library(DT)
library(dplyr)
library(lubridate)
library(ggplot2)
library(leaflet)
library(shinyalert)

ufo_dataset = read.csv("data/ufo-sightings.csv", header = TRUE)
ufo_dataset$hour = hour(as.POSIXct(
                            gsub("-", "", gsub("T", "", gsub(":", "", ufo_dataset$date_time))), 
                            format="%Y%m%d%H%M")
                    )

options(shiny.maxRequestSize = 30*1024^2)

shinyServer(function(input, output, session) {
  
  fileUpload <- reactive({
    content_file <- input$ufo_file
    if(is.null(content_file)){
      return(NULL)
    }
    return(read.csv(content_file$datapath))
    
  })

  # ------------ UFO Dashboard --------------------
  # Renderizando la table del dataset
  output$ufo_dataset <- DT::renderDataTable({
      dt <- fileUpload()
      dt[, input$show_vars] %>%
      DT::datatable(extensions = 'Buttons',
                    options = list(buttons = c("csv", "pdf"),
                                   dom = 'lfrtipB'),
                    filter = list(position = 'top'),
                    rownames = FALSE)
      return(dt)
  })
  
  # Renderizando las estadísticas generales
  
  output$ufo_sightings <- renderInfoBox({
    dt <- fileUpload()
    infoBox("UFO Sightings", format(nrow(dt), big.mark = ","),"Total", icon = icon("reddit-alien"), fill = TRUE, color = "green")
  })
  
  output$ufo_sightings_shapes <- renderInfoBox({
    dt <- fileUpload()
    if (!is.null(dt)){
      infoBox("UFO Sighting Shapes", nrow(dt %>% distinct(shape)), "Total", icon = icon("vector-square"), fill = TRUE)
    }else{
      infoBox("UFO Sighting Shapes", "NULL", "Total", icon = icon("vector-square"), fill = TRUE)
    }
    
  })
  
  output$ufo_sightings_cities <- renderInfoBox({
    dt <- fileUpload()
    if (!is.null(dt)){
      infoBox("UFO Sighting Cities", format(nrow(fileUpload() %>% distinct(city)), big.mark = ","), "Around all USA", icon = icon("city"), fill = TRUE, color = "yellow")
    }else{
      infoBox("UFO Sighting Cities", "NULL", "Around all USA", icon = icon("city"), fill = TRUE, color = "yellow")
    }
    
  })
  
  # ------------ UFO Sighting by Date --------------------
  
  # Reactive para actualizar dataset según el ufo_date_range
  getDTDate <- reactive({
    dt <- fileUpload()
    if (!is.null(dt)){
      if (input$ufo_date_period == "year"){
        result <- dt %>%
          mutate(date = as.Date(date_time), year = year(date)) %>%
          filter(between(date, as.Date(input$ufo_date_range[1]),as.Date(input$ufo_date_range[2]))) %>%
          group_by(year) %>%
          summarise(n = n())  
      }else if (input$ufo_date_period == "month"){
        result <- dt %>%
          mutate(date = as.Date(date_time), month = month(date)) %>%
          filter(between(date, as.Date(input$ufo_date_range[1]),as.Date(input$ufo_date_range[2]))) %>%
          group_by(month) %>%
          summarise(n = n())
      }else if (input$ufo_date_period == "day"){
        result <- dt %>%
          mutate(date = as.Date(date_time), day = day(date)) %>%
          filter(between(date, as.Date(input$ufo_date_range[1]),as.Date(input$ufo_date_range[2]))) %>%
          group_by(day) %>%
          summarise(n = n())
      }
      return(result)
    }

  })
  
  # Renderizando y creando el plot
  output$ufo_date_plot <- renderPlot({
    dt <- getDTDate()
    
    if (!is.null(dt)){
      if (input$ufo_date_period == "year"){
        p <- ggplot(dt, aes(factor(year), n)) +
          geom_segment( aes(x=factor(year), xend=factor(year), y=0, yend=n), color="grey")
      }else if (input$ufo_date_period == "month"){
        p <- ggplot(dt, aes(factor(month), n)) +
          geom_segment( aes(x=factor(month), xend=factor(month), y=0, yend=n), color="grey")
      }else if (input$ufo_date_period == "day"){
        p <- ggplot(dt, aes(factor(day), n)) +
          geom_segment( aes(x=factor(day), xend=factor(day), y=0, yend=n), color="grey")
      }
      
      p<- p +
        geom_point(shape = 21, colour = input$ufo_date_color, fill = "white", size = 2, stroke = 1) +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
        xlab(input$ufo_date_period) + ylab("Total")
      
      return(p)
    }
    
  })
  
  # Renderizando la table del dataset
   output$ufo_date_dataset <- DT::renderDataTable({
     dt <- getDTDate()
     if (!is.null(dt)){
       dt%>%
         DT::datatable(extensions = 'Buttons',
                       options = list(buttons = c("csv", "pdf"),
                                      dom = 'lfrtipB'),
                       filter = list(position = 'top'),
                       rownames = NULL,
         ) %>%
         formatRound(c("n"), mark = ",",digits = 0)
     }
     
   })
   
   # ------------ UFO Sighting by State mapped --------------------
   
   # Reactive para actualizar dataset según el ufo_map_state y ufo_map_shape
   getMap <- reactive({
     dt <- fileUpload()
     if (!is.null(dt)){
       name_shapes <- dt$shape %>% unique()
       map <- dt %>%
         filter(state == input$ufo_map_state)
       
       if (input$ufo_map_shape != ""){
         if (input$ufo_map_shape %in% name_shapes){
           map <- map %>%
             filter(shape == input$ufo_map_shape)
         }
       }
       
       unique(map[,c("city_latitude","city_longitude")])
       return(map)
     }
     
   })
   
   # Renderizando el mapa
   output$ufo_map_draw <- renderLeaflet({
     
     dt <- fileUpload()
     if (!is.null(dt)){
       name_shapes <- dt$shape %>% unique()
       
       color_shapes <- c('#9e0142','#d53e4f','#f46d43','#fdae61','#fee08b','#ffffbf','#e6f598','#abdda4','#66c2a5','#3288bd','#5e4fa2')
       pal <- colorFactor(color_shapes, domain = name_shapes)
       
       m <- leaflet() %>% addTiles() %>%
         addCircles(data = getMap(), lat = ~city_latitude, lng = ~city_longitude,
                    color = ~pal(shape), label = ~shape, opacity = 1)
       
       m <- m %>% addLegend(data = getMap(), "bottomright", pal = pal,
                            values = ~shape, title = "Shapes",
                            opacity = 0.7)
       
       return(m)
     }
   })
   
   # Renderizando la table del dataset
   output$ufo_map_dataset <- DT::renderDataTable({
     getMap() %>%
       DT::datatable(extensions = 'Buttons',
                     options = list(buttons = c("csv", "pdf"),
                                    dom = 'lfrtipB'),
                     filter = list(position = 'top'),
                     rownames = NULL,
       )
   })



   ### UFO sightings by shape and state ###
   output$ufo_shape_plot <- renderPlot({
     if (!is.null(input$select_shape)) {
       selected_shapes <- ufo_dataset %>% 
                           filter(shape %in% input$select_shape) %>% 
                           count(shape)
       barplot(selected_shapes$n, names.arg=selected_shapes$shape, 
               col="lightgreen", border="white", las=2,
               xlab="Shape", ylab="Quantity", main="Count by shape")
     }
   })

   # output$ui_select_state <- renderUI({
   #   all_states <- ufo_dataset %>% 
   #                  count(state)
   #   selectInput("select_state", "States:", choices=all_states$state, multiple=TRUE)
   # })  
   
   output$ufo_state_plot <- renderPlot({
     if (!is.null(input$select_state)) {
       sel_states <- ufo_dataset %>% 
                     filter(state %in% input$select_state) %>% 
                     count(state)
       barplot(sel_states$n, names.arg=sel_states$state, 
               col="lightgreen", border="darkgreen", las=2,
               xlab="State", ylab="Quantity", main="Count by state")
     }
   })
   
   observe({
     query <- parseQueryString(session$clientData$url_search)
     shapes <- NULL
     if (!is.null(query[["shape"]])) {
       shapes <- unlist(strsplit(query[["shape"]], ","))
     }
     if (!is.null(shapes)) {
       updateSelectInput(session, "select_shape", selected=shapes)
     }
     states <- NULL
     if (!is.null(query[["state"]])) {
       states <- unlist(strsplit(query[["state"]], ","))
     }
     if (!is.null(states)) {
       updateSelectInput(session, "select_state", selected=states)
     }
     if (!is.null(shapes) || !is.null(states)) {
       updateTabsetPanel(session, "main_menu", selected = "ufo_basic")
     }
   })
   
   
   
   ### UFO sightings by day time ###
   do_plot_time <- eventReactive(input$ufo_time_btn, {
     if (!is.null(input$select_timeday)) {
       hours <- c()
       for (item in input$select_timeday) {
         st <- as.integer(strsplit(item, "-")[[1]][1]) #start time
         et <- as.integer(strsplit(item, "-")[[1]][2])-1 #end time
         hours <- append(hours, c(st:et))
       }
       sel_hours <- ufo_dataset %>%
                    filter(hour %in% hours) %>%
                    count(hour)
       par(bg = 'lightblue')
       barplot(sel_hours$n, names.arg=sel_hours$hour,
               col="aquamarine1", border="darkblue", las=2,
               xlab="Hour", ylab="Quantity", main="Count by time of day")
       sel_hours <- ufo_dataset %>%
                     filter(hour %in% hours)
       datatable(sel_hours, 
                 options = list(buttons = c("csv", "pdf"), dom = 'lfrtipB'),
                 filter = list(position = 'top'))
     }
   })
   
   output$ufo_daytime_plot <- renderPlot({
     do_plot_time()
   })
   
   output$ufo_daytime_dataset <- DT::renderDataTable({
     do_plot_time()
   })
   


   # output$result <- renderText({ paste(ufo_dataset$hour[1])
   # })
   
})
