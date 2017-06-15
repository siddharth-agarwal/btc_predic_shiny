getData <- function(){
  test_sub_total_dset <- read.csv("sub_total_datset_652015")
  test_sub_total_dset <- test_sub_total_dset[, !(names(test_sub_total_dset)) %in% "X"]
  return(test_sub_total_dset)
}

trainModel <- function(train){
  
  formula <- "pricechange ~ ATRCT "
  
  codes = c("BCHAIN/BLCHS","BCHAIN/CPTRA","BCHAIN/DIFF","BCHAIN/ETRVU","BCHAIN/HRATE","BCHAIN/MKTCP","BCHAIN/MIREV","BCHAIN/NTRAN","BCHAIN/NADDU","BCHAIN/TOTBC","BCHAIN/TRFEE","BCHAIN/TRVOU","BCHAIN/TVTVR")
  
  for (code in codes){
    formula <- paste(formula, paste("",strsplit(code,"/")[[1]][2],sep=""), sep=" + ")
  }
  
  lm <- glm(formula=formula, data=train, family=binomial)
  return(lm)
  
}

testModel <- function(lm, test){
  predtst <- predict(lm,test,type="response")
  
  rounded_pred <- round(predtst)
  
  count <- 0
  for(i in 1:nrow(test)){
    count <- count + abs((test$pricechange[i] -rounded_pred[[i]]))
  }
  
  print((nrow(test)-count)/nrow(test))
}

predictMostRecent <- function(lm){
  stats <- c("median-confirmation-time","blocks-size","cost-per-transaction","difficulty","estimated-transaction-volume-usd","hash-rate","market-cap","miners-revenue","n-transactions","n-unique-addresses","total-bitcoins","transaction-fees","trade-volume","tx-trade-ratio")
  
  recent_diff <- data.frame(matrix(ncol=14,nrow=1))
  
  i <- 0
  for (stat in stats){
    i <- i + 1
    current_data <- read.csv(paste("https://blockchain.info/charts/",stat,"?format=csv",sep=""))
    recent_diff[1,i] <- (tail(current_data,n=2)[2])[2,] - (tail(current_data,n=2)[2])[1,]
  }
  
  colnames(recent_diff) <- c("ATRCT","BLCHS","CPTRA","DIFF","ETRVU","HRATE","MKTCP","MIREV","NTRAN","NADDU","TOTBC","TRFEE","TRVOU","TVTVR")
  
  return(round(predict(lm,recent_diff,type="response")))
}

predictFromYesterday <- function(lm,sub_total_dataset){
  stats <- c("median-confirmation-time","blocks-size","cost-per-transaction","difficulty","estimated-transaction-volume-usd","hash-rate","market-cap","miners-revenue","n-transactions","n-unique-addresses","total-bitcoins","transaction-fees","trade-volume","tx-trade-ratio")
  
  today <- data.frame(matrix(ncol=14,nrow=1))
  
  i <- 0
  for (stat in stats){
    i <- i + 1
    current_data <- read.csv(paste("https://blockchain.info/charts/",stat,"?format=csv",sep=""))
    today[1,i] <- tail(current_data,n=1)[2]
  }
  
  yday <- sub_total_dataset[as.Date(Sys.Date())-1]
  yday <- yday[, !(names(yday)) %in% "Date"]
  
  today_diff <- today - coredata(yday)
  colnames(today_diff) <- c("ATRCT","BLCHS","CPTRA","DIFF","ETRVU","HRATE","MKTCP","MIREV","NTRAN","NADDU","TOTBC","TRFEE","TRVOU","TVTVR")
  
  return(round(predict(lm,today_diff,type="response")))
}