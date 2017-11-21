ggplot(data = a, aes(x = date, y = nb_users, fill = forcats::fct_rev(Platform))) +
    theme_minimal()+
    geom_area(position = "stack") + 
    theme(legend.position = "top") +
    theme(legend.title = element_blank()) +
    theme(panel.grid.minor.x = element_blank()) +
    theme(panel.grid.major.x = element_blank()) +
    theme(axis.title = element_blank()) +
    scale_x_date(date_minor_breaks = "1 day")
