library(RDCOMClient)
# create outlook app
today <- Sys.Date()
title <- paste0('[WOF][JEO] Marketing Report Week of ',dt_start, ' ~ ', dt_end)

OutApp <- COMCreate("Outlook.Application")
outMail = OutApp$CreateItem(0)

# yu.wang3@ubisoft.com
outMail[["To"]] = "jing.wang@ubisoft.com"
outMail[["CC"]] = "jing.wang@ubisoft.com"
outMail[["subject"]] = title

# attach all of png files
charts <- list.files() %>% str_subset(".png")
for (a in charts) {
    cht = a
    outMail[["Attachments"]]$Add(cht)
}

# build HTML body
library(readtext)
htmlbody <- readtext("wof_weekly_report_format.txt")

MyHTML <- htmlbody$text

value_list_wof <- c("wof_total", "wof_total_x1", "wof_total_ps4", "wof_sessions_x1", "wof_sessions_ps4")
value_list_jeo <- c("jeo_total", "jeo_total_x1", "jeo_total_ps4", "jeo_sessions_x1", "jeo_sessions_ps4")
value_list <- c(value_list_wof, value_list_jeo)

# update values in the html script
for (l in value_list) {
    patt <- l
    repl <- eval(parse(text = l)) # extract value from string
    MyHTML <- str_replace(string = MyHTML, pattern = patt, replacement = repl)
}

outMail[["HTMLbody"]] =  MyHTML
outMail$Send()
