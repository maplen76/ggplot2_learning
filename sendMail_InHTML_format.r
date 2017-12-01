# set working directory
setwd("F:\\Console_WOF\\RApps\\weekly_report")

library(rmarkdown)
library(htmlTable)
library(readtext)
library(stringr)

# pandoc version 1.12.3 or higher is required and was not found
# render rmd file
Sys.setenv(RSTUDIO_PANDOC = "D:\\Program Files\\RStudio\\bin\\pandoc")
rmarkdown::render("wof_weekly_report.Rmd")

library(RDCOMClient)
# create outlook app
today <- Sys.Date()
title <- paste0('[WOF][JEO] Marketing Report Week of ', dt_start, ' ~ ', dt_end)

OutApp <- COMCreate("Outlook.Application")
outMail = OutApp$CreateItem(0)

outMail[["To"]] = "xxx@xxxx.com"
outMail[["CC"]] = "xxx@xxx.com"
outMail[["subject"]] = title

# attach all of png files
# list all of files in the directory and filter out .png files, and attach all of them
charts <- list.files() %>% str_subset(".png")
charts <- paste0(getwd(),'/',charts) # have to attach the full path when attch file as attachment

for (a in charts) {
    cht = a
    outMail[["Attachments"]]$Add(cht)
}

# build HTML body
# have to create a HTML.txt file to store HTML code, and replace corresponding values
library(readtext)
htmlbody <- readtext("wof_weekly_report_format.txt")
MyHTML <- htmlbody$text

# variable list is stored in file wof_weekly_report_variable_list.txt
value_list <- read.csv("wof_weekly_report_variable_list.txt", header = F, col.names = "variable", stringsAsFactors = F)$variable
# update values in the html script
for (l in value_list) {
    patt <- l
    repl <- eval(parse(text = l)) # extract value from string
    MyHTML <- str_replace(string = MyHTML, pattern = patt, replacement = repl)
}

outMail[["HTMLbody"]] =  MyHTML
outMail$Send()
