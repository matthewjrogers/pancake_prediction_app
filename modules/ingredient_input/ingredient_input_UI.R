ingredient_input_UI <- function(id){
  ns <- NS(id)
  
  fluidRow(
    tags$head(tags$link(href = "style.css", rel = "stylesheet"),
              tags$style(HTML("@import url('//fonts.googleapis.com/css?family=Montserrat:400,700,900');
                              .selected {background-color:#b19cd9 !important;};
                              label.control-label{font-family: 'Montserrat'}
                              ;"))),
    uiOutput(ns('ingredient_inputs'))
  )
}