knitr::opts_chunk$set(echo = TRUE)
library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(plotly)
library(readr)
library(lubridate)

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

##################### The data cleaning part added by dyf START

# Data cleaning: convert date format
data_usa$`Order Date` <- dmy(data_usa$`Order Date`)
data_usa$`Ship Date` <- dmy(data_usa$`Ship Date`)

# Convert date to "year-month-day" format
data_usa$`Order Date` <- format(data_usa$`Order Date`, "%Y-%m-%d")
data_usa$`Ship Date` <- format(data_usa$`Ship Date`, "%Y-%m-%d")

# Add year column
data_usa$Year <- format(as.Date(data_usa$`Order Date`), "%Y")

##################### The data cleaning part added by dyf END