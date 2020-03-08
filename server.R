server <- function(input, output, session){
  
  w <- Waiter$new(
    html = spin_timer(),
    id = 'url_upload_modal',
    color = transparent(.7)
  )
  # NOTE: important to define rvs in server rather than in global, as it is undesirable to share 'ingredient states' between sessions
  # utility tracking object -------------------------------------------------
  
  utility_rvs <- reactiveValues(input_counter = 7,
                                servings = 8,
                                prediction = NULL,
                                np_icon = sample(not_pancake_icons, 1)
  )
  
  # create input tracking reactiveValues --------------------------------------------
  
  for(idx in seq(length(default_ingredients))){
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
  
  # render info section -----------------------------------------------------
  
  output$info <- renderUI(
    tabsetPanel(
      id = 'info_section_tabs',
      tabPanel("Predict",
               value = 'use',
               div(style = 'padding:15px;',
                   strong(HTML("We've all been there. You're cooking happily, when suddenly you're struck by an unpleasant suspicion:")),
                   br(), br(),
                   strong(HTML('Am I making <em>pancakes?</em>')),
                   br(), br(),
                   HTML("Fear no more! This app (probably) has answers!
                        <br><br>To use the app, either enter a recipe in the inputs or click the green upload button on the right to import a recipe from allrecipes.com.
                        <br><br><em>To add more ingredients, click the green plus sign. For help using the app, click the question mark icon.</em>"),
                   br(), br(),
                   actionButton("check_recipe", strong("Am I making pancakes?"), style = "width:100%")
               )
      ),
      tabPanel("Origin",
               value = 'about',
               div(style = 'padding:15px;',
                   strong(HTML("In our recipe book, my wife and I have a recipe labeled “probably pancakes”. My wife transcribed the recipe at some point in college, sans label, and eventually it acquired its probabilistic identification.")),
                   br(), br(),
                   HTML("I suppose some people would be satisfied that since the recipe yields fluffy, flat cakes that go really well with maple syrup it is, in fact, a pancake recipe.

                        I am not one of those people. About a year ago, I realized that it was probably possible to predict whether or not a recipe was for pancakes based solely on the quantities, types, and proportions of ingredients in the recipe."),
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
      )
    )
  )
  # disable prediction if there are 1 or fewer ingredient -------------------
  
  observe({ # prefer shinyjs::toggleState
    if(length(names(input_values)[!sapply(reactiveValuesToList(input_values), is.null)]) > 1){
      enable('check_recipe')
    } else {
      disable('check_recipe')
    }
  })
  
  # render inputs UI ----------------------------------------------------
  # input UI
  output$inputs <- renderUI(
    column(12,
           wellPanel(style = 'background-color:#fcfcfc !important;',
                     div(style = 'padding:15px;',
                         fluidRow(
                           column(6,
                                  align = 'left'
                           ),
                           column(3),
                           column(3,
                                  div(style = 'padding-top:22px;text-align:center;',
                                      div(style = "display:inline-block;",
                                          actionBttn(
                                            inputId = "add_input",
                                            label = NULL,
                                            style = "simple",
                                            icon = icon("plus-square")
                                          ), 
                                          actionBttn(
                                            inputId = 'upload',
                                            label = NULL,
                                            style = 'simple',
                                            icon = icon("file-upload")
                                          ),
                                          actionBttn(
                                            inputId = "help",
                                            label = NULL,
                                            style = "simple",
                                            icon = icon("question-circle")
                                          )
                                      ))
                           )
                         ),
                         hr(),
                         tagList( # call module UI function for all non-null elements
                           lapply(sort(names(input_values)[!sapply(reactiveValuesToList(input_values), is.null)]), function(id){
                             do.call(ingredient_input_UI, list(id))
                           }))
                     )
           )
    )
  )
  
  
  observe({ # callModule for all non-null elements in reactive vales
    lapply(names(input_values)[!sapply(reactiveValuesToList(input_values), is.null)], function(id){
      callModule(ingredient_input, id, input_values, input_id = id)
    })
  })
  
  # NOTE: reactiveValues does not support removing a name once created. Setting a reactiveValue to NULL removes the value, 
  # but retains the item name. This is convenient when you wish to initialize an element as NULL, less so when you want to
  # dynamically alter reactiveValues lists. SOLUTION: set value to null, call only for names of non-null elements
  
  # add input ---------------------------------------------------------------
  
  observeEvent(input$add_input,{
    if(length(names(input_values)[!sapply(reactiveValuesToList(input_values), is.null)]) < 12){ # limit to 12 ingredients
      
      # add empty input
      input_values[[paste0('input', utility_rvs$input_counter)]] <- data.table(ingredient = NA,
                                                                               amount = NA,
                                                                               unit = NA)
      # increment ingredient counter to avoid duplicate IDs
      utility_rvs$input_counter <- utility_rvs$input_counter + 1
      
    } else { # stop the user from adding infinite inputs
      sendSweetAlert(session = session,
                     title = "Too many ingredients!",
                     type = 'error',
                     text = 'The app can only handle 12 ingredients at a time.'
      )
    }
  })
  
  # predict pancakes --------------------------------------------------------
  
  # process inputs to data frame
  
  observeEvent(input$check_recipe, {
    processed_input_data <- isolate(process_recipe_input(reactiveValuesToList(input_values) %>% bind_rows(),
                                                         # input$servings,
                                                         liquids,
                                                         fats,
                                                         all_relevant_vars
    ))
    
    # prediction 
    callModule(predict_pancakes,
               'predict',
               utility_rvs = utility_rvs,
               processed_input_data = processed_input_data
    )
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
  
  # NOTE: Attempted observeEvent({input$a input$b}, {expr}), but reactivity broke
  # repeated code as a matter of expediency, but unhappy about it
  observeEvent(input$check_recipe, {
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
  
  observeEvent(input$check_url, {
    utility_rvs$np_icon <- sample(not_pancake_icons, 1)
    
    # see above note re. modules and observeEvent
    
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
  
  # url import --------------------------------------------------------------
  
  # import from URL popup
  observeEvent(input$upload, {
    showModal(
      modalDialog(
        id = 'url_upload_modal',
        title = strong("Import Recipe From URL"),
        strong("You don't carry your pancake recipe with you?"),
        HTML("<br><br>Enter a link to an <em><b>allrecipes.com</b></em> recipe below to find out if it's pancakes. 
             <br>The predict button will be enabled when you provide a valid URL."),
        hr(),
        textInput('url_upload', label = NULL, width = '100%'),
        footer = tagList(
          disabled(actionButton("check_url", strong("Am I making pancakes?"))),
          modalButton("Cancel")
        ),
        easyClose = TRUE
      )
    )
  })  
  

  observe({ # enable check recipe button if there is text input and that input contains allrecipes.com
    toggleState("check_url", isTruthy(input$url_upload) && str_detect(input$url_upload, "allrecipes.com"))
  })
  
  
  observeEvent(input$check_url, {
    
    disable("check_url") # prevent user from spamming check url button
    
    # I force a 4 second wait between queries--spinner shows user something is happening
    w$show()
    input_recipe <- read_safely(input$url_upload)
    
    if (is.na(input_recipe)){ # if reading the link failed, send an error
      w$hide()
      enable("check_url") # re-enable so user can try again
      
      sendSweetAlert(session = session, type = 'error', 
                     title = "Sorry - that link didn't work", 
                     text = "Please try another!")
      
    } else if (length(html_nodes(input_recipe, ".added")) == 0){ # if provided link isn't a recipe page, throw an error
      w$hide()
      enable("check_url") # re-enable so user can try again
      
      sendSweetAlert(session = session, type = 'error', 
                     title = "That link does not appear to have listed ingredients", 
                     text  = "Please ensure your link goes to a recipe page on allrecipes.com and that you typed the URL correctly")
    } else {
      # process from URL to normalized data frame
      raw_recipe_data <- process_recipe_url(recipe = input_recipe,
                                            fruits = fruits,
                                            nuts = nuts,
                                            veggies = veggies,
                                            spices = spices,
                                            conversion_units = conversion_units
      )
      
      # process from normalized data frame to format suitable for model
      processed_input_data <- process_recipe_input(recipe_table = raw_recipe_data[['recipe_df']],
                                                   # servings = raw_recipe_data[['num_servings']],
                                                   liquids,
                                                   fats,
                                                   all_relevant_vars
      )
      
      recipe_title <- html_nodes(input_recipe, "#recipe-main-content") %>% html_text() # pull recipe title for popup
      
      # hide_spinner()
      w$hide()
      updateTextInput(session = session, 'url_upload', value = "") # reset input value
      removeModal()
      
      callModule(predict_pancakes,
                 'predict',
                 utility_rvs = utility_rvs,
                 processed_input_data = processed_input_data,
                 recipe_title = recipe_title
      )
    }
    
  })
  
  
}

