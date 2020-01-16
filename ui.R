
ui <- fluidPage(
  title = 'Probably Pancakes',
  shinyjs::useShinyjs(),
  useShinydashboard(),
  tags$head(tags$link(href = "style.css", rel = "stylesheet"),
            tags$style(HTML("@import url('//fonts.googleapis.com/css?family=Montserrat:400,700,900');
                            #info{font-family: 'Montserrat'}
                            #header{font-family: 'Montserrat';font-weight:700;},
                            .selected {background-color:#301934 !important;},
                            .nav-tabs{color: #301934}
                            ;"))),
  div(id = "header",
      div(id = "title",
          "Probably Pancakes"
      ),
      div(id = "subsubtitle",
          tags$a(href = "http://www.unconquerablecuriosity.com/", "Matt J. Rogers")
      )
  ),
  fluidRow(
    column(3,
           uiOutput('info'),
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
              # fluidRow(
              #   column(5,
              #          align = 'right',
              #          pickerInput('servings',
              #                      "Servings",
              #                      choices = c(
              #                        "Don't Know",
              #                        as.character(seq(19)),
              #                        "20 +"),
              #                      selected = "6",
              #                      inline = TRUE,
              #                      width = '100%'
              #          )
              #          
              #   )
              # ),
              # fluidRow(
              #   column(5,
              #          align = 'center',
              #          hr()
              #   )
              # ),
              fluidRow(uiOutput('inputs'))
    # )
  )),
  fluidRow(
    div(uiOutput('prediction'))
  )
)