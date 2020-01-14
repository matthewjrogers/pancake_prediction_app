
ui <- fluidPage(
  title = 'Probably Pancakes',
  shinyjs::useShinyjs(),
  useShinydashboard(),
  tags$head(tags$link(href = "style.css", rel = "stylesheet")),
  div(id = "header",
      div(id = "title",
          "Probably Pancakes"
      ),
      div(id = "subsubtitle",
          "Created by",
          tags$a(href = "http://www.unconquerablecuriosity.com/", "Matt J. Rogers")
      )
  ),
  fluidRow(
    column(3,
           wellPanel(
             radioGroupButtons(
               inputId = "info_toggle",
               label = NULL,
               choices = c("Use the App" = 'use', 
                           "About" = 'about'),
               justified = TRUE
             ),
             br(),
             uiOutput('info')
           ),
           fluidRow(
             column(4,
                    actionButton(
                      inputId = "add_input",
                      label = "Add Input", 
                      icon = icon('plus')
                    )
             ), column(5),
             column(3,
                    align = 'right',
                    actionBttn(
                      inputId = "help",
                      label = NULL,
                      style = "simple", 
                      # color = "primary",
                      icon = icon("question-circle")
                      )
                    
                    )
           )
    ), column(9,
              fluidRow(uiOutput('inputs'))
    )
  ),
  fluidRow(
    div(uiOutput('prediction'))
  )
)