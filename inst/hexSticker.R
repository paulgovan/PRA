
library(hexSticker)
imgurl <- "inst/gauge.svg"
my_sticker <- theme_sticker(size = 2)
my_sticker <- sticker(imgurl,
                      s_x            = 1,
                      s_y            = 0.75,
                      s_width        = 0.45,
                      package        = "PRA",
                      p_size         = 20,
                      p_color        = "white",
                      h_fill         = "#fb6a4a",
                      h_color        = "#a50f15",
                      h_size         = 3.0,
                      url = "paulgovan.github.io/PRA",
                      u_size = 5,
                      filename       = "inst/PRA_hex_sticker.png"
                      )
plot(my_sticker)


