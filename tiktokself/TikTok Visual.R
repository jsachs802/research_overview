library(tidyverse)

load("short_tiktok_df.Rda")


library(viridis)


p <- ggplot(data = short_tiktok_df,
            mapping = aes(x = time_stamp,
                          group = music.id,
                          color = type)) 

p1 <- p + geom_freqpoly(aes(y=..density..), binwidth = 2)


p2 <- p1 + facet_grid(type~.) 

p3 <- p2 + theme_classic() + theme(strip.background = element_blank(),
                                   strip.text.y = element_blank(),
                                   axis.text.x=element_text(angle=-45), 
                                   legend.position = c(0.7, 0.55), 
                                   legend.key.width = unit(1, "cm"), 
                                   legend.key.height = unit(1, "line")) 

p4 <- p3 + scale_x_date(limits = as.Date(c("2020-01-01", "2021-03-10"))) + 
  scale_color_viridis_d(begin= 0.2, end = 0.7, option="magma", 
                        name = "Music Type",
                        labels = c("Coming Out TikTok Songs", 
                                   "Top Songs of 2020 (streaming)", 
                                   "Top TikTok Songs of 2020")) + 
  guides() + 
  labs(x=NULL, y = "Density") +
  scale_y_continuous(breaks = c(0, 0.02, 0.04), labels = c(0, 0.02, 0.04), limits = c(0, 0.05))

p4


### TikTok Bar Plot


totals <- data_frame(song = c("        Hayloft", 
                              "Sweater Weather", 
                              "          Girls", 
                              " Original Sound", 
                              "       Relationship", 
                              "            Lottery", 
                              "Blinding Lights", 
                              "   Dance Monkey", 
                              "          Roses", 
                              "  Before You Go"),
                     artist = c("Mother Mother", "The Neighbourhood", "Girl in Red", "Lucy", "Young Thug", "K Camp", "The Weeknd", "Tones and I","SAINt JHN", "Lewis Capaldi"), 
                     type = c("gs", "gs", "gs", "gs", "tiktok", "tiktok", "pop", "pop", "pop", "pop"), 
                     total_videos = c(222000, 457700, 119600, 12600, 27600000, 25800000, 1300000, 6700000, 2600000, 831100))


library(scales)


gs <- ggplot(totals %>% filter(type == "gs"), aes(reorder(x = song, -total_videos), y = total_videos)) + 
  geom_bar(stat="identity", aes(fill = type)) + 
  scale_fill_viridis_d(begin= 0.2, end = 0.7, option="magma") + 
  scale_y_sqrt(labels = comma) + theme_classic() + guides(fill= "none") + 
  theme(axis.text.x=element_text(angle=-90) )+ 
  labs(x=NULL, y=NULL) +
  coord_flip()

tt <- ggplot(totals %>% filter(type == "tiktok"), aes(reorder(x = song, -total_videos), y = total_videos)) + 
  geom_bar(stat="identity", aes(fill = type)) + 
  scale_fill_viridis_d(begin= 0.7, end = 0.7, option="magma") + 
  scale_y_sqrt(labels = comma) + theme_classic() + guides(fill= "none") + 
  theme(axis.text.x=element_text(angle=-90)) + 
  labs(x=NULL, y=NULL) + 
  coord_flip()

pop <- ggplot(totals %>% filter(type == "pop"), aes(reorder(x = song, -total_videos), y = total_videos)) + 
  geom_bar(stat="identity", aes(fill = type)) + 
  scale_fill_viridis_d(begin= 0.5, end = 0.5, option="magma") + 
  scale_y_sqrt(labels = comma) + theme_classic() + guides(fill= "none") + 
  theme(axis.text.x=element_text(angle=-90)) + 
  labs(x=NULL, y=NULL)+
  coord_flip()


library(gridExtra)
library(grid)
library(cowplot)


gl = list(as_grob(p4), as_grob(gs), as_grob(tt), as_grob(pop))

titokplot <- grid.arrange(grobs = gl, 
             widths = c(3, 0.01, 1, 0.1),
             heights = c(0.1, 0.7, 0.2, 0.7, 0.3, 0.5, 0.1),
             padding = unit(2, "line"),
             layout_matrix = rbind(c(1,NA, NA, NA),
                                   c(1,NA, 2, NA),
                                   c(1,NA, NA, NA),
                                   c(1,NA, 4, NA), 
                                   c(1,NA, NA, NA), 
                                   c(1,NA, 3, NA)))


