#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(readxl)
library(tidyr)
library(dplyr)
library(DT)

df <- read_xlsx("data/2020-12-05 Authorisation Matrix Final Draft.xlsm", sheet = "Matrix", skip = 1)
df_clean <- df %>% 
  rename(`CA Role` = X__1) %>% 
  select(-`Not Used`, -`Not Used__1`, -`Not Used__2`)
df_long <- df_clean %>% 
  gather(key = `Decision`, val = Authority, -`CA Role`, na.rm = T)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("CA Authorisation Matrix"),
  tabsetPanel(
    tabPanel(
      title = "By CA Role",
      selectInput("ca_role",
                  "CA Role",
                  unique(df_long$`CA Role`),
                  selected = "00. AGM/SGM"),
      # Show the filtered table
        dataTableOutput("tbl_ca_role")
    ),
    tabPanel(
      title = "By Decision type",
      selectInput("decision",
                  "Decision",
                  unique(df_long$`Decision`),
                  selected = "Policy: Constitution"),
      # Show the filtered table
      dataTableOutput("tbl_decision")
      
    ),
    tabPanel(
      title = "Full matrix",
      dataTableOutput("tbl_full")
    )
  )
)


# Define server logic required to draw a histogram
server <- function(input, output) {
   
  output$tbl_ca_role <- renderDT(df_long %>% 
                                          filter(`CA Role` == input$ca_role),
                                        filter = "top"
  )
  output$tbl_decision <- renderDT(df_long %>% 
                                           filter(Decision == input$decision),
                                         filter = "top"
  )
  
  output$tbl_full <- renderDT(df_clean,
                                     filter = "top"
  )
}

# Run the application 
shinyApp(ui = ui, server = server)

