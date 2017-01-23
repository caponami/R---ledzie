
library(shiny)

pageWithSidebar(
  headerPanel(''),
  sidebarPanel(
    selectInput('month',
                label = "Month",
                choices = c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"),
                selected = "1")
  ),
  mainPanel(
    plotOutput('plot')
  )
)
