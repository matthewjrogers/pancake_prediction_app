ingredient_input_UI <- function(id){
  ns <- NS(id)
  
  fluidRow(
    uiOutput(ns('ingredient_inputs'))
  )
}