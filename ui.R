## app.R ##
library(shiny)
library(shinydashboard)
library(dplyr)

dashboardPage(
  dashboardHeader(title = "UFO Insighting"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("UFO Dashboard", tabName = "dashboard", icon = icon("reddit-alien")),
      menuItem("UFO Sighting by Date", tabName = "ufo_date", icon = icon("calendar-alt")),
      menuItem("UFO Sighting City Mapped", tabName = "ufo_map", icon = icon("globe-americas")),
      menuItem("UFO Sighting by shape", tabName = "ufo_basic", icon = icon("chart-area")),
      menuItem("UFO Sighting by time", tabName = "ufo_time", icon = icon("stopwatch"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              fluidRow(
                box(
                  width = 12,
                  h1("UFO Sighting"),
                  "The National UFO Research Center (NUFORC) collects and serves over 100,000 reports of UFO sightings.
                  This dataset contains the report content itself including the time, location duration, and other attributes in both the raw form as it is recorded on the NUFORC site as well as a refined, standardized form that also contains lat/lon coordinates."
                )
              ),
              fluidRow(
                infoBox("UFO Sightings", 10 * 2, icon = icon("reddit-alien"), fill = TRUE, color = "green"),
                infoBox("UFO Sighting Shapes", 10 * 2, icon = icon("vector-square"), fill = TRUE),
                infoBox("UFO Sighting Cities", 10 * 2, icon = icon("city"), fill = TRUE, color = "yellow")
              ),
              fluidRow(
                
              )
      ),
      tabItem(tabName = "ufo_date",
              fluidRow(
                box(status = "primary", 
                    title = "Filtros",
                    solidHeader = TRUE,
                    
                    dateRangeInput("ufo_date_range", "Rango de fechas"),
                    radioButtons("ufo_date_period", label ="Período", choices = list("Año" = 1,
                                                                              "Mes" = 2,
                                                                              "Día" = 3)),
                    helpText("Nota: Se mostrará una gráfica con los conteos de UFO Sightings
                             (abistamiento de OVNIS) en el rango de fechas seleccionado agrupado por el período."),
                    actionButton("ufo_date_btn", "Ver UFO Sightings", icon = icon("space-shuttle"))
                ),
                box(
                  title = "Output",
                )
              )
      ),
      tabItem(tabName = "ufo_map",
              fluidRow(
                box(status = "primary", 
                    title = "Filtros",
                    solidHeader = TRUE,
                    
                    selectInput("ufo_map_shape", "Shape", choices = list("Cube" = 1,
                                                                                     "Circle" = 2,
                                                                                     "Light" = 3)),
                    helpText("Nota: Se mostrará una mapa de los USA indicando los conteos de UFO Sightings
                             (abistamiento de OVNIS) que han sucedido en los estados correspondientes."),
                    actionButton("ufo_date_btn", "Ver UFO Sightings", icon = icon("space-shuttle"))
                ),
                box(
                  title = "Output",
                )
              )
      ),
      tabItem(tabName = "ufo_basic",
              fluidRow(
                      box(status = "primary", 
                          title = "Filtros",
                          solidHeader = TRUE,
                          selectInput("select_shape", "Shape:",
                                      c("sphere"="sphere",
                                        "unknown"="unknown",
                                        "flash"="flash",
                                        "light"="light",
                                        "oval"="oval",
                                        "changing"="changing",
                                        "disk"="disk",
                                        "fireball"="fireball",
                                        "circle"="circle",
                                        "triangle"="triangle",
                                        "rectangle"="rectangle",
                                        "formation"="formation",
                                        "other"="other",
                                        "cigar"="cigar",
                                        "diamond"="diamond",
                                        "egg"="egg",
                                        "chevron"="chevron",
                                        "teardrop"="teardrop",
                                        "-"="-",
                                        "cylinder"="cylinder",
                                        "cone"="cone",
                                        "cross"="cross"), 
                                      multiple = TRUE), 
                          uiOutput("ui_select_state")
                          , textOutput("result")
                      ),
                      box(title = "Output",
                          plotOutput("ufo_shape_plot"),
                          plotOutput("ufo_state_plot")
                      )
              )
      ),
      tabItem(tabName = "ufo_time",
              fluidRow(
                      box(status = "primary", 
                           title = "Filtros",
                          solidHeader = TRUE, 
                          div(actionButton("ufo_basic_btn", "Plot UFO Sightings", icon = icon("space-shuttle")), 
                              align = "center")
                      ),
                      box(title = "Output"
                      )
              )
      )
    )
  )
)
