"""All the constants used in the module."""

TABLE = (
    '"{}" [label=<<FONT FACE="IPAexGothic"><TABLE BORDER="0" CELLBORDER="1"'
    ' CELLPADDING="4" CELLSPACING="0">{}{}</TABLE></FONT>>];'
)

START_CELL = '<TR><TD ALIGN="LEFT"><FONT FACE="IPAexGothic">'
FONT_TAGS = "<FONT {}>{}</FONT>"
# Used for each row in the table.
ROW_TAGS = "<TR><TD{}>{}</TD></TR>"
DOT_GRAPH_BEGINNING = """
      digraph {
         graph [rankdir=LR, fontname="IPAexGothic"];
         node [label="\\N",
             shape=plaintext,
             fontname="IPAexGothic"
         ];
         edge [color=gray50,
             minlen=2,
             style=dashed,
             fontname="IPAexGothic",
             labelfontname="IPAexGothic",
             headlabelfontname="IPAexGothic",
             taillabelfontname="IPAexGothic"
         ];
      """
ER_FORMAT_TITLE = 'title {{label: "{}", size: "40"}}'
