
ui <- fluidPage(
  title = 'Probably Pancakes',
  shinyjs::useShinyjs(),
  use_waiter(),
  tags$head(tags$link(href = "style.css", rel = "stylesheet"),
            tags$style(HTML("@import url('//fonts.googleapis.com/css?family=Montserrat:200,400,700,900');
                            .selected {background-color:#301934 !important;};"))),
  div(id = "header",
      div(id = "title",
          "Probably Pancakes"
      ),
      div(id = "subsubtitle",
          tags$a(href = "http://www.unconquerablecuriosity.com/", "Matt J. Rogers")
      )
  ),
  fluidRow(
    column(5,
           div(uiOutput('info')),
           uiOutput('prediction_boxes'),
           predict_pancakesUI('predicts')
    ), column(7,
              fluidRow(
                  uiOutput('inputs')
                )
  )
  )
)