library(shiny)
library(shinyWidgets)
library(shinyjs)
library(shinycssloaders)
library(waiter) # uses development version of waiter
                # remotes::install_github("JohnCoene/waiter")

library(data.table) # fast data processing and update-by-reference
library(dplyr)      # data manipulation - same family as rvest 
library(purrr)      # for possibly()

library(rvest)   # web data retrieval
library(stringr) # string manipulation
library(stringi) # string manipulation

# machine learning libraries
library(recipes) 
library(caret)
library(ranger)
library(e1071)

R.utils::sourceDirectory("modules")
R.utils::sourceDirectory("functions")

# load model objects ------------------------------------------------------
load('model_objects/pancake_recipe_no_servings.RDS')
load('model_objects/pancake_rf_no_servings.RDS')

# global values -----------------------------------------------------------

# defaults
not_pancake_icons <- paste0(c('banana', 'bread', 'broccoli', 'muffin'), '.png')

default_ingredients <- c('flour', 'baking_powder', 'sugar', 'milk', 'eggs', 'butter')
default_amounts     <- c(1.5, 3.5, 1, 1.25, 1, 3)
default_units       <- c('cup', 'tsp', 'tbsp', 'cup', 'egg', 'tbsp')

# processing inputs
liquids <- c('buttermilk', 'fruit_juice', 'milk', 'water', 'yogurt', 'sour_cream', 'other_liquid') # list of liquid ingredients

fats <- c('butter', 'oil', 'shortening', 'other_fat') # list of fats

all_relevant_vars <- c("baking_powder", "baking_soda", "butter", "egg", "flour", "fruit", "milk", # list of variables the model cares about     
                       "nut", "oil", "salt", "spice", "sugar", "vanilla", "water", "yeast", "total_volume",
                       "total_liquid", "prop_liquid", "total_fat", "prop_fat" )


# url processing regex
fruits <- c("\\w*apple", "\\w*berr(y|ies)", "raisin", "lemon", "banana",
            "orange", "pear", "peach", "rhubarb", "plum", "cherry", "fruit", "lime", "mango", "currant", "cherr(y|ies)")
nuts <- c("\\w*nut", "almond", "pecan", "seed")
veggies <- c("carrot", "pumpkin", "potato", "zucchini", "\\bcorn\\b", "\\byam")
spices <- c("cinnamon", "nutmeg", "clove", "ginger", "spice", "cardamom", "pepper")
conversion_units <- c("tablespoon", "teaspoon", "cup", "ounce", "pint", "pinch")