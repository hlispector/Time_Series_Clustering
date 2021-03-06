library(Quandl)

#https://github.com/aayushmnit/Data-science-presentation/blob/master/Deep_dive_in_hierarchical_clustering/Time_series_example.pdf

Quandl.api_key("X8fn4LKgpiW3kRNoLAQn")

library(ggplot2)
library(gridExtra)
library(ggdendro)
library(zoo)
library(TSclust)

pg <- Quandl('EOD/PG', start_date="2016-05-01", end_date='2017-05-01', collapse = 'weekly', type='zoo')

apple <- Quandl('EOD/AAPL', start_date="2016-05-01", end_date='2017-05-01', collapse = 'weekly', type='zoo')

visa <- Quandl('EOD/V', start_date="2016-05-01", end_date='2017-05-01', collapse = 'weekly', type='zoo')

uhg <- Quandl('EOD/UNH', start_date="2016-05-01", end_date='2017-05-01', collapse = 'weekly', type='zoo')

cocacola <- Quandl('EOD/KO', start_date="2016-05-01", end_date='2017-05-01', collapse = 'weekly', type='zoo')

goldmansachs <- Quandl('EOD/GS', start_date="2016-05-01", end_date='2017-05-01', collapse = 'weekly', type='zoo')

walmart <- Quandl('EOD/WMT', start_date="2016-05-01", end_date='2017-05-01', collapse = 'weekly', type='zoo')

merk <- Quandl('EOD/MRK', start_date="2016-05-01", end_date='2017-05-01', collapse = 'weekly', type='zoo')

plot(pg)

joined_ts <- cbind(pg[,4], apple[,4], visa[,4], uhg[,4], cocacola[,4], goldmansachs[,4], 
                   walmart[,4], merk[,4])

names(joined_ts) <- c('P&G', 'Apple', 'Visa', 'UHG', 'Cocacola', 'GoldmanSachs', 'Walmart', 
                      'Merk')
plot(joined_ts)

hc <- hclust(dist(t(joined_ts)), "ave")

plot(hc)

colours_hc <-cutree(hc, h=2)

hcdata <- dendro_data(hc)

names_order <- hcdata$labels$label

hcdata$labels$label <- ''

p1 <- ggdendrogram(hcdata, rotate = T, leaf_labels = F)

new_data <- joined_ts[,rev(as.character(names_order))]

p2 <- autoplot(new_data, facets = Series ~ . ) + aes(colour = as.character(rep(colours_hc, each=53)), linetype = NULL) + geom_line(size=1.5) + xlab('') + ylab('') + theme(legend.position = "none")
         

gp1 <- ggplotGrob(p1)

gp2 <- ggplotGrob(p2)

grid.arrange(gp2, gp1, ncol = 2, widths = c(4,2))

maxs <- apply(joined_ts, 2, max)

mins <- apply(joined_ts, 2, min)

joined_ts_scales <- scale(joined_ts, center = mins, scale = maxs - mins)

plot(joined_ts_scales)

hc <- hclust(dist(t(joined_ts_scales)), "ave")

plot(hc)

colours_hc <- cutree(hc, h=2)

hcdata <- dendro_data(hc)

names_order <- hcdata$labels$label

hcdata$labels$label <- ''

p1 <- ggdendrogram(hcdata, rotate = T, leaf_labels = FALSE)

new_data <- joined_ts_scales[, rev(as.character(names_order))]

p2 <- autoplot(new_data, facets = Series ~ .) + aes(colour=as.character(rep(colours_hc, each = 53)), linetyoe = NULL) + geom_line(size = 1.5) + xlab('') + ylab('') + theme(legend.position = "none")

gp1 <- ggplotGrob(p1)

gp2 <- ggplotGrob(p2)

grid.arrange(gp2, gp1, ncol=2, widths=c(4,2))

data <- data.frame(joined_ts)

data_modified <- data

rownames(data_modified) = 1:nrow(data_modified)

data_modified <- (data_modified[2:53,] - data_modified[1:52,])*100/(data_modified[1:52,])
head(data_modified)

hc <- hclust(diss(t(data_modified), "ACF"), "ave")

plot(hc)

colours_hc <- cutree(hc, h=2)

rownames(data_modified) <- rownames(data)[1:52]

data_modified <- as.matrix(data_modified)

class(data_modified[1:53,1])

data_modified <- xts(data_modified,as.POSIXct(rownames(data_modified)))
