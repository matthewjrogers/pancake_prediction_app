
# slow html reading -------------------------------------------------------

read_slowly <- function(x, ...){
  output <- read_html(x)
  Sys.sleep(4)
  return(output)
}


# safe html reading -- returns NA if function fails -----------------------

read_safely <- possibly(read_slowly, NA)

