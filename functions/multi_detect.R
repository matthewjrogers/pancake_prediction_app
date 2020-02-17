multi_detect <- function(string, pattern){
  map_lgl(string, ~stri_detect_regex(., pattern) %>% any(.))
}
