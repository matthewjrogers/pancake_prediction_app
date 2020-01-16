library(shiny)
library(shinyWidgets)
library(shinydashboard)

library(dplyr)
library(data.table)

library(recipes)
library(caret)
library(ranger)

R.utils::sourceDirectory("modules")
R.utils::sourceDirectory("functions")

# load model objects ------------------------------------------------------
load('model_objects/pancake_recipe.RDS')
load('model_objects/pancake_rf.RDS')

# global values -----------------------------------------------------------

not_pancake_icons <- c('apple-alt', 'fish', 'lemon')

default_ingredients <- c('flour', 'baking_powder', 'sugar', 'milk', 'egg', 'butter')
default_amounts     <- c(1.5, 3.5, 1, 1.25, 1, 3)
default_units       <- c('cup', 'tsp', 'tbsp', 'cup', 'egg', 'tbsp')

# utility tracking object -------------------------------------------------

utility_rvs <- reactiveValues(input_counter = 7,
                              servings = 6,
                              prediction = NULL
                              )

# create input tracking object --------------------------------------------

input_values <- reactiveValues()

# initialize default values
for(idx in seq(length(default_ingredients))){
  input_values[[paste0('input', idx)]] <- data.table(ingredient = default_ingredients[[idx]],
                                                     amount = default_amounts[[idx]],
                                                     unit = default_units[[idx]]
                                                     )
}


