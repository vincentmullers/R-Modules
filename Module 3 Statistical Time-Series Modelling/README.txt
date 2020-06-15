I think that's enough data cleaning for now.. time to get started with some Data Science.

Since we'll mainly be dealing with time-series data, let's focus on that. 

There's varying ways to deal with time-series forecasting. There's the more Conventional way and then there's the Machine Learning way. 

The different ways, algorithms, techniques, etc all have their strengths and weaknesses. There's no "one size fits all" (or at least not yet - fortunately enough for the Data Scientist) and what we eventually end up doing is make a judgment of which model fits our data best, or picking a model based on performance. Some models are less sensible to outliers, while others are able to learn more complicated patterns or offer more stable estimates. 

Deep learning methods nowadays often outperform convential frameworks for classification tasks. For time-series this remains the question, as data is often far more limited and to learn deep patterns, we require a lot of data. Moreover, time-series include complexities that classification data sets do not suffer from, like seasonality, trend, (ir)relevance of older data points, difficulties in stripping outliers / cross-validation (on what period can we test the model?), need to retrain after each data point, dealing with missing data points or forecasts going outside of logical bounds (like 0). 

In this module we'll be looking at parametric models. These models have a fixed number of parameters that are calibrated (optimized) assuming certain distributional properties of the data (e.g. data is normally distributed). Practically, this means the structure of the model is fixed, and we just need to optimize the parameters in the model. Therefore, all you need to know for predicting the future is the model's parameters. Think about a linear regression model: 

Y = a + bX is a parametric model with parameters "a" and "b". 

A parametric model therefore makes some assumptions about the data. Given that we do not have a lot of data that will train the model the exact structure of the data, we may need this structure imposed on the data. 

This module starts exploring some of these models and will also teach some of the ways to evaluate performance. Please first follow the tutorial.R before moving out on to practice.R.

In the next module, we'll be looking at non-parametric models. 

Good luck! 