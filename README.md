# btc_predic_shiny

Predicting Bitcoin Price Movements Using a Binomial GLM Model

The idea behind this model is to detect potential mispricings in the Bitcoin market. It is is based on 'Automated Bitcoin Trading via Machine Learning Algorithms, which can be found here (http://cs229.stanford.edu/proj2014/Isaac%20Madan,%20Shaurya%20Saluja,%20Aojia%20Zhao,Automated%20Bitcoin%20Trading%20via%20Machine%20Learning%20Algorithms.pdf). Data is pulled from Quandl.

The model is trained on the daily difference of 16 blockchain-related variables. The output is a binary variable: 1 if the price of Bitcoin has gone up from the previous day, and 0 otherwise.

1. Pull down current price of BTC"
2. Train the model. Sometimes, the model fails to converge (without any errors) so the accuracy on the test data goes down. You should see an accuracy of around 97% when it's converged properly.
3. Predict prices using current data. The data source is only updated by the hour. There are two predictions that are generated. One is using the difference of the previous day's data compared to the most recent data. The other is using the difference of the 2 most recent data points. The table generated in step 1 will give you the times used for both predictions. The first row is yesterday's data, and the next two rows are the most recent data points.
Both of the predictions should be in agreement. If one/both are not, there could be a potential mispricing.
