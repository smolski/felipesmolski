# Carga de paquetes ----
library(shiny)
library(quantmod)

# Carga fichero helpers ----
source("helpers.R")

# UI ----
ui <- fluidPage(
  titlePanel("Stock"),

  sidebarLayout(
    sidebarPanel(
      helpText("Selecione uma ação.
               Fonte: Yahoo finance."),

      textInput("siglas", "Siglas", "DIS"),

      dateRangeInput("fechas",
                     "Intervalo de datas",
                     start = "2013-01-01",
                     format = "dd/mm/yyyy",
                     end = as.character(Sys.Date())),

      br(),
      br(),

      checkboxInput("log", "Escala logarítmica",
                    value = FALSE),

      checkboxInput("ajuste",
                    "Ajuste dos dados pela inflação", value = FALSE)
    ),

    mainPanel(plotOutput("plot"))
  )
)

# Server ---

server <- function(input, output) {

  data <- reactive({
    cat("Yahoo Finance \n")
    getSymbols(input$siglas, src = "yahoo",
                       from = input$fechas[1],
                       to = input$fechas[2],
                       auto.assign = FALSE)
  })
    output$plot <- renderPlot({

      dataAjustada = reactive({
        if(input$ajuste) return(data())
        cat("Cálculo de Ajuste \n")
        adjust(data())

      })

    chartSeries(dataAjustada(), theme = chartTheme("black"),
                type = "line", log.scale = input$log, TA = NULL)
  })

}

# Run the app
shinyApp(ui, server)
