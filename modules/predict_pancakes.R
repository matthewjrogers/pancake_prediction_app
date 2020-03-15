predict_pancakesUI <- function(id){
  ns <- NS(id)
  div() # could not find a way around having a cursory UI for the module
}

predict_pancakes <- function(input, 
                             output, 
                             session, 
                             utility_rvs,
                             processed_input_data,
                             recipe_title = NULL
){
  
  if (processed_input_data$prop_liquid >= .8){ # crepe recipes run 65%-75% hydration -- anything much thinner than that isn't a recipe
    sendSweetAlert(
      session = session,
      title = "That's probably soup",
      text = paste0("The recipe you provided was ", format(processed_input_data$prop_liquid, digits = 3), "% liquid."),
      btn_colors = '#b19cd9',
      type = "error"
    )
  } else {
    if (processed_input_data[, rowSums(.SD)] == 0){ 
      # if none of the important ingredients show up, it's not a pancake, or possibly even a baked good
      # we don't need the model to know that
      utility_rvs$prediction <- 'other'
    } else {
      # apply recipe--center and scale data, remove near-zero-variance variables
      baked_pancakes <- bake(prepped_pancakes, processed_input_data)
      
      # make prediction
      utility_rvs$prediction <- as.character(predict(rf_model, baked_pancakes))
    }
    
    # send an alert--let's user know something happened if they put in two consecutive pancakes/not pancakes
    if(utility_rvs$prediction == 'pancake'){
      sendSweetAlert(
        session = session,
        title = "Pancake!",
        text = ifelse(isTruthy(recipe_title),
                      HTML(paste0("You can relax - ", recipe_title," is probably pancakes")),
                      "You can relax - it's probably pancakes"),
        btn_colors = '#20b2aa',
        type = "success"
      )
    } else {
      sendSweetAlert(
        session = session,
        title = "Something else...",
        text = ifelse(isTruthy(recipe_title),
                      HTML(paste0(recipe_title," does not look like pancakes")),
                      "That doesn't seem to be pancakes"),
        btn_colors = '#b19cd9',
        type = "error"
      )
    }
  }
}