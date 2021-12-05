## app.R ##
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(DT)
library(dplyr)
library(leaflet)

dt <- read.csv("data/ufo-sightings.csv")
states <- unique(dt[,"state"])

dashboardPage(
  dashboardHeader(title = "UFO Insighting"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("UFO Dashboard", tabName = "dashboard", icon = icon("reddit-alien")),
      menuItem("UFO Sighting by Date", tabName = "ufo_date", icon = icon("calendar-alt")),
      menuItem("UFO Sighting by Time", tabName = "ufo_time", icon = icon("stopwatch")),
      menuItem("UFO Sighting State Mapped", tabName = "ufo_map", icon = icon("globe-americas")),
      menuItem("UFO Sighting Basic", tabName = "ufo_basic", icon = icon("chart-area"))
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
      tabItem(tabName = "ufo_time",
              
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
              
      )
    )
  )
)
