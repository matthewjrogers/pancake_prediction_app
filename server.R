server <- function(input, output, session){
  
  
  # render input objects ----------------------------------------------------
  # call module UI function for all non-null elements
  output$inputs <- renderUI(
    column(9,
           tagList(lapply(sort(names(input_values)[!sapply(reactiveValuesToList(input_values), is.null)]), function(id){
             do.call(ingredient_input_UI, list(id))
           }))
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
      
      input_values[[paste0('input', utility_rvs$input_counter)]] <- data.table(ingredient = NA,
                                                                               amount = NA,
                                                                               unit = NA)
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
    if(input$info_toggle == 'use'){
      div(
        strong(HTML("We've all been there. You're cooking happily, when suddenly you're struck by an unpleasant suspicion:")),
        br(), br(),
        strong(HTML('Am I making <em>pancakes?</em>')),
        br(), br(),
        HTML("Fear no more! This app (probably) has answers!
           <br>Enter a recipe in the inputs and click the button below to answer the all-important question - am I making pancakes? 
            <br><br><em>For help using the app, click the question mark icon below</em>"),
        br(), br(),
        actionButton("check_recipe", strong("Am I making pancakes?"), style = "width:100%")
      )
    } else {
      div(
        strong(HTML('This app begins with a recipe on a scrap of paper labeled "probably pancakes."')),
        br(), br(),
        HTML("Eventually, I decided it was time to take a definitive stand on the nature of the recipe. 
        Admittedly, the recipe yielded fluffy, flat cakes that <em>looked</em> a lot like pancakes and <em>tasted</em> a lot like pancakes, 
             but trusting my tastebuds yielded much less project than the alternative."),
        br(), br(),
        strong('Method'),
        br(),
        'In the spring of 2018 I wrote a web-scraping program to collect recipes from allrecipes.com. I collected a total of 3,200 recipes, 
        roughly 400 pancake recipes and 2,800 others.',
        br(), br(),
        paste0('Using this data, I trained a machine learning algorithm to classify recipes as pancakes or not pancakes. 
               For more on the process, visit '),
        tagList(a(HTML('my blog'), href = 'unconquerablecuriosity.com', style = "color:#000000;text-decoration:underline;"))
      )
    }
  )
  
  # predict pancakes --------------------------------------------------------
  
  observeEvent(input$check_recipe, {
    set.seed(123)
    # process data
    processed_input_data <- isolate(process_recipe_input(reactiveValuesToList(input_values) %>% bind_rows(),
                                                         input$servings))
    
    baked_pancakes <- bake(prepped_pancakes, processed_input_data)
    utility_rvs$prediction <- as.character(predict(rf_model, baked_pancakes))
    
  })
  
  output$prediction <- renderUI({
    req(utility_rvs$prediction)
    if(utility_rvs$prediction == 'pancake'){
      valueBox('Pancakes', "That's (probably) a pancake!", icon = icon('cookie'), color = 'aqua', width = 7)
    } else{
      ic <- sample(not_pancake_icons, 1)
      valueBox('Not Pancakes', "That's (probably) not pancakes", icon = icon(ic), color = 'maroon', width = 7)
    }
  })
  
  
  
  # faq ---------------------------------------------------------------------
  
  observeEvent(input$help,{
    showModal(
      modalDialog(
        title = strong("Recipe Input FAQs"),
        strong("My recipe has flour, but it isn't wheat flour - where should I list it?"),
        tags$ul("For the purposes of the model, it's all the same. Add it as flour"),
        strong("My ingredient is not listed - what should I do?"),
        tags$ul(HTML("As you might expect, an exhaustive list of ingredient is not possible. However, 
          it is important for the model to know the total volume of ingredients.<br>
           Categorize your ingredient as wet (e.g. cider, cottage cheese, beer) 
                     or dry (e.g. cocoa powder, powdered milk, pork crackling), 
                     and add it under 'Other Wet' or 'Other Dry' ingredients respectively.")),
        strong(HTML("Does anyone really put beer or pork in their pancakes?")),
        tags$ul(tagList(a(HTML('Yes'), href = 'https://www.allrecipes.com/recipe/87685/beer-pancakes/')))
      )
    )
    
  })
}