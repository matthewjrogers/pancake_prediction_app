ingredient_input <- function(input, 
                             output, 
                             session, 
                             ingredient_rvs,
                             input_id
){
  

  # render inputs -----------------------------------------------------------
  
  output$ingredient_inputs <- renderUI(
    tagList(
      shinyjs::useShinyjs(),
    fluidRow(
      column(3,
             pickerInput(session$ns('ingredient'),
                         label = 'Ingredient',
                         choices = list(`Usual Suspects` = c("Flour" = "flour",
                                                             "Eggs" = "eggs"),
                                        `Raising Agents` = c("Baking Powder" = "baking_powder", 
                                                             "Baking Soda" = "baking_soda",
                                                             "Yeast" = "yeast"),
                                        Dairy = c("Butter" = "butter", 
                                                  "Buttermilk" = 'buttermilk',
                                                  "Yogurt" = 'yogurt', 
                                                  "Sour Cream" = 'sour_cream', 
                                                  "Milk" = "milk"),
                                        Sweeteners = c("Sugar" = "sugar", 
                                                       "Honey" = 'honey',
                                                       'Agave' = 'agave',
                                                       'Molasses' = 'molasses'
                                        ),
                                        `Non-Dairy Liquids` = c("Water" = "water", 
                                                                "Fruit Juice" = 'fruit_juice'),
                                        `Non-Dairy Fats` = c("Oil" = "oil", 
                                                             'Shortening' = 'shortening'
                                        ),
                                        Flavorings = c("Salt" = "salt", 
                                                       "Spices" = "spice", 
                                                       "Vanilla" = "vanilla"),
                                        Other = c("Oats" = 'oats',
                                                  "Fruit" = "fruit", 
                                                  "Nuts" = "nut",
                                                  'Carrot' = 'vegetable',
                                                  'Zucchini' = 'vegetable',
                                                  'Pumpkin' = 'vegetable'
                                                  ),
                                        `Unlisted Ingredient` = c("Other Wet Ingredient" = 'other_liquid',
                                                                  "Other Dry Ingredient" = 'other_dry',
                                                                  "Other Fat" = 'other_fat')
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
                         choices = c('Teaspoon' = 'tsp', 
                                     'Tablespoon' = 'tbsp', 
                                     'Cup' = 'cup', 
                                     'Ounce' = 'oz', 
                                     "Egg" = 'egg', 
                                     "Piece of Fruit" = 'fruit'),
                         selected = input_values[[input_id]]$unit
             )),
      column(3,
             br(),
             div(style = "padding-top:5px;",
                 actionButton(session$ns('remove'), 
                              label = NULL, 
                              width = '100%',
                              icon = icon('minus-circle')))
      )
    )
    )
  )
  
  # delete input ------------------------------------------------------------
  
  observeEvent(input$remove, {
    ingredient_rvs[[input_id]] <- NULL
  })  
  
  # update reactive values --------------------------------------------------
  
  observeEvent(input$ingredient, {
    if(!is.null(input_values[[input_id]])){
      input_values[[input_id]][, ingredient := input$ingredient]
    }
  })
  
  observeEvent(input$amount, {
    if(!is.null(input_values[[input_id]])){
      input_values[[input_id]][, amount := input$amount]
    }
  })
  
  observeEvent(input$unit, {
    if(!is.null(input_values[[input_id]])){
      input_values[[input_id]][, unit := input$unit]
    }
  })

}