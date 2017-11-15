# WOF XBOX Store Rating
library(rvest)
library(dplyr)
library(stringr)
library(ggplot2)
library(scales)
setwd('F:\\Console_WOF\\RApps')

# xbox store page of WOF: https://www.microsoft.com/en-us/store/p/wheel-of-fortune/br76vbtv0nk0

url <- "https://www.microsoft.com/en-us/store/p/wheel-of-fortune/br76vbtv0nk0"
# download.file(url = url, destfile = "wof_xboxstore_rating.html", quiet = T)

url_xbox_store <- read_html(x = url, verbose = T)

# extract xbox store rating
Rating_xbox_store <- url_xbox_store %>% 
    html_nodes(xpath = '//*[@id="ratings-reviews"]/div[1]/div[1]/div/span') %>%
    html_text() %>%
    as.numeric()

nb_ratings <- url_xbox_store %>%
    html_nodes(xpath = '//*[@id="ratings-reviews"]/div[1]/div[1]/div/div/div/span') %>%
    html_text() %>%
    as.numeric()


# to create the x_path of rating distribution
star_a <-'//*[@id="ratings-reviews"]/div[1]/div[1]/ul/li['
star_b <- ']/a/span[1]'

per_a <- '//*[@id="ratings-reviews"]/div[1]/div[1]/ul/li['
per_b <- ']/a/div/div/span'

rating_df <- data.frame()

for (i in 1:5) {
    star_xpath <-  paste0(star_a,i,star_b)
    percentage_xpath <- paste0(per_a,i,per_b)
    
    star <- url_xbox_store %>%
        html_nodes(xpath = star_xpath) %>%
        html_text() %>%
        str_sub(1,1) %>%
        as.numeric()
    
    percentage <- url_xbox_store %>%
        html_nodes(xpath = percentage_xpath) %>%
        html_text() %>%
        str_replace('%', '') %>%
        as.numeric()
    
    df <- data.frame(star = star, percentage = percentage)
    rating_df <- rbind.data.frame(rating_df, df)
    print(rating_df)
}

# visualize rating distribution
rating_df_pos <- rating_df %>% mutate(pos = percentage+2)

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
  


review_user <- url_xbox_store %>%
    html_nodes(xpath = '//*[@class="srv_reviews"]/div[2]/div[1]/p[2]') %>%
    html_text()

review_date <- url_xbox_store %>%
    html_nodes(xpath = '//*[@class="srv_reviews"]/div[2]/div[1]/p[1]') %>%
    html_text()

review_star <- url_xbox_store %>%
    html_nodes(xpath = '//*[@class="srv_reviews"]/div[2]/div[1]/div/p/span[1]') %>%
    html_text() %>%
    as.numeric()

review_title <- url_xbox_store %>%
    html_nodes(xpath = '//*[@class="srv_reviews"]/div[2]/div[2]/div[1]/h5/text()') %>%
    html_text()

review_detail <- url_xbox_store %>%
    html_nodes(xpath = '//*[@class="srv_reviews"]/div[2]/div[2]/div[1]/div[1]/p[1]') %>%
    html_text() %>%
    str_replace_all("[\r\n]" , "")

review_helpful <- url_xbox_store %>%
    html_nodes(xpath = '//*[@class="srv_reviews"]/div[2]/div[2]/div[2]/p') %>%
    html_text() 




x <- url_xbox_store %>%
    html_nodes(xpath = '//*[@class="srv_reviews"]/')











 
