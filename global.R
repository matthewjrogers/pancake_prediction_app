library(shiny)
library(shinyWidgets)
library(shinyjs)
library(shinycssloaders)
# library(shinybusy)
library(waiter) # uses development version of waiter
                # remotes::install_github("JohnCoene/waiter")

library(data.table) # fast data processing and update-by-reference
library(dplyr)      # data manipulation - same family as rvest 
library(purrr)      # for possibly()

library(rvest)   # web data retrieval
library(stringr) # string manipulation
library(stringi) # string manipulation

library(recipes) 
library(caret)
library(ranger)
library(e1071)

R.utils::sourceDirectory("modules")
R.utils::sourceDirectory("functions")

# load model objects ------------------------------------------------------
load('model_objects/pancake_recipe.RDS')
load('model_objects/pancake_rf.RDS')

# global values -----------------------------------------------------------

not_pancake_icons <- paste0(c('banana', 'bread', 'broccoli', 'muffin'), '.png')

default_ingredients <- c('flour', 'baking_powder', 'sugar', 'milk', 'eggs', 'butter')
default_amounts     <- c(1.5, 3.5, 1, 1.25, 1, 3)
default_units       <- c('cup', 'tsp', 'tbsp', 'cup', 'egg', 'tbsp')

# url processing regex
fruits <- c("\\w*apple", "\\w*berr(y|ies)", "raisin", "lemon", "banana",
            "orange", "pear", "peach", "rhubarb", "plum", "cherry", "fruit", "lime", "mango", "currant", "cherr(y|ies)")
nuts <- c("\\w*nut", "almond", "pecan", "seed")
veggies <- c("carrot", "pumpkin", "potato", "zucchini", "\\bcorn\\b", "\\byam")
spices <- c("cinnamon", "nutmeg", "clove", "ginger", "spice", "cardamom", "pepper")
conversion_units <- c("tablespoon", "teaspoon", "cup", "ounce", "pint", "pinch")