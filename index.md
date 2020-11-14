## Probably pancakes?

In our recipe book, my wife and I have a recipe labeled “probably pancakes”. My wife transcribed the recipe at some point in college, sans label, and eventually it acquired its probabilistic identification. I suppose some people would be satisfied that since the recipe yields fluffy, flat cakes that go really well with maple syrup it is, in fact, a pancake recipe.

I am not one of those people. About a year ago, I realized that it was probably possible to predict whether or not a recipe was for pancakes based solely on the quantities, types, and proportions of ingredients in the recipe. 

### This spawned a two part project.

First, I needed to [collect some data](https://github.com/matthewjrogers/Pancake_ID), so in 2018 I wrote some scripts to scrape recipes from allrecipes.com. These included all recipes listed in the "pancakes" and "bread" categories. The "bread" category actually contained a variety of recipes, making it a useful and convenient comparison category. 

I then trained a basic random forest to classify these recipes as either pancakes or not pancakes. Combined with SMOTE to balance the data, this yielded an F1 score  over .90 on unseen validation data.




