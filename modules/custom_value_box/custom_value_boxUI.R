custom_value_boxUI <- function(id){
  ns <- NS(id)
  
  fluidRow(
    uiOutput(ns("value_box"))
  )
}