custom_value_boxUI <- funtion(id){
  ns <- NS(id)
  fluidRow(
    uiOutput(ns("value_box"))
  )
}