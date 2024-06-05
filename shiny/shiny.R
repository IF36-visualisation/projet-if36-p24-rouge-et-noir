knitr::opts_chunk$set(echo = TRUE)

library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(plotly)
library(readr)

data_usa_path <- "../data/superstore.csv"
data_usa <- read_csv(data_usa_path)

data_mya_path <- "../data/WalmartSQL repository.csv"
data_mya <- read_delim(data_mya_path, delim = ";", escape_double = FALSE, trim_ws = TRUE)

# ###########################################################
get_custom_quarter <- function(date) {
  month <- as.POSIXlt(date)$mon + 1
  if (month %in% 1:3) {
    return("Q1")
  } else if (month %in% 4:6) {
    return("Q2")
  } else if (month %in% 7:9) {
    return("Q3")
  } else if (month %in% 10:12) {
    return("Q4")
  } else {
    return("Unknown")
  }
}
get_custom_week <- function(date) {
  week_of_year <- strftime(date, format = "%U")
  return(week_of_year)
}

client_usa <- data_usa %>%
  select(`Customer ID`, `Order Date`, `Order ID`, Sales, Quantity) %>%
  group_by(`Customer ID`, `Order Date`, `Order ID`) %>%
  summarise(quantity = sum(Quantity, na.rm = TRUE),
            total = sum(Sales, na.rm = TRUE)) %>%
  ungroup() %>%
  transmute(customer_id = `Customer ID`,
            order_id = `Order ID`,
            order_date = as.Date(`Order Date`, format = "%d-%m-%y"),
            quantity = quantity,
            total = total)

client_usa$quarter <- sapply(client_usa$order_date, get_custom_quarter)

client_usa$week <- sapply(client_usa$order_date, get_custom_week)

client_mya <- data_mya %>%
  select(quantity, total, dtme, invoice_id) %>%
  transmute(order_id = invoice_id,
            order_date = dtme,
            quantity = quantity,
            total = total)

client_mya$quarter <- sapply(client_mya$order_date, get_custom_quarter)

client_mya$week <- sapply(client_mya$order_date, get_custom_week)

client_mya_total_quantity <- client_mya %>%
  select(total = total,
         quantity = quantity)
client_usa_total_quantity <- client_usa %>%
  select(total = total,
         quantity = quantity)

max_date <- max(client_usa$order_date)

rfm_data <- client_usa %>%
  group_by(customer_id) %>%
  summarise(
    total_days = as.numeric(difftime(max(order_date), min(order_date), units = "days")),
    recency = as.numeric(min(difftime(max_date, order_date, units = "days"), na.rm = TRUE)),
    frequency = n(),
    monetary = sum(total, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  filter(recency < 547 & total_days < 547)

rfm_data <- rfm_data %>%
  mutate(
    r_score = ntile(recency, 2),
    f_score = ntile(frequency, 2),
    m_score = ntile(monetary, 2)
  )

rfm_data <- rfm_data %>%
  mutate(
    segment = paste0("R", r_score, "F", f_score, "M", m_score)
  )

rfm_to_customer_segment <- function(rfm_label) {
  segment_map <- c(
    "R1F1M1" = "New Customers",
    "R1F1M2" = "Important Deepening Customers", 
    "R1F2M1" = "Potential customers",
    "R1F2M2" = "Important Value Customers",
    "R2F1M1" = "Churned Customers",
    "R2F1M2" = "Important Retention Customers",
    "R2F2M1" = "Average Maintenance Customers",
    "R2F2M2" = "Important Win-Back Customers"
  )
  
  customer_segment <- segment_map[rfm_label]
  
  return(customer_segment)
}

rfm_data$segment <- rfm_to_customer_segment(rfm_data$segment)


# ############# The data cleaning part of Wuyuan START

product_us = data_usa %>%
  select(`Product ID`, Category, `Sub-Category`, Sales, Quantity, Profit) %>% #choose the concerned fields
  group_by(Category, `Sub-Category`, `Product ID`,Profit) %>% #group all the lines by the 3 fields
  summarise(quantity = sum(Quantity, na.rm = TRUE),
            total = sum(Sales, na.rm = TRUE),
            profit = sum(Profit, na.rm = TRUE),
            unit_price = total / quantity) %>% #delete the null cell and calculate the unit_price of a product, the sales and the total income
  ungroup() %>%
  transmute(product_id = `Product ID`,
            category = `Category`,
            sub_category = `Sub-Category`,
            unit_price = unit_price,
            quantity = quantity,
            total = total,
            profit = Profit) #form a new table and use it later
#include the profit, and then compare it with the profit in the table mya



product_mya = data_mya %>%
  select(product_line, invoice_id, unit_price, quantity, total, gross_income, gross_margin_pct) %>% #choose the concerned fields
  group_by(product_line, invoice_id, unit_price) %>% #group all the lines by the 3 fields
  summarise(quantity = sum(quantity, na.rm = TRUE), 
            total = sum(total, na.rm = TRUE), 
            profit = gross_income * gross_margin_pct) %>% #"na.rm" deletes the null cell and calculate the total income and the sales  
  ungroup() %>%
  transmute(product_id = invoice_id,
            category = product_line,
            unit_price = unit_price,
            quantity = quantity,
            total = total,
            profit = profit
  ) #form a new table and use it later

# ############# The data cleaning part of Wuyuan END

# ###########################################################

ui <- dashboardPage(
  dashboardHeader(title = "Visualisations des Données du Marché"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("RFM", tabName = "rfm_transactions", icon = icon("bar-chart")),
      menuItem("Price and sales", tabName = "price_sales_us", icon = icon("bar-chart")), #Wuyuan
      menuItem("Price and profit", tabName = "price_profit_us_mya", icon = icon("usd"))  #Wuyuan
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "rfm_transactions",
              fluidRow(
                box(title = "RFM Analysis", width = 12, status = "primary", solidHeader = TRUE, 
                    plotlyOutput("plotRfmTransactions", height = "600px")),
                box(width = 12, 
                    HTML("<div style='padding: 15px;'>
                    <h4>How to classify users and formulate corresponding sales strategies according to different users(by using RFM model)?</h4>
                    <p>The RFM (Recency, Frequency, Monetary) model is a customer segmentation technique used in marketing to analyze and group customers based on their purchasing behaviors. Each component of the RFM model provides insight into different aspects of customer behavior:
                      <ul>
                        <li>
                          <strong>Recency (R)</strong>: How recently a customer made a purchase(days since last purchase). 
                          Calculate the number of days since the customer's last purchase. Assign a score based on how recent this purchase was, with more recent purchases getting higher scores.
                        </li>
                        <li>
                          <strong>Frequency (F)</strong>: How often a customer makes a purchase(days how often to shop).
                          Count the total number of purchases made by the customer within a specified time period. Assign a score based on the number of purchases, with more frequent purchasers getting higher scores.
                        </li>
                        <li>
                          <strong>Monetary (M)</strong>: How much money a customer spends(purchase amount in US dollars).
                          Sum the total amount of money the customer has spent within a specified time period. Assign a score based on the total spending, with higher spenders getting higher scores.
                        </li>
                      </ul>
                    </p>
                    
                    <p> </p>

    <p>Each customer is assigned to an RFM group, which represents their performance on these three dimensions. Here is a description of each category:
      <ol>
          <li>
              <span><strong>R1F1M1 - New Customers</strong></span>
              <ul>
                  <li>
                      <span><strong>Description:</strong> These are customers who have just made their first purchase recently. Their purchase frequency and purchase amount are both low.</span>
                  </li>
                  <li>
                      <span><strong>Features:</strong> Since they are new customers, they need to be cultivated into loyal customers through good service and appropriate marketing strategies.</span>
                  </li>
              </ul>
          </li>
          <li>
              <span><strong>R1F1M2 - Important Deepening Customers</strong></span>
              <ul>
                  <li>
                      <span><strong>Description:</strong> These customers have recently made their first purchase, and although the purchase frequency is low, the purchase amount is high.</span>
                  </li>
                  <li>
                      <span><strong>Features:</strong> These customers have high potential and need to further understand their needs and provide personalized products and services to increase their purchase frequency.</span>
                  </li>
              </ul>
          </li>
          <li>
              <span><strong>R1F2M1 - Potential Customers</strong></span>
              <ul>
                  <li>
                      <span><strong>Description:</strong> These customers have recently made purchases, with a high purchase frequency, but a low amount per purchase.</span>
                  </li>
                  <li>
                      <span><strong>Features:</strong> These customers have a high interaction frequency, and their purchase amount can be increased by recommending related products and improving customer experience.</span>
                  </li>
              </ul>
          </li>
          <li>
              <span><strong>R1F2M2 - Important Value Customers</strong></span>
              <ul>
                  <li>
                      <span><strong>Description:</strong> These customers have recently made frequent purchases and have a high amount.</span>
                  </li>
                  <li>
                      <span><strong>Features:</strong> These are the most valuable customers and need to be maintained and cared for, with exclusive offers and quality services to maintain their loyalty.</span>
                  </li>
              </ul>
          </li>
          <li>
              <span><strong>R2F1M1 - Churned Customers</strong></span>
              <ul>
                  <li>
                      <span><strong>Description:</strong> These customers have not made purchases for a long time and have low purchase frequency and amount.</span>
                  </li>
                  <li>
                      <span><strong>Features:</strong> These customers are at risk of churn and may need to be revived through special promotions or reactivation strategies.</span>
                  </li>
              </ul>
          </li>
          <li>
              <span><strong>R2F1M2 - Important Retention Customers</strong></span>
              <ul>
                  <li>
                      <span><strong>Description:</strong> These customers have not made purchases for a long time, but they used to have high purchase amounts.</span>
                  </li>
                  <li>
                      <span><strong>Features:</strong> These customers used to be high-value customers and need to be re-stimulated through special care and personalized promotional strategies.</span>
                  </li>
              </ul>
          </li>
          <li>
              <span><strong>R2F2M1 - Average Maintenance Customers</strong></span>
              <ul>
                  <li>
                      <span><strong>Description:</strong> These customers have average purchase behavior, with high frequency but low amount.</span>
                  </li>
                  <li>
                      <span><strong>Features:</strong> These customers are a relatively stable customer group and their purchase behavior can be maintained through continuous interaction and moderate offers.</span>
                  </li>
              </ul>
          </li>
          <li>
              <span><strong>R2F2M2 - Important Win-Back Customers</strong></span>
              <ul>
                  <li>
                      <span><strong>Description:</strong> These customers have a high purchase frequency and a high purchase amount, but have not made any purchases recently.</span>
                  </li>
                  <li>
                      <span><strong>Features:</strong> These customers used to be very important customers, and you can try to reactivate them by developing targeted recovery strategies (such as special offers and personalized recommendations).</span>
                  </li>
              </ul>
          </li>
      </ol>
    </p>
                          </div>")
                )
              )),
      
      # ############# The ui part of Wuyuan START
      
      tabItem(tabName = "price_sales_us",
              fluidRow(
                box(title = "The relation between the sales and the price in US", width = 12, status = "primary", solidHeader = TRUE, 
                    plotOutput("plotPriceSales")),
                sliderInput("profitSlider", "Select Profit Range:",
                            min = min(product_us$profit, na.rm = TRUE),
                            max = max(product_us$profit, na.rm = TRUE),
                            value = range(product_us$profit, na.rm = TRUE),
                            step = 100),
                checkboxGroupInput("categoryCheckbox", "Select Categories:",
                                   choices = unique(product_us$category),
                                   selected = unique(product_us$category)),
                checkboxGroupInput("subCategoryCheckbox", "Select Categories:",
                                   choices = unique(product_us$sub_category),
                                   selected = unique(product_us$sub_category))
              )),
      tabItem(tabName = "price_profit_us_mya",
              fluidRow(
                box(title = "The distribution of the unit_price and the profit in the 2 countries", width = 12, status = "primary", solidHeader = TRUE, 
                    plotOutput("plotPriceProfit")),
                sliderInput("salesSliderUS", "Select Sales Range of US:",
                            min = floor(min(product_us$quantity, na.rm = TRUE)),
                            max = ceiling(max(product_us$quantity, na.rm = TRUE)),
                            value = range(product_us$quantity, na.rm = TRUE),
                            step = 1),
                sliderInput("salesSliderMYA", "Select Sales Range of MYA:",
                            min = floor(min(product_mya$quantity, na.rm = TRUE)),
                            max = ceiling(max(product_mya$quantity, na.rm = TRUE)),
                            value = range(product_mya$quantity, na.rm = TRUE),
                            step = 1),
                checkboxGroupInput("categoryCheckboxUS", "Select Category (US):",
                                   choices = unique(product_us$category),
                                   selected = unique(product_us$category)),
                checkboxGroupInput("categoryCheckboxMYA", "Select Category (MYA):",
                                   choices = unique(product_mya$category),
                                   selected = unique(product_mya$category))
              ))
      # ############# The server part of Wuyuan END
    )
  )
)

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
      geom_point(color = "black") +
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
      geom_smooth(data = product_us, aes(x = unit_price, y = profit), method = "lm", se = FALSE, color = "blue") +
      geom_smooth(data = product_mya, aes(x = unit_price, y = profit), method = "lm", se = FALSE, color = "red") +
      theme_minimal() +
      xlim(0, 300) +  # limit the range of x
      ylim(-250, 250) 
  })
  
  # ############# The server part of Wuyuan END
}

shinyApp(ui, server)



