ingredient_input <- function(input, 
                             output, 
                             session, 
                             ingredient_rvs,
                             input_id
){
  
  # render inputs -----------------------------------------------------------
  
  output$ingredient_inputs <- renderUI(
    # column(8,
    fluidRow(
      column(3,
             pickerInput(session$ns('ingredient'),
                         label = 'Ingredient',
                         choices = c("Baking Powder" = "baking_powder", 
                                        "Baking Soda" = "baking_soda", 
                                        "Butter" = "butter", 
                                        "Eggs" = "eggs", 
                                        "Flour" = "flour", 
                                        "Fruit" = "fruit", 
                                        "Milk" = "milk",         
                                        "Nuts" = "nut", 
                                        "Oil" = "oil", 
                                        "Salt" = "salt", 
                                        "Spices" = "spice", 
                                        "Sugar" = "sugar", 
                                        "Vanilla" = "vanilla", 
                                        "Water" = "water", 
                                        "Yeast" = "yeast",
                                        "Buttermilk" = 'buttermilk', 
                                        "Fruit Juice" = 'fruit_juice', 
                                        "Yogurt" = 'yogurt', 
                                        "Sour Cream" = 'sour_cream', 
                                        "Other Wet Ingredient" = 'other_liquid',
                                        "Other Dry Ingredient" = 'other_dry',
                                        "Other Fat" = 'other_fat'
                         ),
                         selected = input_values[[input_id]]$ingredient,
                         options = pickerOptions(liveSearch = TRUE)
             )),
      column(3,
             numericInput(session$ns('amount'),
                          'Amount',
                          min = .25,
                          max = 100,
                          value = input_values[[input_id]]$amount,
                          step = .01
             )),
      column(3,
             pickerInput(session$ns('unit'),
                         'Unit',
                         choices = c('tsp', 
                                     'tbsp', 
                                     'cup', 
                                     'oz', 
                                     'egg', 
                                     'fruit'),
                         selected = input_values[[input_id]]$unit
             )),
      column(3,
             br(),
             div(style = "padding-top:5px; align:left",
                 actionButton(session$ns('remove'), 
                              label = NULL, 
                              width = '100%',
                              icon = icon('minus-circle')))
      )
    )
    # )
  )
  
  # delete input ------------------------------------------------------------
  
  observeEvent(input$remove, {
    ingredient_rvs[[input_id]] <- NULL
  })  
  
  # update reactive values --------------------------------------------------
  
  observeEvent(input$ingredient, {
    input_values[[input_id]][, ingredient := input$ingredient]
  })
  
  observeEvent(input$amount, {
    input_values[[input_id]][, amount := input$amount]
  })
  
  observeEvent(input$unit, {
    input_values[[input_id]][, unit := input$unit]
  })
  
}