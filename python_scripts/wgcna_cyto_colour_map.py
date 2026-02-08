import py4cytoscape as p4c

style_name = "WGCNA_style_full"
p4c.create_visual_style(style_name)

color_map = {
    "bisque4": "#8B7D6B",
    "black": "#000000",
    "blue": "#0000FF",
    "brown": "#A52A2A",
    "brown4": "#8B2323",
    "cyan": "#00FFFF",
    "darkgreen": "#006400",
    "darkgrey": "#A9A9A9",
    "darkmagenta": "#8B008B",
    "darkolivegreen": "#556B2F",
    "darkorange": "#FF8C00",
    "darkorange2": "#EE7600",
    "darkred": "#8B0000",
    "darkslateblue": "#483D8B",
    "darkturquoise": "#00CED1",
    "floralwhite": "#FFFAF0",
    "green": "#008000",
    "greenyellow": "#ADFF2F",
    "grey": "#BEBEBE",
    "grey60": "#999999",
    "ivory": "#FFFFF0",
    "lightcyan": "#E0FFFF",
    "lightcyan1": "#E0FFFF",
    "lightgreen": "#90EE90",
    "lightsteelblue1": "#CAE1FF",
    "lightyellow": "#FFFFE0",
    "magenta": "#FF00FF",
    "mediumpurple3": "#8968CD",
    "midnightblue": "#191970",
    "orange": "#FFA500",
    "orangered4": "#8B2500",
    "paleturquoise": "#AFEEEE",
    "pink": "#FFC0CB",
    "plum1": "#FFBBFF",
    "plum2": "#EEAEEE",
    "purple": "#800080",
    "red": "#FF0000",
    "royalblue": "#4169E1",
    "saddlebrown": "#8B4513",
    "salmon": "#FA8072",
    "sienna3": "#CD6839",
    "skyblue": "#87CEEB",
    "skyblue3": "#6CA6CD",
    "steelblue": "#4682B4",
    "tan": "#D2B48C",
    "turquoise": "#40E0D0",
    "violet": "#EE82EE",
    "white": "#FFFFFF",
    "yellow": "#FFFF00",
    "yellowgreen": "#9ACD32"
}

p4c.set_node_color_mapping(
    style_name=style_name,
    table_column="WGCNA_cluster",   # change if needed
    mapping_type="d",
    mapping=color_map
)

p4c.set_current_style(style_name)

