process_recipe_input <- function(recipe_table, servings){
  setDT(recipe_table)
  
  if(servings == "Don't Know"){
    num_servings <- sample(6:12, 1)
  } else if (servings == "20 +"){
    num_servings <- 20
  } else {
    num_servings <- as.numeric(servings)
  }
  # unit conversions to cups--excluding eggs and fruit (e.g. apples)
  conversion_tbl = data.table(unit = c('tsp', 'tbsp', 'cup', 'oz', 'egg', 'fruit'),
                              conversion = c(0.0208333, 0.0625, 1, 0.125, 1, 1)
  )
  
  # avg_egg_volume = 3.25*.0625
  liquids <- c('buttermilk', 'fruit_juice', 'milk', 'water', 'yogurt', 'sour_cream', 'other_liquid')
  
  fats <- c('butter', 'oil', 'shortening', 'other_fat')
  
  all_relevant_vars <- c("servings", "baking_powder", "baking_soda", "butter", "eggs", "flour", "fruit", "milk",         
                         "nut", "oil", "salt", "spice", "sugar", "vanilla", "water", "yeast", "total_volume",
                         "total_liquid", "prop_liquid", "total_fat", "prop_fat" )
  
  std_amount_tbl <- conversion_tbl[recipe_table, on = 'unit']
  
  std_amount_tbl[, std_amount := amount*conversion]
  std_amount_tbl = std_amount_tbl[, .(std_amount = sum(std_amount)), ingredient] # aggregate if user selects the same ingredient more than once
  std_amount_tbl[, id := 1]
  std_amount_tbl <- dcast(std_amount_tbl, id ~ ingredient, value.var = 'std_amount')
  std_amount_tbl[, id := NULL]
  
  # standardize by servings
  std_amount_tbl[, 1:ncol(std_amount_tbl) := lapply(.SD, function(c){c/num_servings})]
  
  #calculate total volume of recipe, total liquid, total fat, and proportions of each
  std_amount_tbl[, total_volume := rowSums(.SD)]
  std_amount_tbl[, total_liquid := rowSums(.SD), .SDcols = colnames(std_amount_tbl)[colnames(std_amount_tbl) %in% liquids]]
  std_amount_tbl[, total_fat:= rowSums(.SD), .SDcols = colnames(std_amount_tbl)[colnames(std_amount_tbl) %in% fats]]
  std_amount_tbl[, prop_liquid := total_liquid/total_volume]
  std_amount_tbl[, prop_fat := total_fat/total_volume]
  
  std_amount_tbl[, servings := num_servings]
  
  std_amount_tbl[, all_relevant_vars[!all_relevant_vars %in% colnames(std_amount_tbl)] := 0]
  
  if(any(!colnames(std_amount_tbl) %in% all_relevant_vars)){
    std_amount_tbl[, colnames(std_amount_tbl)[!colnames(std_amount_tbl) %in% all_relevant_vars] := NULL]
  }
  return(std_amount_tbl)
}
