library(hexSticker)

# Create the sticker
sticker("inst/logo2.png",
        package = "PRA",
        p_size=25, p_color = "black",
        s_x=1, s_y=0.8, s_width=.6,
        h_fill = "white",  # Hexagon fill color
        h_color = "black",     # Hexagon border color
        filename = "pra_hex_sticker.png")

# Display the sticker
sticker
