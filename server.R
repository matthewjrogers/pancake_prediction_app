server <- function(input, output, session){
  
  #### reactive values ---------------------------------------------------------
  # utility tracking object -------------------------------------------------
  
  utility_rvs <- reactiveValues(input_counter = 7,
                                servings = 8,
                                prediction = NULL,
                                np_icon = sample(not_pancake_icons, 1)
  )
  
  # create input tracking object --------------------------------------------
  
  for(idx in seq(length(default_ingredients))){
    # important to define rvs here rather than in global, as it is undesirable to share 'ingredient states' between sessions
    if(exists('input_values')){
      input_values[[paste0('input', idx)]] <- data.table(ingredient = default_ingredients[[idx]],
                                                         amount = default_amounts[[idx]],
                                                         unit = default_units[[idx]]
      )
    } else{
      input_values <<- reactiveValues()
      input_values[[paste0('input', idx)]] <- data.table(ingredient = default_ingredients[[idx]],
                                                         amount = default_amounts[[idx]],
                                                         unit = default_units[[idx]]
      )
    }
  }  
  
  # render input objects ----------------------------------------------------
  # call module UI function for all non-null elements
  output$inputs <- renderUI(
    column(12,
           wellPanel(style = 'background-color:#fcfcfc !important;',
                     div(style = 'padding:15px;',
                         fluidRow(
                           column(6,
                                  align = 'left',
                                  pickerInput('servings',
                                              "Servings",
                                              choices = c(
                                                "Don't Know",
                                                as.character(seq(19)),
                                                "20 +"),
                                              selected = as.character(utility_rvs$servings),
                                              width = '100%'
                                  )
                           ),
                           column(3),
                           column(3,
                                  div(style = 'padding-top:22px;text-align:center;',
                                      div(style = "display:inline-block",
                                          actionBttn(
                                            inputId = "add_input",
                                            label = NULL,
                                            style = "simple",
                                            icon = icon("plus-square")
                                          ), 
                                          actionBttn(
                                            inputId = "help",
                                            label = NULL,
                                            style = "simple",
                                            icon = icon("question-circle")
                                          )))
                           )
                         ),
                         hr(),
                         tagList(lapply(sort(names(input_values)[!sapply(reactiveValuesToList(input_values), is.null)]), function(id){
                           do.call(ingredient_input_UI, list(id))
                         }))
                     )
           )
    )
  )
  
  # callModule for all non-null elements in reactive vales
  observe({
    lapply(names(input_values)[!sapply(reactiveValuesToList(input_values), is.null)], function(id){
      callModule(ingredient_input, id, input_values, input_id = id)
    })
  })
  
  # NB: reactiveValues does not support removing a name once created. Setting a reactiveValue to NULL removes the value, 
  # but retains the item name. This is convenient when you wish to initialize an element as NULL, less so when you want to
  # dynamically alter reactiveValues lists. SOLUTION: set value to null, call only for names of non-null elements
  
  # add input ---------------------------------------------------------------
  
  observeEvent(input$add_input,{
    if(length(names(input_values)[!sapply(reactiveValuesToList(input_values), is.null)]) < 12){
      
      # add empty input
      input_values[[paste0('input', utility_rvs$input_counter)]] <- data.table(ingredient = NA,
                                                                               amount = NA,
                                                                               unit = NA)
      # increment ingredient counter
      utility_rvs$input_counter <- utility_rvs$input_counter + 1
      
    } else {
      sendSweetAlert(session = session,
                     title = "Too many ingredients!",
                     type = 'error',
                     text = 'The app can only handle 12 ingredients at a time.'
      )
    }
  })
  
  # render info section -----------------------------------------------------
  
  output$info <- renderUI(
    tabsetPanel(
      tabPanel("Predict",
               value = 'use',
               div(style = 'padding:15px;',
                   strong(HTML("We've all been there. You're cooking happily, when suddenly you're struck by an unpleasant suspicion:")),
                   br(), br(),
                   strong(HTML('Am I making <em>pancakes?</em>')),
                   br(), br(),
                   HTML("Fear no more! This app (probably) has answers!
                        <br><br>Enter a recipe in the inputs and click the button below to answer the all-important question - am I making pancakes?
                         <br><br><em>To add more ingredients, click the green plus sign. For help using the app, click the question mark icon.</em>"),
                   br(), br(),
                   actionButton("check_recipe", strong("Am I making pancakes?"), style = "width:100%")
               )
      ),
      tabPanel("Origin",
               value = 'about',
               div(style = 'padding:15px;',
                   strong(HTML('This app begins with a recipe on a scrap of paper labeled "probably pancakes."')),
                   br(), br(),
                   HTML("Eventually, I decided it was time to take a definitive stand on the nature of the recipe.
                     Admittedly, the recipe yielded fluffy, flat cakes that <em>looked</em> a lot like pancakes and <em>tasted</em> a lot like pancakes,
                          but trusting my tastebuds yielded much less project than the alternative."),
                   br(), br(),
                   strong('Method'),
                   br(),
                   'In the spring of 2018 I used R to collect recipes from allrecipes.com. I collected a total of 3,200 recipes,
                     roughly 400 pancake recipes and 2,800 others.',
                   br(), br(),
                   paste0('Using this data, I trained a machine learning algorithm to classify recipes as pancakes or not pancakes.
                            For more on the process, visit '),
                   tagList(a(HTML('my blog'), href = 'http://www.unconquerablecuriosity.com/2020/01/17/probably-pancakes/', style = "color:#000000;text-decoration:underline;")),
                   br(),hr(),
                   HTML('Icons made by <a href="https://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a>, 
                        <a href="https://www.flaticon.com/authors/good-ware" title="Good Ware">Good Ware</a>,  
                         <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a>, and 
                         <a href="https://www.flaticon.com/authors/eucalyp" title="Eucalyp">Eucalyp</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>')
               )
      ),
      tabPanel("What Matters",
               value = 'model',
               div(style = 'padding:15px',
                   strong("What makes a pancake a pancake?"),
                   br(), br(),
                   HTML("The most important feature of a pancake recipe, as far as this model is concerned, is the proportion of liquid in the recipe.
                   Batters (i.e. recipes with a high proportion of liquid) with a low proportion of fat and sugar are consistently recognized as pancakes by the model. <br><br>Note that the dataset did not contain information on what
                   constitutes a recipe in the first place, so taking the above rule of thumb to the extreme can yield silly predictions. 
                   For example, if you change the default recipe from 1.25 cups of milk to 1,250 cups of milk, the app will still predict that the recipe is pancakes."),
                   br(), br(),
                   "Another important variable is the number of servings. Pancake recipes tended to have a lower number of servings than other recipes in the data I collected.
                   When 'Don't Know' is selected from the drop down, the app randomly selects a value between 6 and 12 (the range of most common values among recipes I collected).
                   Selecting this option may yield a prediction that changes each time you click the button."
               )
      )
    )
  )
  
  # predict pancakes --------------------------------------------------------
  
  observeEvent(input$check_recipe, {
    # process inputs to data frame
    processed_input_data <- isolate(process_recipe_input(reactiveValuesToList(input_values) %>% bind_rows(),
                                                         input$servings))
    
    # apply recipe--center and scale data, remove near-zero-variance variables
    baked_pancakes <- bake(prepped_pancakes, processed_input_data)
    
    # make prediction
    utility_rvs$prediction <- as.character(predict(rf_model, baked_pancakes))
    
    # send an alert--let's user know something happened if they put in two consecutive pancakes/not pancakes
    if(utility_rvs$prediction == 'pancake'){
      sendSweetAlert(
        session = session,
        title = "Pancake!",
        text = "You can relax - it's probably pancakes",
        btn_colors = '#20b2aa',
        type = "success"
      )
    } else {
      sendSweetAlert(
        session = session,
        title = "Something else...",
        text = "That doesn't seem to be pancakes",
        btn_colors = '#b19cd9',
        type = "error"
      )
    }
  })
  
  # render prediction output
  output$prediction_boxes <- renderUI({
    req(utility_rvs$prediction)
    if(utility_rvs$prediction == 'pancake'){
      custom_value_boxUI('is_pancake')
    } else{
      custom_value_boxUI('other')
    }
  })
  
  callModule(custom_value_box,
             'is_pancake',
             color = '#20b2aa',
             box_title = 'pancakes',
             box_text = "That looks like pancakes!",
             box_icon = 'pancakes.png'
  )
  
  observeEvent(input$check_recipe,{
    utility_rvs$np_icon <- sample(not_pancake_icons, 1)
    
    # calling modules from an observeEvent is not ideal, but cost is low for lightweight modules like this one,
    # and it allows random icon selection (otherwise it will pick randomly once per session)
    
    callModule(custom_value_box,
               'other',
               color = '#b19cd9',
               box_title = 'not pancakes',
               box_text = "That doesn't look like pancakes ",
               box_icon = utility_rvs$np_icon
    )
  })
  
  # faq ---------------------------------------------------------------------
  
  observeEvent(input$help,{
    showModal(
      modalDialog(
        title = strong("Recipe Input FAQs"),
        strong("What if I don't know how many servings my recipe makes?"),
        tags$ul(HTML("<li>That's an option you can select in the drop down menu. The app will randomly select a number of servings
                servings between 6 and 12 (the range of most common values among recipes I collected).
                Note that this may cause the app's prediction for a recipe to change.</li>")),
        strong("My recipe has flour, but it isn't wheat flour - where should I list it?"),
        tags$ul(HTML("<li>For the purposes of the model, it's all the same. Add it as flour</li>")),
        strong('When should I use the unit "Piece of Fruit" listed in the dropdown?'),
        tags$ul(HTML("<li>If your recipe calls for a whole piece of fruit, without specifying volume (e.g. one sliced banana), use 'Piece of Fruit'.
                     If your recipe does specify volume for the fruit (e.g. one cup of sliced banana) use the appropriate volumetric unit.</li>")),
        strong("My ingredient is not listed - what should I do?"),
        tags$ul(HTML("<li>As you might expect, an exhaustive list of ingredient is not possible. However, 
                      it is important for the model to know the total volume of ingredients.<br><br>
                      Categorize your ingredient as wet (e.g. cider, cottage cheese, beer), 
                      dry (e.g. cocoa powder, powdered milk, pork crackling), or fat (e.g. margarine) 
                     and add it under 'Other Wet Ingredient', 'Other Dry Ingredient', or 'Other Fat' respectively.</li>")),
        strong(HTML("Does anyone really put beer or pork in their pancakes?")),
        tags$ul(tagList(a(HTML('<li>Yes</li>'), href = 'https://www.allrecipes.com/recipe/87685/beer-pancakes/'))),
        strong("Why can't I choose grams as my unit of measure?"),
        tags$ul(HTML("<li>Because grams are a measure of weight rather than volume. Volumetric proportions are important in the model at the heart of this app,
                     and the conversion from grams to volume would vary greatly based on the ingredient in question. Rather than make assumptions about the conversion,
                     I leave it to the user to make an accuarate translation into the appropriate units.</li>"))
      )
    )
    
  })
}