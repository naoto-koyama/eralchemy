"""This class allow to transform SQLAlchemy metadata to the intermediary syntax."""

from __future__ import annotations

from typing import TYPE_CHECKING, Any, Callable

import sqlalchemy as sa
from sqlalchemy import create_engine
from sqlalchemy.exc import CompileError
from sqlalchemy.ext.automap import AutomapBase, automap_base

from .models import Column, Relation, Table

if TYPE_CHECKING:
    from typing_extensions import Protocol

    class DeclarativeBase(Protocol):
        metadata: sa.MetaData


def check_all_compound_same_parent(fk: sa.ForeignKey):
    """Checks if all other ForeignKey Constraints of our table are on the same parent table as the current one."""
    table = fk.column.table.fullname
    if not fk.constraint:
        return True
    for col in fk.constraint.table.columns:
        if not col.foreign_keys:
            return False
        for foreign_column in col.foreign_keys:
            if table != foreign_column.column.table.fullname:
                return False
    return True


def relation_to_intermediary(fk: sa.ForeignKey) -> Relation:
    """Transform an SQLAlchemy ForeignKey object to its intermediary representation."""
    primkey_count = 0
    if fk.constraint:
        primkey_count = sum(
            [True for x in fk.constraint.table.columns if x.primary_key],
        )
    # when there is only a single primary key column of the current key
    if (primkey_count == 1 and fk.parent.primary_key) or fk.parent.unique:
        right_cardinality = "1"
    else:
        # check if the other primkeys have a foreign key onto the same table
        # if this is the case, we are not optional and must be unique
        right_cardinality = "1" if check_all_compound_same_parent(fk) else "*"
    return Relation(
        right_table=format_name(fk.parent.table.fullname),
        right_column=format_name(fk.parent.name),
        left_table=format_name(fk.column.table.fullname),
        left_column=format_name(fk.column.name),
        right_cardinality=right_cardinality,
        left_cardinality="?" if fk.parent.nullable else "1",
    )


def format_type(typ: Any) -> str:
    """Transforms the type into a nice string representation."""
    try:
        return str(typ)
    except CompileError:
        return "Null"


def format_name(name: Any) -> str:
    """Transforms the name into a nice string representation."""
    return str(name)


def column_to_intermediary(
    col: sa.Column,
    type_formatter: Callable[[Any], str] = format_type,
) -> Column:
    """Transform an SQLAlchemy Column object to its intermediary representation."""
    return Column(
        name=col.name,
        type=type_formatter(col.type),
        is_key=col.primary_key,
        is_null=col.nullable,
    )


def table_to_intermediary(table: sa.Table) -> Table:
    """Transform an SQLAlchemy Table object to its intermediary representation."""
    table_columns = getattr(table.c, "_colset", getattr(table.c, "_data", {}).values())
    return Table(
        name=table.fullname,
        columns=[column_to_intermediary(col) for col in table_columns],
    )


def metadata_to_intermediary(
    metadata: sa.MetaData,
) -> tuple[list[Table], list[Relation]]:
    """Transforms SQLAlchemy metadata to the intermediary representation."""
    tables = [table_to_intermediary(table) for table in metadata.tables.values()]
    relationships = [
        relation_to_intermediary(fk)
        for table in metadata.tables.values()
        for fk in table.foreign_keys
    ]
    return tables, relationships


def declarative_to_intermediary(
    base: DeclarativeBase,
) -> tuple[list[Table], list[Relation]]:
    """Transform an SQLAlchemy Declarative Base to the intermediary representation."""
    return metadata_to_intermediary(base.metadata)


def name_for_scalar_relationship(
    base: AutomapBase,
    local_cls: Any,
    referred_cls: type[Any],
    constraint: sa.ForeignKeyConstraint,
) -> str:
    """Overriding naming schemes."""
    return referred_cls.__name__.lower() + "_ref"


def database_to_intermediary(
    database_uri: str,
    schema: str | None = None,
    use_comments: bool = False,
) -> tuple[list[Table], list[Relation]]:
    """Introspect from the database (given the database_uri) to create the intermediary representation."""
    Base = automap_base()
    engine = create_engine(database_uri)
    
    # 追加: コメント情報を取得する辞書
    column_comments = {}
    table_comments = {}
    
    # コメント情報を取得する（PostgreSQL用）
    if use_comments:
        try:
            with engine.connect() as connection:
                # テーブルコメントを取得
                table_comment_query = """
                SELECT table_name, obj_description(
                    (quote_ident(table_schema) || '.' || quote_ident(table_name))::regclass, 'pg_class'
                ) as comment
                FROM information_schema.tables
                WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
                AND obj_description(
                    (quote_ident(table_schema) || '.' || quote_ident(table_name))::regclass, 'pg_class'
                ) IS NOT NULL
                """
                if schema is not None:
                    schemas = schema.split(",")
                    schema_conditions = " OR ".join([f"table_schema = '{s.strip()}'" for s in schemas])
                    table_comment_query += f" AND ({schema_conditions})"
                
                table_comment_result = connection.execute(sa.text(table_comment_query))
                for row in table_comment_result:
                    table_comments[row[0]] = row[1]
                
                # カラムコメントを取得
                column_comment_query = """
                SELECT table_name, column_name, col_description(
                    (quote_ident(table_schema) || '.' || quote_ident(table_name))::regclass,
                    ordinal_position
                ) as comment
                FROM information_schema.columns
                WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
                AND col_description(
                    (quote_ident(table_schema) || '.' || quote_ident(table_name))::regclass,
                    ordinal_position
                ) IS NOT NULL
                """
                if schema is not None:
                    schemas = schema.split(",")
                    schema_conditions = " OR ".join([f"table_schema = '{s.strip()}'" for s in schemas])
                    column_comment_query += f" AND ({schema_conditions})"
                
                column_comment_result = connection.execute(sa.text(column_comment_query))
                for row in column_comment_result:
                    key = f"{row[0]}.{row[1]}"
                    column_comments[key] = row[2]
        except Exception as e:
            print(f"コメント情報の取得中にエラーが発生しました: {e}")
    
    if schema is not None:
        schemas = schema.split(",")
        for schema in schemas:
            schema = schema.strip()
            # reflect the tables
            Base.metadata.schema = schema
            Base.prepare(
                engine,
                name_for_scalar_relationship=name_for_scalar_relationship,
            )
    else:
        # reflect the tables
        Base.prepare(
            engine,
            name_for_scalar_relationship=name_for_scalar_relationship,
        )

    tables, relationships = declarative_to_intermediary(Base)
    
    # 追加: コメント情報をテーブルとカラムに適用
    if use_comments:
        for table in tables:
            # テーブルコメントを適用（現在は使用していないが将来的に使用する可能性あり）
            if table.name in table_comments:
                table.comment = table_comments[table.name]
            
            # カラムコメントを適用
            for column in table.columns:
                key = f"{table.name}.{column.name}"
                if key in column_comments:
                    # コメントをカラムの型として設定（use_commentsモードの場合）
                    column.comment = column_comments[key]
                    if use_comments:
                        column.type = column_comments[key]
    
    return tables, relationships
