custom_value_box <- function(input,
                             output,
                             session,
                             color,
                             box_title,
                             box_text,
                             box_icon
){
  output$value_box <- renderUI(
    div(style = paste0("padding: 8px 15px 8px 15px;
        background-color: ",color,";
        
        border-radius:15px;
        font-family: 'Montserrat';
        background-image: url('",box_icon,"');
        background-origin: content-box;
        background-repeat: no-repeat;
        background-size: 18% !important;
        background-position: right;
        width:100%;
        height:150px;
        box-shadow: 3px 3px 5px grey;
        "),
        h3(toupper(box_title), style = "color:#ffffff;font-weight: 900; font-size:40px"),
        h5(box_text, style = "color:#ffffff;font-weight: 200; font-size:30px")
    )
  )
}