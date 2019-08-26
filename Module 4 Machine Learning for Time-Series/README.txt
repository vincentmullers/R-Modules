In the last module, we learned that parametric models have a fixed number of parameters and therefore a fixed structure. 

A non parametric model has an indefinite number of parameters, and depending on the data, some may be present while others may not be. Under the non-parametric approach, we do not need to assume the 'shape' of the data, and are therefore more likely to learn its true shape. 

Where a parametric model captures all its information about the data in its set parameters, a non-parametric model can capture more subtle aspects of the data. It has the freedom to change the model structure to better fit the data. 

It may sound that non-parametric are much better. Mind however that this depends on the noise in the data. A good example of when parametric models perform well vs when you'd prefer a non-parametric model:

"
Imagine you need to approximate a circle given as a point cloud, a lot of points roughly lying near the circle.

Parametric model would be a closed curve made up of some fixed number of straight lines. If N=4 your parametric model is a rectangle and your job is to fit this rectangle to the point cloud.

Non-parametric model is when your N is not fixed, so you can add more and more sides.

Which one is better to use? This depends on the level of noise. If your point cloud is almost a perfect circle (noise is very small) then non-parametric is better since with each new side approximates a circle better and better. But, if there is a lot of noise then adding sides will only model that noise and you would be better off sticking with 4 sides (rectangle), so parametric model would be better in a noisy case.
"

Let's have a look at some Machine Learning methods to Time-Series!

