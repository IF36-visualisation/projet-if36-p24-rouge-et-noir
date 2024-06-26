library(shiny)
library(shinydashboard)

rfm_description <- tags$div(style = 'padding: 15px;',
                            tags$h4("How to classify customers based on their consumption behavior and to formulate corresponding strategies?"),
                            tags$p("The RFM (Recency, Frequency, Monetary) model is a customer segmentation technique used in marketing to analyze and group customers based on their purchasing behaviors. Each component of the RFM model provides insight into different aspects of customer behavior:",
                                   tags$ul(
                                     tags$li(tags$strong("Recency (R):"), " How recently a customer made a purchase (days since last purchase). Calculate the number of days since the customer's last purchase. Assign a score based on how recent this purchase was, with more recent purchases getting higher scores."),
                                     tags$li(tags$strong("Frequency (F):"), " How often a customer makes a purchase (days how often to shop). Count the total number of purchases made by the customer within a specified time period. Assign a score based on the number of purchases, with more frequent purchasers getting higher scores."),
                                     tags$li(tags$strong("Monetary (M):"), " How much money a customer spends (purchase amount in US dollars). Sum the total amount of money the customer has spent within a specified time period. Assign a score based on the total spending, with higher spenders getting higher scores.")
                                   )
                            ),
                            tags$p(),
                            tags$p("Each customer is assigned to an RFM group, which represents their performance on these three dimensions. Here is a description of each category:",
                                   tags$ol(
                                     tags$li(tags$span(tags$strong("R2F1M1 - New Customers")),
                                             tags$ul(
                                               tags$li(tags$span(tags$strong("Description:"), " These are customers who have just made their first purchase recently. Their purchase frequency and purchase amount are both low.")),
                                               tags$li(tags$span(tags$strong("Features:"), " Since they are new customers, they need to be cultivated into loyal customers through good service and appropriate marketing strategies."))
                                             )
                                     ),
                                     tags$li(tags$span(tags$strong("R2F1M2 - Important Deepening Customers")),
                                             tags$ul(
                                               tags$li(tags$span(tags$strong("Description:"), " These customers have recently made their first purchase, and although the purchase frequency is low, the purchase amount is high.")),
                                               tags$li(tags$span(tags$strong("Features:"), " These customers have high potential and need to further understand their needs and provide personalized products and services to increase their purchase frequency."))
                                             )
                                     ),
                                     tags$li(tags$span(tags$strong("R2F2M1 - Potential Customers")),
                                             tags$ul(
                                               tags$li(tags$span(tags$strong("Description:"), " These customers have recently made purchases, with a high purchase frequency, but a low amount per purchase.")),
                                               tags$li(tags$span(tags$strong("Features:"), " These customers have a high interaction frequency, and their purchase amount can be increased by recommending related products and improving customer experience."))
                                             )
                                     ),
                                     tags$li(tags$span(tags$strong("R2F2M2 - Important Value Customers")),
                                             tags$ul(
                                               tags$li(tags$span(tags$strong("Description:"), " These customers have recently made frequent purchases and have a high amount.")),
                                               tags$li(tags$span(tags$strong("Features:"), " These are the most valuable customers and need to be maintained and cared for, with exclusive offers and quality services to maintain their loyalty."))
                                             )
                                     ),
                                     tags$li(tags$span(tags$strong("R1F1M1 - Churned Customers")),
                                             tags$ul(
                                               tags$li(tags$span(tags$strong("Description:"), " These customers have not made purchases for a long time and have low purchase frequency and amount.")),
                                               tags$li(tags$span(tags$strong("Features:"), " These customers are at risk of churn and may need to be revived through special promotions or reactivation strategies."))
                                             )
                                     ),
                                     tags$li(tags$span(tags$strong("R1F1M2 - Important Retention Customers")),
                                             tags$ul(
                                               tags$li(tags$span(tags$strong("Description:"), " These customers have not made purchases for a long time, but they used to have high purchase amounts.")),
                                               tags$li(tags$span(tags$strong("Features:"), " These customers used to be high-value customers and need to be re-stimulated through special care and personalized promotional strategies."))
                                             )
                                     ),
                                     tags$li(tags$span(tags$strong("R1F2M1 - Average Maintenance Customers")),
                                             tags$ul(
                                               tags$li(tags$span(tags$strong("Description:"), " These customers have average purchase behavior, with high frequency but low amount.")),
                                               tags$li(tags$span(tags$strong("Features:"), " These customers are a relatively stable customer group and their purchase behavior can be maintained through continuous interaction and moderate offers."))
                                             )
                                     ),
                                     tags$li(tags$span(tags$strong("R1F2M2 - Important Win-Back Customers")),
                                             tags$ul(
                                               tags$li(tags$span(tags$strong("Description:"), " These customers have a high purchase frequency and a high purchase amount, but have not made any purchases recently.")),
                                               tags$li(tags$span(tags$strong("Features:"), " These customers used to be very important customers, and you can try to reactivate them by developing targeted recovery strategies (such as special offers and personalized recommendations)."))
                                             )
                                     )
                                   )
                            )
)


ui <- dashboardPage(
  dashboardHeader(title = "Market Data Visualizations"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Customer Category Analysis", tabName = "rfm_transactions", icon = icon("bar-chart")),
      menuItem("Price and sales", tabName = "price_sales_us", icon = icon("bar-chart")), #Wuyuan
      menuItem("Price and profit", tabName = "price_profit_us_mya", icon = icon("usd")),  #Wuyuan
      menuItem("Average Transaction Amounts", tabName = "avg_transactions", icon = icon("bar-chart")), # czy
      menuItem("City Analysis", tabName = "city_analysis", icon = icon("city"))  # Dyf
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "rfm_transactions",
              fluidRow(
                box(title = "How to classify customers based on their consumption behavior and to formulate corresponding strategies?", width = 12, status = "primary", solidHeader = TRUE, 
                    plotlyOutput("plotRfmTransactions", height = "600px")),
                box(width = 12, 
                  rfm_description
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
                            step = 100, width = '300%'),
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
                
              )),
      
      # ############# The new ui part added by czy START
      
      tabItem(tabName = "avg_transactions",
              fluidRow(
                box(title = "Montant Moyen des Transactions par Sous-catégorie", width = 12, status = "primary", solidHeader = TRUE, 
                    plotlyOutput("plotAvgTransactions")),
                box(width = 12, 
                    checkboxGroupInput("categoryFilter", "Select Categories:", choices = unique(data_usa$`Sub-Category`), selected = unique(data_usa$`Sub-Category`)),
                    HTML("<div style='padding: 15px;'>
                            <h4>Contexte:</h4>
                            <p>La catégorie des copieurs, ayant le montant moyen de transaction le plus élevé, reflète une demande continue pour des équipements de bureau efficaces et modernes, particulièrement dans un contexte où le travail à distance et la digitalisation des espaces de travail s'accélèrent. Cela pourrait indiquer une augmentation des investissements des entreprises pour améliorer l'efficacité et l'automatisation des bureaux.</p>
                            <h4>Situation Actuelle:</h4>
                            <p>Bien que les catégories 'Copieurs' et 'Machines' présentent des montants élevés, les articles de bureau plus courants tels que 'Fournitures' et 'Étiquettes' montrent des montants plus faibles, probablement en raison de leur bas prix unitaire et de leur achat fréquent, ce qui démontre une demande stable pour ces consommables dans l'environnement de bureau.</p>
                          </div>")
                )
              )),
      # ############# The new ui part added by czy END
      
      # ############# The new ui part added by dyf START
      
      tabItem(tabName = "city_analysis",
              fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 12,
                    sliderInput("num_cities", "Number of Cities to Display:", min = 1, max = 20, value = 10),
                    selectInput("year", "Select Year:", choices = c("All", unique(data_usa$Year)), selected = "All")
                )
              ),
              fluidRow(
                box(title = "Number of Customers by City in USA", status = "primary", solidHeader = TRUE, width = 6,
                    plotOutput("customer_count_plot")
                ),
                box(title = "Average Customer Spending by City in USA", status = "primary", solidHeader = TRUE, width = 6,
                    plotOutput("avg_spending_plot")
                )
              ))
      # ############# The new ui part added by dyf END
    )
  )
)
