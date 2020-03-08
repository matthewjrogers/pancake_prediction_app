process_recipe_input <- function(recipe_table, liquids, fats, all_relevant_vars){
  setDT(recipe_table)
  
  # unit conversions to cups--excluding fruit (e.g. apples)--avg large egg volume = 3.25*.0625 or ~ 0.203125
  conversion_tbl = data.table(unit = c('tsp', 'tbsp', 'cup', 'oz', 'egg', 'fruit'),
                              conversion = c(0.0208333, 0.0625, 1, 0.125, 0.203125, 1)
  )
  
  std_amount_tbl <- conversion_tbl[recipe_table[!is.na(ingredient)], on = 'unit']
  
  std_amount_tbl[, std_amount := amount*conversion]
  std_amount_tbl <- std_amount_tbl[, .(std_amount = sum(std_amount, na.rm = TRUE)), ingredient] # aggregate if user selects the same ingredient more than once
  std_amount_tbl[, id := 1]
  std_amount_tbl <- dcast(std_amount_tbl, id ~ ingredient, value.var = 'std_amount')
  std_amount_tbl[, id := NULL]
  
  #calculate total volume of recipe, total liquid, total fat, and proportions of each
  std_amount_tbl[, total_volume := rowSums(.SD, na.rm = TRUE)]
  std_amount_tbl[, total_liquid := rowSums(.SD, na.rm = TRUE), .SDcols = names(std_amount_tbl)[names(std_amount_tbl) %in% liquids]]
  std_amount_tbl[, total_fat:= rowSums(.SD, na.rm = TRUE), .SDcols = names(std_amount_tbl)[names(std_amount_tbl) %in% fats]]
  std_amount_tbl[, total_fat := ifelse(is.na(total_fat), 0, total_fat)] # handle NA for fatless recipes
  std_amount_tbl[, total_liquid := ifelse(is.na(total_liquid), 0, total_liquid)] # shouldn't have liquidless recipes, but the app shouldn't crash as a result
  
  std_amount_tbl[, prop_liquid := total_liquid/total_volume]
  std_amount_tbl[, prop_fat := total_fat/total_volume]
  
  std_amount_tbl[, all_relevant_vars[!all_relevant_vars %in% names(std_amount_tbl)] := 0]
  
  if(any(!names(std_amount_tbl) %in% all_relevant_vars)){ # null out superflous columns --shouldn't apply, but preemptive error handling is cheap in this case
    std_amount_tbl[, names(std_amount_tbl)[!names(std_amount_tbl) %in% all_relevant_vars] := NULL]
  }
  return(std_amount_tbl)
}
