
ui <- fluidPage(
  title = 'Probably Pancakes',
  shinyjs::useShinyjs(),
  useShinydashboard(),
  tags$head(tags$link(href = "style.css", rel = "stylesheet"),
            tags$style(HTML("@import url('//fonts.googleapis.com/css?family=Montserrat:200,400,700,900');
                            .selected {background-color:#301934 !important;},
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
    column(5,
           div(uiOutput('info')),
           div(id = 'custom-info-box',
               style = "padding: 5px 15px 5px 15px;
                        background-color: #20b2aa;
                        /*border: 2px solid #301934;*/
                        border-radius:15px;
                        font-family: 'Montserrat';
                        background-image: url('large_icon.png');
                        background-origin: content-box;
                        background-repeat: no-repeat;
                        background-size: 25%;
                        background-position: right;
                        width:100%;
                        height:150px;
                        box-shadow: 3px 3px 5px grey;
                        ",
               h3("PANCAKES", style = "color:#ffffff;font-weight: 900; font-size:40px"),
               # br(),
               h5("That's probably pancakes!", style = "color:#ffffff;font-weight: 200; font-size:30px")
               )
           # div(uiOutput('prediction'))
    ), column(7,
              fluidRow(
                uiOutput('inputs')
                )
  )
  )
)