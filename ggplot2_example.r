# creae area_plot
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
