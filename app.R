# Load packages ----
library(shiny)
library(quantmod)

# Source helpers ----
source("helpers.R")

# User interface ----
ui <- fluidPage(
  titlePanel("stockVis"),

  sidebarLayout(
    sidebarPanel(
      helpText("Select a stock to examine.

        Information will be collected from Yahoo finance."),
      textInput("symb", "Symbol", "SPY"),

      dateRangeInput("dates",
                     "Date range",
                     start = "2013-01-01",
                     end = as.character(Sys.Date())),

      br(),

      checkboxInput("log", "Plot y axis on log scale",
                    value = FALSE),

      checkboxInput("adjust",
                    "Adjust prices for inflation", value = FALSE),
      br(),
      downloadButton("download","Download", icon=icon("download"))
      #downloadLink("download","Download", icon=icon("download"))
    ),

    mainPanel(plotOutput("plot"))
  )
)

# Server logic
server <- function(input, output) {

  dataInput = reactive({
    return(getSymbols(input$symb, src = "yahoo",
               from = input$dates[1],
               to = input$dates[2],
               auto.assign = FALSE))
  })
  
  dataAdjust = reactive({
    if (input$adjust) return(adjust(dataInput()))
    dataInput()
  })

  output$plot = renderPlot({
    chartSeries(dataAdjust(), theme = chartTheme("white"),
                type = "line", log.scale = input$log, TA = NULL)
  })
  
  output$download = downloadHandler(
    #filename = paste0(input$symb,ifelse(input$adjust,'-adj',''),'-', Sys.Date(), '.csv'),
    filename = paste0('data-', Sys.Date(), '.csv'),
    content = function(con) {
      write.csv(dataAdjust(), con)
    }
  )

}

# Run the app
shinyApp(ui, server)
