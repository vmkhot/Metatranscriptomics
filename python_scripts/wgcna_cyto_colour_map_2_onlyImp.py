import py4cytoscape as p4c

style_name = "WGCNA_style_full"
p4c.create_visual_style(style_name)

# set discrete mapping one color at a time
p4c.set_node_color_mapping(
    style_name=style_name,
    table_column="WGCNA_if_important",
    mapping_type="d",
    table_column_values=[
        "bisque4","black","blue","brown","brown4","cyan","darkgreen","darkgrey",
        "darkmagenta","darkolivegreen","darkorange","darkorange2","darkred",
        "darkslateblue","darkturquoise","floralwhite","green","greenyellow",
        "grey","grey60","ivory","lightcyan","lightcyan1","lightgreen",
        "lightsteelblue1","lightyellow","magenta","mediumpurple3","midnightblue",
        "orange","orangered4","paleturquoise","pink","plum1","plum2","purple",
        "red","royalblue","saddlebrown","salmon","sienna3","skyblue","skyblue3",
        "steelblue","tan","turquoise","violet","white","yellow","yellowgreen"
    ],
    colors=[
        "#8B7D6B","#000000","#0000FF","#A52A2A","#8B2323","#00FFFF","#006400","#A9A9A9",
        "#8B008B","#556B2F","#FF8C00","#EE7600","#8B0000","#483D8B","#00CED1","#FFFAF0",
        "#008000","#ADFF2F","#BEBEBE","#999999","#FFFFF0","#E0FFFF","#E0FFFF","#90EE90",
        "#CAE1FF","#FFFFE0","#FF00FF","#8968CD","#191970","#FFA500","#8B2500","#AFEEEE",
        "#FFC0CB","#FFBBFF","#EEAEEE","#800080","#FF0000","#4169E1","#8B4513","#FA8072",
        "#CD6839","#87CEEB","#6CA6CD","#4682B4","#D2B48C","#40E0D0","#EE82EE","#FFFFFF",
        "#FFFF00","#9ACD32"
    ]
)

p4c.set_visual_style(style_name)

