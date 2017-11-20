library(rmarkdown)
#pandoc version 1.12.3 or higher is required and was not found
Sys.setenv(RSTUDIO_PANDOC = "D:/Program Files/RStudio/bin/pandoc")
rmarkdown::render("F:\\Console_WOF\\RApps\\wof_xbox_store_rating.Rmd")

library(htmlTable)
library(RDCOMClient)

today <- Sys.Date()
title <- paste0('[WOF] Xbox Store Rating: ',Rating_xbox_store, ' on ', today)
body <- paste0('Xbox Store Rating is ',Rating_xbox_store, ' on ', today)

OutApp <- COMCreate("Outlook.Application")
outMail = OutApp$CreateItem(0)

outMail[["To"]] = "jing.wang@ubisoft.com"
outMail[["CC"]] = "jing.wang@ubisoft.com"
outMail[["subject"]] = title

# attach reviews distributions
# to attach img into the HTML body
outMail[["Attachments"]]$Add("F:/Console_WOF/RApps/rating_df_plot.png")
# Refer to the attachment with a cid
# "basename" returns the file name without the directory.
rating_df_plot_img.inline <- paste0( "<img src='cid:",
                                     basename("rating_df_plot.png"),
                                     "' width = '400'>"
                                     )

# attach most useful word Cloud
outMail[["Attachments"]]$Add("F:/Console_WOF/RApps/most_useful_reviews.png")
# Refer to the attachment with a cid
# "basename" returns the file name without the directory.
most_useful_reviews.inline <- paste0( "<img src='cid:",
                                     basename("most_useful_reviews.png"),
                                     "' width = '400'>")


MyHTML <- paste0('<html><h1><strong>',
                 Rating_xbox_store,
                 "</strong></h1>",
                 "<p>Reviewed by ",
                 nb_ratings_players,
                 " players</p>",
                 '<p>Check out Xbox store page <em><a href="https://www.microsoft.com/en-us/store/p/wheel-of-fortune/br76vbtv0nk0">Wheel of Fortune</a></em></p>',
                 '<p><em>The data is grabbed by ',
                 Sys.time(),
                 '</em></p>',
                 '<p>Reviews Distributions</p>',
                 '<p>',
                 rating_df_plot_img.inline,
                 '</p>',
                 '<p><a href="https://www.microsoft.com/en-us/store/p/wheel-of-fortune/br76vbtv0nk0#ratings-reviews">Most Helpful Reviews</a>',
                 ' Word Cloud <em>(Most Helpful Reivews are the default reviews displayed in WOF Xbox store game page)</em></p>',
                 '<p>',
                 most_useful_reviews.inline,
                 '</p><html>'
                 )

outMail[["HTMLbody"]] =  MyHTML

outMail$Send()
unlink("rating_df_plot.png")
unlink("most_useful_reviews.png")

#outMail[["body"]] = "test"
#outMail[["Attachments"]]$Add('F:\\Console_WOF\\RApps\\wof_xbox_store_rating.pdf')

