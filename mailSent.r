library(RDCOMClient)


OutApp <- COMCreate("Outlook.Application")

outMail = OutApp$CreateItem(0)

outMail[["To"]] = "jing.wang@163.com"
outMail[["subject"]] = "test"
outMail[["body"]] = "test"
outMail[["Attachments"]]$Add('F:\\Console_WOF\\RApps\\wof_xbox_store_rating.pdf')


outMail$Send()
