library(shiny)


server <- function(input, output) {
  output$plotRfmTransactions <- renderPlotly({
    plot_ly(x = rfm_data$recency,
            y = rfm_data$frequency,
            z = rfm_data$monetary,
            type = "scatter3d",
            mode = "markers",
            color = rfm_data$segment,
            hoverinfo = "text",
            text = ~paste("Customer ID:", rfm_data$customer_id, "<br>",
                          "Recency:", rfm_data$recency, "<br>",
                          "Frequency:", rfm_data$frequency, "<br>",
                          "Monetary:", rfm_data$monetary),
            marker = list(size = 5)) %>% 
      layout(
        scene = list(
          xaxis = list(title = "Recency(days)"),
          yaxis = list(title = "Frequency(days)"),
          zaxis = list(title = "Monetary($)")
        ),
        title = "Model RFM"
      )
  })
  
  # ############# The server part of Wuyuan START
  output$plotPriceSales <- renderPlot({
    filtered_data = product_us %>%
      filter(profit >= input$profitSlider[1] & profit <= input$profitSlider[2]) %>%
      filter(category %in% input$categoryCheckbox) %>%
      filter(sub_category %in% input$subCategoryCheckbox)
    
    ggplot(filtered_data, aes(x = unit_price, y = quantity)) +
      geom_point(color = "salmon") +
      labs(title = "The relation between the sales and the price (US)",
           x = "product_unit_price ($)",
           y = "sales (pcs)") +
      theme_minimal() +
      scale_x_continuous(breaks = seq(0, 3500, by = 200)) #Modify the x-axis scale range and interval, to make it easier to read.
  })
  
  output$plotPriceProfit <- renderPlot({
    filtered_us <- product_us %>%
      filter(quantity >= input$salesSliderUS[1] & quantity <= input$salesSliderUS[2])  %>%
      filter(category %in% input$categoryCheckboxUS)
    
    filtered_mya <- product_mya %>%
      filter(quantity >= input$salesSliderMYA[1] & quantity <= input$salesSliderMYA[2]) %>%
      filter(category %in% input$categoryCheckboxMYA)  
    
    ggplot()+
      geom_point(data = filtered_us, aes(x = unit_price, y = profit, color = 'US'))+
      geom_point(data = filtered_mya, aes(x = unit_price, y = profit, color = 'MYA'))+
      labs(title = "The distribution of the unit_price and the profit in 2 countries (US and MYA)",
           x = "product_unit_price",
           y = "profit") +
      geom_smooth(data = product_us, aes(x = unit_price, y = profit), method = "lm", se = FALSE, color = "skyblue") +
      geom_smooth(data = product_mya, aes(x = unit_price, y = profit), method = "lm", se = FALSE, color = "salmon") +
      theme_minimal() +
      xlim(0, 300) +  # limit the range of x
      ylim(-250, 250) 
  })
  
  # ############# The server part of Wuyuan END
  
  # ############# The new server part added by czy START
  filtered_data <- reactive({
    data_usa %>% 
      filter(`Sub-Category` %in% input$categoryFilter)
  })
  
  output$plotAvgTransactions <- renderPlotly({
    plot_data <- filtered_data() %>%
      group_by(`Sub-Category`) %>%
      summarise(Average_Transaction_Amount = mean(Sales, na.rm = TRUE)) %>%
      arrange(desc(Average_Transaction_Amount))
    
    p <- ggplot(plot_data, aes(x = reorder(`Sub-Category`, -Average_Transaction_Amount), y = Average_Transaction_Amount)) +
      geom_bar(stat = "identity", fill = "blue") +
      labs(title = "Average Transaction Amount by Sub-Category", x = "Sub-Category", y = "Average Transaction Amount (USD)") +
      theme(axis.text.x = element_text(angle = 65, vjust = 0.6))
    
    ggplotly(p)
  })
  # ############# The server part added by czy END
  
  ##################### The server part added by dyf START
  filtered_data <- reactive({
    if (input$year == "All") {
      data_usa
    } else {
      data_usa %>% filter(Year == input$year)
    }
  })
  
  output$customer_count_plot <- renderPlot({
    city_count <- filtered_data() %>%
      group_by(City) %>%
      summarise(CustomerCount = n_distinct(`Customer ID`)) %>%
      arrange(desc(CustomerCount)) %>%
      head(input$num_cities)
    
    ggplot(city_count, aes(x = reorder(City, CustomerCount), y = CustomerCount)) +
      geom_bar(stat = "identity", fill = "salmon") +
      coord_flip() +
      labs(title = "Number of Customers by City", x = "City", y = "Number of Customers")
  })
  
  output$avg_spending_plot <- renderPlot({
    avg_spending <- filtered_data() %>%
      group_by(City) %>%
      summarise(AvgSpending = mean(Sales)) %>%
      arrange(desc(AvgSpending)) %>%
      head(input$num_cities)
    
    ggplot(avg_spending, aes(x = reorder(City, AvgSpending), y = AvgSpending)) +
      geom_bar(stat = "identity", fill = "skyblue") +
      coord_flip() +
      labs(title = "Average Customer Spending by City", x = "City", y = "Average Spending")
  })
  ##################### The server part added by dyf end
} 

