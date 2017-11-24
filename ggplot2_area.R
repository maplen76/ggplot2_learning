---
title: "WOF Weekly Report"
author: "Jing.wang@ubisoft.com"
date: "`r Sys.Date()`"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## WOF Acquistion

```{r build_WOF_Connection, include=FALSE}
library(ggplot2)
library(dplyr)
library(scales)
library(RODBCDBI)
# wof is stored on dw05
con <- dbConnect(RODBCDBI::ODBC(), dsn = "dnadw05")
dt <- as.character(Sys.Date())
dt_end <- as.character(Sys.Date()-1)
dt_start <- as.character(Sys.Date()-7)
```

```{sql wof_dnu, connection=con, include=FALSE, output.var="wof_new_daily"}
-- extract WOF daily new users
SELECT
    COUNT(DISTINCT p.profileId) AS nb_users
    ,CASE CAST(p.firstSessionStart AS date) WHEN '1970-01-01' THEN CAST(p.lasteventreceived AS date) ELSE CAST(p.firstSessionStart AS date) END AS date
    ,CASE WHEN pf.Platform IS NULL THEN 'Unknown' ELSE pf.Platform END AS Platform
FROM
    DW_WOF_POSTLAUNCH.profile.player AS p
LEFT JOIN 
    DW_WOF_POSTLAUNCH.[user].dim_platform pf ON p.appId = pf.appId
GROUP BY 
    CASE CAST(p.firstSessionStart AS date) WHEN '1970-01-01' THEN CAST(p.lasteventreceived AS date) ELSE CAST(p.firstSessionStart AS date) END
    ,CASE WHEN pf.Platform IS NULL THEN 'Unknown' ELSE pf.Platform END

```

```{r wof_nb_for_html}
wof_new <- wof_new_daily %>%
    group_by(Platform) %>%
    summarise(sub_total = sum(nb_users)) %>%
    mutate(total=sum(sub_total),
           percentage = scales::percent(sub_total/total),
           s_total = formatC(sub_total, format="f", big.mark = " ", digits=0),
           t = formatC(total, format="f", big.mark = " ", digits=0),
           lable = paste0(s_total, " (", percentage,")")
           )

wof_total <- wof_new %>% dplyr::filter(Platform == 'PS4') %>% dplyr::select(t) %>% as.character()
wof_total_ps4 <- wof_new %>% dplyr::filter(Platform == 'PS4') %>% dplyr::select(lable) %>% as.character()
wof_total_x1 <- wof_new %>% dplyr::filter(Platform == 'Xone') %>% dplyr::select(lable) %>% as.character()
    
```


```{r wof_dnu_plot, include=FALSE}
# create area plot function
area_plot <- function (data = data, x = date, y = nb_users, title = title) {
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
        scale_y_continuous(labels = scales::comma) + # set thousand seperator
        theme(axis.ticks.x = element_line(size = 1, colour = "#DEDEDE")) + # set axis ticks
        scale_x_date(date_minor_breaks = "3 days", breaks = pretty_breaks(7), expand = c(0, 0.5)) # expand remove space between axis and area-plot
}

```

```{r =}
wof_new_daily = wof_new_daily %>% 
    filter(date >= '2017-11-07') %>% 
    tbl_df()

wof_new_daily_plot <- area_plot(data = wof_new_daily, x = date, y = nb_users, title = "WOF Acquisition Trend")
ggsave(filename = "wof_new_daily_plot.png", plot = wof_new_daily_plot, width = 5, height = 3)

wof_new_daily_plot
```

```{sql wof_dau, connection=con, include=FALSE, output.var="wof_dau"}
-- extract WOF DAU
SELECT 
	CAST(gs.ServerTimestamp AS date) AS date
	,CASE WHEN pf.Platform IS NULL THEN 'Unknown' ELSE pf.Platform END AS Platform
	,COUNT(DISTINCT gs.profileId) AS nb_users
	,COUNT(DISTINCT gs.SessionId) AS nb_sessions
FROM 
	DW_WOF_POSTLAUNCH.event.gameStart gs
LEFT JOIN 
	DW_WOF_POSTLAUNCH.[user].dim_platform pf ON gs.appId = pf.appId
GROUP BY
	CAST(gs.ServerTimestamp AS date)
	,CASE WHEN pf.Platform IS NULL THEN 'Unknown' ELSE pf.Platform END

```

## WOF DAU
```{r wof_dau_plot, fig.cap = "WOF DAU"}
wof_dau = wof_dau %>% 
    filter(date >= '2017-11-07') %>% 
    tbl_df()

wof_dau_plot <- area_plot(data = wof_dau, x = date, y = nb_users, title = "WOF DAU")

ggsave(filename = "wof_dau_plot.png", plot = wof_dau_plot, width = 5, height = 3)

wof_dau_plot

```

## WOF Game Mode
```{sql wof_gameMode, connection=con, include=FALSE, output.var="wof_gameMode"}
-- extract WOF Game Mode Played
SELECT 
	CASE WHEN pf.platform IS NOT NULL THEN pf.platform ELSE a.AppId END AS Platform
    ,a.contextName	
	,CAST(a.ServerTimestamp AS DATE) AS date
	,COUNT(DISTINCT a.EventId) AS nb_matches
FROM 
	DW_WOF_POSTLAUNCH.event.match_start a
LEFT JOIN 
	DW_WOF_POSTLAUNCH.[user].dim_platform pf ON a.AppId = pf.AppId
WHERE 
	a.matchSource IS NOT NULL
GROUP BY
	CASE WHEN pf.platform IS NOT NULL THEN pf.platform ELSE a.AppId END
    ,a.contextName	
	,CAST(a.ServerTimestamp AS DATE)
```

```{r wof_gameModeDsitribution}
wof_gameMode_total <- wof_gameMode %>%
    filter(date >= '2017-11-07') %>%
    group_by(contextName) %>%
    summarise(nb_match = sum(nb_matches)) %>%
    arrange(desc(nb_match)) %>%
    mutate(total_match = sum(nb_match)) %>%
    mutate(percentage = nb_match/total_match,
           per = round(percentage*100),
           labels.prison = paste(contextName,": ", per, "%", sep = ""),
           cuml = cumsum(nb_match),
           midpoint = cuml - nb_match/2
           )

# order the factor to plot
wof_gameMode_total$contextName <- factor(wof_gameMode_total$contextName, levels = wof_gameMode_total$contextName[order((wof_gameMode_total$nb_match), decreasing = F)])

wof_gameMode_plot <-
ggplot(data = wof_gameMode_total, aes(x = "", y = nb_match, fill = contextName)) +
    geom_bar(width = 1, stat = "identity") + 
    geom_text(aes(x = c(1,1.1,1,1.2,1.4,1.6), y = midpoint, label = labels.prison)) +
  # load library ggrepel geom_label_repel(aes(x = 1, y = midpoint, label = labels.prison)) 
  # guides(fill = guide_legend(reverse=TRUE,title = NULL,)) +
    guides(fill = FALSE) +
    coord_polar("y", start=0) +
    scale_fill_brewer(palette = "Oranges") +
    theme_minimal() +
    theme_void()

ggsave(filename = "wof_gameMode_plot.png", plot = wof_gameMode_plot, width = 5, height = 3)
wof_gameMode_plot

```

```{r disconnect_wof, include=FALSE}
# close dw05 connection
dbDisconnect(con)
```

## JEO Acquistion
```{r build_jeo_connection, include=FALSE}
# JEO is stored on dw06
con <- dbConnect(RODBCDBI::ODBC(), dsn = "dnadw06")
dt <- as.character(Sys.Date())
```

```{sql extract_dnu, connection=con, include=FALSE, output.var="jeo_new_daily"}
-- extract JEO daily new users
SELECT
    COUNT(DISTINCT p.profileId) AS nb_users
    ,CASE CAST(p.firstSessionStart AS date) WHEN '1970-01-01' THEN CAST(p.lasteventreceived AS date) ELSE CAST(p.firstSessionStart AS date) END AS date
    ,CASE WHEN pf.Platform IS NULL THEN 'Unknown' ELSE pf.Platform END AS Platform
FROM
    DW_JEOPARDY_POSTLAUNCH.profile.player AS p
LEFT JOIN 
    DW_JEOPARDY_POSTLAUNCH.[user].dim_platform pf ON p.appId = pf.appId
GROUP BY 
    CASE CAST(p.firstSessionStart AS date) WHEN '1970-01-01' THEN CAST(p.lasteventreceived AS date) ELSE CAST(p.firstSessionStart AS date) END
    ,CASE WHEN pf.Platform IS NULL THEN 'Unknown' ELSE pf.Platform END

```

```{r jeo_nb_for_html}
jeo_new <- jeo_new_daily %>%
    group_by(Platform) %>%
    summarise(sub_total = sum(nb_users)) %>%
    mutate(total=sum(sub_total),
           percentage = scales::percent(sub_total/total),
           s_total = formatC(sub_total, format="f", big.mark = " ", digits=0),
           t = formatC(total, format="f", big.mark = " ", digits=0),
           lable = paste0(s_total, " (", percentage,")")
           )

jeo_total <- jeo_new %>% dplyr::filter(Platform == 'PS4') %>% dplyr::select(t) %>% as.character()
jeo_total_x1 <- jeo_new %>% dplyr::filter(Platform == 'PS4') %>% dplyr::select(lable) %>% as.character()
jeo_total_ps4 <- jeo_new %>% dplyr::filter(Platform == 'Xone') %>% dplyr::select(lable) %>% as.character()
    
```

```{r jeo_new_plot, fig.cap = "JEO New Users"}
jeo_new_daily = jeo_new_daily %>% 
    filter(date >= '2017-11-07') %>% 
    tbl_df()

jeo_new_daily_plot <- area_plot(data = jeo_new_daily,x = date, y = nb_users, title = "JEO Acquistion Trend")
ggsave(filename = "jeo_new_daily_plot.png", plot = jeo_new_daily_plot, width = 5, height = 3)

jeo_new_daily_plot

```

## JEO DAU
```{sql extract_dau, connection=con, include=FALSE, output.var="jeo_dau"}
-- extract JEO dau
SELECT 
	CAST(gs.ServerTimestamp AS date) AS date
	,CASE WHEN pf.Platform IS NULL THEN 'Unknown' ELSE pf.Platform END AS Platform
	,COUNT(DISTINCT gs.profileId) AS nb_users
	,COUNT(DISTINCT gs.SessionId) AS nb_sessions
FROM 
	DW_JEOPARDY_POSTLAUNCH.event.gameStart gs
LEFT JOIN 
	DW_JEOPARDY_POSTLAUNCH.[user].dim_platform pf ON gs.appId = pf.appId
GROUP BY
	CAST(gs.ServerTimestamp AS date)
	,CASE WHEN pf.Platform IS NULL THEN 'Unknown' ELSE pf.Platform END

```

```{r jeo_dau_plot, fig.cap = "JEO DAU"}
jeo_dau = jeo_dau %>% 
    filter(date >= '2017-11-07') %>% 
    tbl_df()

jeo_dau_plot <- area_plot(data = jeo_dau, x = date, y = nb_users, title = "JEO DAU")

ggsave(filename = "jeo_dau_plot.png", plot = jeo_dau_plot, width = 5, height = 3)
jeo_dau_plot

```

## JEO Game Mode
```{sql jeo_gameMode, connection=con, include=FALSE, output.var="jeo_gameMode"}
-- extract JEO Game Mode Played
SELECT 
	CASE WHEN pf.platform IS NOT NULL THEN pf.platform ELSE a.AppId END AS Platform
    ,a.contextName	
	,CAST(a.ServerTimestamp AS DATE) AS date
	,COUNT(DISTINCT a.EventId) AS nb_matches
FROM 
	DW_JEOPARDY_POSTLAUNCH.event.GameMode_start a
LEFT JOIN 
	DW_JEOPARDY_POSTLAUNCH.[user].dim_platform pf ON a.AppId = pf.AppId
GROUP BY
	CASE WHEN pf.platform IS NOT NULL THEN pf.platform ELSE a.AppId END
    ,a.contextName	
	,CAST(a.ServerTimestamp AS DATE)
```

```{r JEO_gameModeDsitribution}
jeo_gameMode_total <- jeo_gameMode %>%
    filter(date >= '2017-11-07') %>%
    group_by(contextName) %>%
    summarise(nb_match = sum(nb_matches)) %>%
    arrange(desc(nb_match)) %>%
    mutate(total_match = sum(nb_match)) %>%
    mutate(percentage = nb_match/total_match,
           per = round(percentage*100),
           labels.prison = paste(contextName,": ", per, "%", sep = ""),
           cuml = cumsum(nb_match),
           midpoint = cuml - nb_match/2
           )

# order the factor to order plot order as expected
jeo_gameMode_total$contextName <- factor(jeo_gameMode_total$contextName, levels = jeo_gameMode_total$contextName[order((jeo_gameMode_total$nb_match), decreasing = F)])

jeo_gameMode_plot <- ggplot(data = jeo_gameMode_total, aes(x = "", y = nb_match, fill = contextName)) +
    geom_bar(width = 1, stat = "identity") + 
    geom_text(aes(x = c(1,1.2,1.2,1.4,1.6), y = midpoint, label = labels.prison)) +
    # guides(fill = guide_legend(reverse=TRUE,title = NULL,)) +
    guides(fill = FALSE) +
    coord_polar("y", start=0) +
    scale_fill_brewer(palette = "Oranges") +
    theme_minimal() +
    theme_void()

ggsave(filename = "jeo_gameMode_plot.png", plot = jeo_gameMode_plot, width = 5, height = 3)
jeo_gameMode_plot

```

```{r disconnect_jeo, include=FALSE}
# close dw06 connection
dbDisconnect(con)
```

