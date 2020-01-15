ingredient_input <- function(input, 
                             output, 
                             session, 
                             ingredient_rvs,
                             input_id
){
  
  # render inputs -----------------------------------------------------------
  
  output$ingredient_inputs <- renderUI(
    column(8,
           fluidRow(
             column(3,
                    pickerInput(session$ns('ingredient'),
                                'Ingredient',
                                choices = c("baking_powder", 
                                            "baking_soda", 
                                            "butter", "eggs", 
                                            "flour", 
                                            "fruit", 
                                            "milk",         
                                            "nut", 
                                            "oil", 
                                            "salt", 
                                            "spice", 
                                            "sugar", 
                                            "vanilla", 
                                            "water", 
                                            'egg',
                                            "yeast",
                                            'buttermilk', 
                                            'fruit_juice', 
                                            'milk', 
                                            'water', 
                                            'yogurt', 
                                            'sour_cream', 
                                            'other_liquid',
                                            'other_dry'
                                            ),
                                selected = input_values[[input_id]]$ingredient
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
                    div(style = "padding-top:5px; align:left",actionButton(session$ns('remove'), label = NULL, icon = icon('minus-circle')))
             )
           )
    )
  )
  
  # delete input ------------------------------------------------------------
  
  observeEvent(input$remove, {
    cat(file = stderr(), "Remove ", input_id, "\n")
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