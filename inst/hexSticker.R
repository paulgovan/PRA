library(hexSticker)

# Create the sticker
sticker("inst/logo.png",
        package = "",
        s_x=1, s_y=1, s_width=.67,
        h_fill = rgb(210, 190, 155, maxColorValue = 255),
        h_color = rgb(253, 63, 56, maxColorValue = 255),
        filename = "pra_hex_sticker.png")

# Display the sticker
sticker
