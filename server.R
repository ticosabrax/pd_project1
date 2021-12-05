
ufo_dataset = read.csv("ufo-sightings.csv", header = TRUE)

shinyServer(function(input, output, session) {
  
  
  # Same as above, but with fill=TRUE
  output$progressBox2 <- renderInfoBox({
    infoBox(
      "Progress", paste0(25 + input$count, "%"), icon = icon("list"),
      color = "purple", fill = TRUE
    )
  })
  output$approvalBox2 <- renderInfoBox({
    infoBox(
      "Approval", "80%", icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow", fill = TRUE
    )
  })
  
  observe({
    shapes <- input$select_shape
    
  })
  output$ufo_shape_plot <- renderPlot({
    if (!is.null(input$select_shape)) {
      selected_shapes <- ufo_dataset %>% 
                          filter(shape %in% input$select_shape) %>% 
                          count(shape)
      barplot(selected_shapes$n, names.arg=selected_shapes$shape, 
              col="lightgreen", border="white", las=2,
              xlab="Shapes", ylab="Quantity", main="Count shapes")
    }
  })
  output$ui_select_state<-renderUI({
    all_states <- ufo_dataset %>% 
                  count(state)
    selectInput("select_state", "States:", choices=all_states$state, multiple=TRUE)
  })  
  output$ufo_state_plot <- renderPlot({
    if (!is.null(input$select_state)) {
      sel_states <- ufo_dataset %>% 
        filter(state %in% input$select_state) %>% 
        count(state)
      barplot(sel_states$n, names.arg=sel_states$state, 
              col="lightgreen", border="white", las=2,
              xlab="State", ylab="Quantity", main="Count by state")
    }
  })
  
  
  
  output$result <- renderText({
    #paste("You chose", ufo_dataset$city[[2]])
    paste("")#input$select_shape)
  })
  
})
