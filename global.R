library(shiny)
library(shinyWidgets)

library(data.table)
library(dplyr)

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

