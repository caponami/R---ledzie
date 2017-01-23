library(shiny)

function(input, output) {
  data <- reactive(
    fish_data %>%
      filter(xmonth == input$month) %>%
      select(id, length))
  output$plot <- renderPlot({
    ggplot(data(),aes(x=id,y=length)) + geom_point(colour = "blue") + geom_smooth(method="auto", se=TRUE,color="white")  + theme_dark() 
  }
  )
}
