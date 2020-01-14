library(shiny)
library(shinyWidgets)
library(shinydashboard)
library(dplyr)
library(data.table)

R.utils::sourceDirectory("modules")

not_pancake_icons <- c('apple-alt', 'fish', 'lemon')

default_ingredients <- c('flour', 'baking_powder', 'sugar', 'milk', 'egg', 'butter')
default_amounts     <- c(1.5, 3.5, 1, 1.25, 1, 3)
default_units       <- c('cup', 'tsp', 'tbsp', 'cup', 'egg', 'tbsp')

utility_rvs <- reactiveValues(pancake_counter = NULL,
                              input_counter = 7
)

input_values <- reactiveValues()

for(idx in seq(length(default_ingredients))){
  input_values[[paste0('input', idx)]] <- data.table(ingredient = default_ingredients[[idx]],
                                                     amount = default_amounts[[idx]],
                                                     unit = default_units[[idx]]
                                                     )
}


