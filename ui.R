## app.R ##
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(DT)
library(dplyr)
library(leaflet)

dt <- read.csv("data/ufo-sightings.csv")
# dt <- read.csv("data//ufo-sightings.csv")
states <- unique(dt[,"state"])

dashboardPage(
  dashboardHeader(title = "UFO sighting"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("UFO Dashboard", tabName = "dashboard", icon = icon("reddit-alien")),
      menuItem("UFO Sighting by Date", tabName = "ufo_date", icon = icon("calendar-alt")),
      menuItem("UFO Sighting State Mapped", tabName = "ufo_map", icon = icon("globe-americas")),
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
                infoBoxOutput("ufo_sightings"),
                infoBoxOutput("ufo_sightings_shapes"),
                infoBoxOutput("ufo_sightings_cities")
              ),
              fluidRow(
                box(
                  status = "primary", 
                  title = "Columns to show",
                  solidHeader = TRUE,
                  width = 2,
                  fileInput("ufo_file", "Upload file"),
                  checkboxGroupInput("show_vars", NULL,
                                     choices = names(dt), selected = names(dt))
                ),
                box(
                  width = 10,
                  h1("The UFO Sighting dataset"),
                  DT::dataTableOutput("ufo_dataset")
                )
              )
      ),
      tabItem(tabName = "ufo_date",
              fluidRow(
                box(status = "primary", 
                    title = "Filtros",
                    solidHeader = TRUE,
                    
                    dateRangeInput("ufo_date_range",
                                   "Rango de fechas",
                                   start = "1969-01-08",
                                   end = "2021-05-19",
                                   separator = "-",
                                   startview = "year"),
                    selectInput("ufo_date_period",
                                 label ="Período",
                                 choices = list("Year" = "year",
                                                "Month" = "month",
                                                "Day" = "day")),
                    radioButtons("ufo_date_color","Color de puntos",
                                 choices = list("Azul"="steelblue",
                                                "Gris"="gray",
                                                "Verde"="green",
                                                "Negro"="black")),
                    helpText("Nota: Se mostrará una gráfica con los conteos de UFO Sightings
                             (abistamiento de OVNIS) en el rango de fechas seleccionado agrupado por el período.")
                ),
                box(
                  status = "primary", 
                  solidHeader = TRUE,
                  title = "UFO Insighting by Date",
                  plotOutput("ufo_date_plot")
                )
              ),
              fluidRow(
                box(
                  status = "warning", 
                  solidHeader = TRUE,
                  width = 12,
                  title = "UFO Insighting by Date - Dataset",
                  DT::dataTableOutput("ufo_date_dataset")
                )
              )
      ),
      tabItem(tabName = "ufo_map",
              fluidRow(
                box(status = "primary", 
                    title = "Filtros",
                    solidHeader = TRUE,
                    
                    selectInput("ufo_map_state", "State", choices = states),
                    searchInput(
                      inputId = "ufo_map_shape", label = "Enter your shape",
                      placeholder = "circle...",
                      btnSearch = icon("search"),
                      btnReset = icon("remove")
                    ),
                    verbatimTextOutput("ufo_map_msg"),
                    helpText("Nota: Se mostrará una mapa de los USA indicando los conteos de UFO Sightings
                             (abistamiento de OVNIS) que han sucedido en los estados correspondientes."),
                ),
                box(
                  title = "Output",
                  leafletOutput("ufo_map_draw", height = 500)
                )
              ),
              fluidRow(
                box(
                  status = "warning", 
                  solidHeader = TRUE,
                  width = 12,
                  title = "UFO Insighting by State Mapped - Dataset",
                  DT::dataTableOutput("ufo_map_dataset")
                )
              )
      ),
      tabItem(tabName = "ufo_basic",
              h4("Tip: This tab could be used with one, two or without parameters (shape and state):"),
              helpText("http://localhost:3028/?shape=flash,oval,rectangle"),
              helpText("http://localhost:3028/?shape=flash&state=MA,TX,CA"),
              br(),
              fluidRow(
                      box(status = "primary", 
                          title = "By shape",
                          solidHeader = TRUE,
                          selectInput("select_shape", "Shapes:",
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
                                        " "=" ",
                                        "cylinder"="cylinder",
                                        "cone"="cone",
                                        "cross"="cross"), 
                                      multiple = TRUE), 
                          plotOutput("ufo_shape_plot")
                          #, textOutput("result")
                      ),
                      box(status = "primary", 
                          title = "By state",
                          solidHeader = TRUE,
                          uiOutput("ui_select_state"),
                          plotOutput("ufo_state_plot")
                      )
              )
      ),
      tabItem(tabName = "ufo_time",
              fluidRow(
                      box(status = "primary", 
                          title = "By time",
                          solidHeader = TRUE, 
                          selectInput("select_timeday", "Time of day:",
                                      c("0000 - 0359"="00-04",
                                        "0400 - 0759"="04-08",
                                        "0800 - 1159"="08-12",
                                        "1200 - 1559"="12-16",
                                        "1600 - 2159"="16-20",
                                        "2000 - 2359"="20-24"), 
                                      multiple = TRUE), 
                          div(helpText("* Select your filter value(s) and then click the button below."),
                            actionButton("ufo_time_btn", "Plot UFO Sightings", icon = icon("space-shuttle")), 
                              align = "center")
                      ),
                      box(title = "Output",
                          plotOutput("ufo_daytime_plot")
                      )
              ),
              fluidRow(
                box(
                  status = "warning", 
                  solidHeader = TRUE,
                  width = 12,
                  title = "UFO sightings by time of day - Dataset",
                  DT::dataTableOutput("ufo_daytime_dataset")
                )
                
              )
      )
    )
  )
)
