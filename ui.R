
ui <- fluidPage(
  title = 'Probably Pancakes',
  shinyjs::useShinyjs(),
  useShinydashboard(),
  tags$head(tags$link(href = "style.css", rel = "stylesheet"),
            tags$style(HTML("@import url('//fonts.googleapis.com/css?family=Montserrat:400,700,900');
                            #info{font-family: 'Montserrat'}
                            #header{font-family: 'Montserrat';font-weight:700;
                                    background-image: url('large_icon.png');
                                    background-repeat: no-repeat;
                                    background-size: 8% !important;
                                    background-position: right;
                                    background-origin: padding-box;
                                    };
                            .selected {background-color:#301934 !important;},
                            
                            'nav nav-tabs{color:#301934}
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
           uiOutput('info')
    ), column(9,
              fluidRow(
                uiOutput('inputs')
                )
  )
  ),
  fluidRow(
    div(uiOutput('prediction'))
  )
)