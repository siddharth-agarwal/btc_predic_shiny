# server.R
library(quantmod)
library(ggplot2)
library(Quandl)
library(dplyr)

source("func.r")

toDate <- function(x) as.POSIXct(x,origin="1970-01-01")

z <- read.zoo(file = "sub_total_datset_652015",header=TRUE, sep=",")
sub_total_dataset <- as.xts(z)

no_date_dataset <- sub_total_dataset
x <- Quandl("BCHAIN/MKPRU")
x <- as.xts(read.zoo(x))
colnames(x) <- "MKPRU"

no_date_dataset <- merge(no_date_dataset,x)
no_date_dataset <- na.omit(no_date_dataset)
no_date_dataset <- no_date_dataset[, !(names(no_date_dataset)) %in% "Date"]


colnames(no_date_dataset) <- c("ATRCT","BLCHS","CPTRA","DIFF","ETRVU","HRATE","MKTCP","MIREV","NTRAN","NADDU","TOTBC","TRFEE","TRVOU","TVTVR","MKPRU")

diff_dataset <-  diff(as.matrix(no_date_dataset))
diff_dataset <- data.frame(diff_dataset)

diff_dataset$pricechange <- ifelse(diff_dataset$MKPRU>0,1,0)

rownames(diff_dataset) <- 1:nrow(diff_dataset)

gl_lm <- NULL

currentPrices <- NULL

returnUporDown <- function(inp){
  if (inp==1){
    return("UP")
  } else {
    return("DOWN")
  }
}

shinyServer(
  function(input, output) {
    output$modelAccuracy <- renderText({
      if (input$trainModel){
        train <- train<-sample_frac(diff_dataset, 0.7)
        sid<-as.numeric(rownames(train))
        test<-diff_dataset[-sid,]
        lm <- trainModel(train)
        gl_lm <<- lm
        paste("Prediction accuracy on test data:",testModel(lm,test))
      }
    })
    
    output$predicYday <- renderText({
      if (input$predictFuture){
        diff <- tail(currentPrices,n=3)[3,2] - tail(currentPrices,n=3)[1,2]
        pred <- predictFromYesterday(gl_lm,sub_total_dataset)
        paste("Predicted direction using the difference in factors from yesterday and today: ", returnUporDown(pred), "... Difference in prices", diff, sep=" ")
      }
    })
    
    output$predicCurrent <- renderText({
      if (input$predictFuture){
        diff <- tail(currentPrices,n=3)[3,2] - tail(currentPrices,n=3)[2,2]
        pred <- predictMostRecent(gl_lm)
        paste("Predicted direction using the most recent difference in factors (usually less than 24 hours): ", returnUporDown(pred), "... Difference in prices", diff, sep=" ")
      }
    })
    
    
    output$data <- renderTable({
      if (input$showData){
        data = sub_total_dataset
        head(data)
      }
    })
    
    output$getCurrentPrice <- renderTable({
      if (input$showCurrentPrice){
        curPrice <- read.csv("https://blockchain.info/charts/market-price?format=csv")
        colnames(curPrice) <- c("Date/Time","BTC Price")
        currentPrices <<- tail(curPrice, n=3)
        tail(curPrice, n=3)
      }
    })
    
  })