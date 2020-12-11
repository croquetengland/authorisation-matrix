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
library(lubridate)

filepath <- "data/2020-12-07 Authorisation Matrix Final Draft.xlsm"
df <- read_xlsx(filepath, sheet = "Matrix", skip = 1)
df_clean <- df %>% 
  rename(`CA Role` = X__1) %>% 
  select(-`Not Used`, -`Not Used__1`, -`Not Used__2`)
df_long <- df_clean %>% 
  gather(key = `Decision`, val = Authority, -`CA Role`, na.rm = T)

df_comments <- read_xlsx(filepath, sheet = "Comments")

df_versionlog <-tribble(
  ~Version, ~Date, ~Description,
  "1.0", ymd(20201205), "Matrix: initial circulated version for Council meeting 12th Dec 2020",
  "1.1", ymd(20201207), "Matrix updated to include the additional items on the \'Financial: Bursary/Development\' column"
) %>% 
  mutate(Date = as.character(Date))

# Define UI for application that draws a histogram
ui <- 
  fluidPage(
    
    # Application title
    titlePanel("CA Authorisation Matrix"),
    sidebarLayout(
      sidebarPanel(
        h4("About this tool"),
        p("This tool is the product of the CA Authorisation Review working group led by Samir Patel that has been looking at which groups or individuals should have authority to take decisions, spend money
          or otherwise make commitments behalf of the CA."),
        p("An interim report was given to the October meeting, with an earlier draft. The Authorisation Matrix working group reviewed all the comments received from Council, the Executive Board and a few CA members, and has updated the matrix accordingly."),
        h4("Instructions"),
        p("Use the individual tabs to view the authorisation matrix by CA role or Decision."),
        h4("Contact"),
        tags$a(href="mailto:croquet@patel500.co.uk", 
               "Samir Patel"),
        
        h4("Version log"),
        tableOutput("version_log")
        
      ),
      mainPanel(
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
          ),
          tabPanel(
            title = "Comments",
            dataTableOutput("tbl_comments")
          )
        )
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
  output$tbl_comments <- renderDT(df_comments,
                              filter = "top"
  )
  
  output$version_log <- renderTable(df_versionlog)
}

# Run the application 
shinyApp(ui = ui, server = server)

