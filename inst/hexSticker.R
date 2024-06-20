# Install the necessary package if not already installed
# install.packages("hexSticker")
# install.packages("ggplot2")

library(hexSticker)
library(ggplot2)

# Create a simple bar chart for the sticker
plot <- ggplot(data.frame(x = factor(c("Low", "Medium", "High")), y = c(0.3, 0.5, 0.4)), aes(x, y)) +
  geom_bar(stat = "identity", fill = c("green", "yellow", "red")) +
  theme_void() +
  theme_transparent() +
  theme(legend.position = "none")

# Create the sticker
sticker(plot,
        package = "PRA",
        p_size = 20,        # Package name font size
        s_size = 10,        # Subtitle font size
        s_x = 1,            # Subtitle x position
        s_y = 0.6,          # Subtitle y position
        s_color = "darkblue",  # Subtitle color
        h_fill = "lightblue",  # Hexagon fill color
        h_color = "black",     # Hexagon border color
        p_color = "darkblue",  # Package name color
        filename = "pra_hex_sticker.png")

# Display the sticker
sticker
