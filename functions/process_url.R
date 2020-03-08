
process_recipe_url <- function(recipe, fruits, nuts, veggies, spices, conversion_units){
  
  recipe_ingredients <- html_nodes(recipe, ".added") %>% 
    html_text() %>% # coerce from xml to text
    as_tibble()     # to tibble (all processing here in tidyverse for consistency with rvest)
  
  recipe_servings <- recipe %>% 
    html_nodes(".subtext") %>%
    html_text() %>% 
    str_extract("(?<=yields\\s)\\d+") %>% 
    ifelse(identical(., character(0)), NA, .)
  
  
  cleaned_recipe <- recipe_ingredients %>%  
    mutate(value = tolower(value)) %>% 
    mutate(amount = str_extract(.$value, "^[\\d, /]+"),
           units = str_extract(.$value, "(\\(.+\\)|[^0-9, /]+)"), 
           ingredient = case_when(
             str_detect(.$value, "flour") ~ "flour",
             str_detect(.$value, "starch") ~ "starch",
             str_detect(.$value, "corn\\s?meal") ~ "cornmeal",
             str_detect(.$value, "bran") ~ "bran",
             str_detect(.$value, "\\boat") ~ "oats", 
             str_detect(.$value, "wheat germ") ~ "wheat germ",
             str_detect(.$value, "sugar") ~ "sugar",
             str_detect(.$value, "juice") ~ "fruit juice",
             str_detect(.$value, "honey") ~ "honey",
             str_detect(.$value, "agave") ~ "agave",
             str_detect(.$value, "syrup") ~ "syrup",
             str_detect(.$value, "molasses") ~ "molasses",
             str_detect(.$value, "frosting") ~ "frosting",
             str_detect(.$value, "buttermilk") ~ "buttermilk", 
             str_detect(.$value, "milk") ~ "milk",
             str_detect(.$value, "cream cheese") ~ "cream cheese",
             str_detect(.$value, "sour cream") ~ "sour cream",
             str_detect(.$value, "tartar") ~ "other", 
             str_detect(.$value, "\\bcream\\b") ~ "cream", 
             str_detect(.$value, "yogurt") ~ "yogurt",
             str_detect(.$value, "cheese") ~ "cheese", 
             str_detect(.$value, "baking soda")  ~ "baking soda",
             str_detect(.$value, "baking powder")~ "baking powder",
             str_detect(.$value,  "yeast") ~ "yeast",
             str_detect(.$value, "\\boil\\b") ~ "oil",
             str_detect(.$value, "shortening") ~ "shortening",
             str_detect(.$value, "margarine") ~ "margarine",
             str_detect(.$value, "\\bsalt\\b") ~ "salt", 
             str_detect(.$value, "water") ~ "water",
             str_detect(.$value, "vanilla extract")  ~ "vanilla",
             str_detect(.$value, "chocolate") ~ "chocolate",
             str_detect(.$value, "cocoa") ~ "chocolate",
             str_detect(.$value, "egg") ~ "eggs",
             str_detect(.$value, "vinegar") ~ "vinegar",
             multi_detect(.$value, spices) ~ "spice",
             multi_detect(.$value, nuts) ~ "nut",
             multi_detect(.$value, fruits) ~ "fruit",
             multi_detect(.$value, veggies) ~ "vegetable",
             str_detect(.$value, "butter") ~ "butter",
             TRUE ~ "other"))
  
  
  cleaned_recipe <- cleaned_recipe %>% 
    filter(units != "wet",
           units != "dry",
           !is.na(amount)) %>% 
    mutate(amount = str_trim(amount)) %>% 
    mutate(numeric_qty = str_replace(amount, "\\s", "+")) %>%  # turn number-fraction combos into arithmetic statements--e.g. "2 1/2" to "2+1/2"
    mutate(numeric_qty = sapply(numeric_qty, function(x) eval(parse(text = x)))) # evaluate arithmetic statements
  
  
  
  cleaned_recipe <- cleaned_recipe %>%  # standardize variable units to cups
    mutate(std_amount = case_when(ingredient == "eggs" ~ numeric_qty,
                                  str_detect(units, "cup") ~ numeric_qty,
                                  str_detect(ingredient, "fruit") ~ numeric_qty,
                                  str_detect(units, "pinch") ~ numeric_qty / 768,
                                  str_detect(units, "teaspoon") ~ numeric_qty * 0.0208333,
                                  str_detect(units, "tablespoon") ~ numeric_qty * 0.0625,
                                  str_detect(units, "ounce") ~ numeric_qty * 0.125,
                                  str_detect(units, "pint") ~ numeric_qty * 2)) %>%
    mutate(std_units = case_when(multi_detect(units, conversion_units) ~ "cup",
                                 ingredient == "eggs"                  ~ "egg"))
  
  final_recipe <- cleaned_recipe %>% 
    group_by(ingredient) %>%
    summarise(amount = sum(std_amount), # collapse multiple obs into single value (e.g. white sugar and brown sugar)
              unit = first(std_units)
    ) %>%
    ungroup() %>% 
    mutate(ingredient = str_replace_all(ingredient, "\\s+", "_"))
    
    output_obj <- list(recipe_df = final_recipe,
                       num_servings = ifelse(is.na(recipe_servings),
                                             "Don't Know",
                                             recipe_servings
                       )
    )
  
  return(output_obj)
}