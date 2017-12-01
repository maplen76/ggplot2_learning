# area chart
area_plot <- function (data = data, x = date, y = nb_users, title = title, scale_max = scale_max) {
    ggplot(data = data, aes(x = date, y = nb_users, fill = forcats::fct_rev(Platform))) +
        theme_minimal() +
        # theme_fivethirtyeight() +
        theme(plot.title = element_text(hjust = 0.5)) + # set title center
        ggtitle(label = title) +
        geom_area(position = "stack") + # set stack plot
        scale_fill_manual(values = c("#55BF55", "#35AFFF")) + # manually set the fill color
        theme(legend.position = "top") +
        theme(legend.title = element_blank()) +
        theme(panel.grid.minor.x = element_blank()) +
        theme(panel.grid.major.x = element_blank()) +
        theme(panel.grid.minor.y = element_blank()) +
        theme(axis.title = element_blank()) +
        scale_y_continuous(limits = c(0,scale_max),labels = scales::comma) + # set thousand seperator
        theme(axis.ticks.x = element_line(size = 1, colour = "#DEDEDE")) + # set axis ticks
        scale_x_date(date_minor_breaks = "3 days", breaks = pretty_breaks(7), expand = c(0, 0.5)) # expand remove space between axis and area-plot
}


# Pie chart
wof_gameMode_plot <-
ggplot(data = wof_gameMode_total, aes(x = "", y = nb_match, fill = contextName)) +
    geom_bar(width = 1, stat = "identity") + 
    geom_text(aes(x = c(1,1.1,1,1.2,1.4,1.6), y = midpoint, label = labels.prison), size = 3) +
  # geom_label_repel(aes(x = 1, y = midpoint, label = labels.prison))  # require library ggrepel
  # guides(fill = guide_legend(reverse=TRUE,title = NULL,)) + # reverse color fill
    guides(fill = FALSE) +
    coord_polar("y", start=0) +
    scale_fill_brewer(palette = "Oranges") +
    theme_minimal() +
    theme_void()

# line chart
p <-ggplot(data = per_long,aes(x = date, y = perc, color = customization)) +
    geom_line(size = 1) + 
    theme_minimal() +
  # ggtitle("\n\n") +
    scale_y_continuous(limits = c(0,100),
                       labels = dollar_format(suffix = "%", prefix = ""), 
                       breaks = pretty_breaks(5)) +
    theme(axis.title = element_blank(), # remove title
        #  legend.title = element_blank(), # remove legend title
        #  legend.position = c(0.17,1.15), # manually fix
        #  legend.direction = "vertical", # set legend direction
          panel.grid.major.x = element_blank(), #remove x major grid line
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          axis.ticks.x = element_line(size = 1, colour = "#DEDEDE") # set x ticks
          ) +
    scale_x_date(breaks = pretty_breaks(10), expand = c(0, 0.5)) + 
    scale_color_manual(values = c("#ED7D31", '#FFC000', '#BFBFBF')) +
    guides(color = FALSE) # remove legend


# bar chart
rating_df_plot <- ggplot(data = rating_df_pos, aes(x = star, y = percentage)) + 
    theme_minimal() +
    geom_bar(stat = 'identity', fill =  c("#A80000"), width = 0.5) + 
    geom_text(aes(x = star, y = pos,label = paste0(percentage, "%"))) + 
    scale_x_continuous(labels = dollar_format(suffix = " stars", prefix = "")) +
    theme(legend.position="none", 
          axis.text.x = element_blank(),
          axis.title=element_blank(),
          axis.ticks = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank()
          ) +
    coord_flip()
