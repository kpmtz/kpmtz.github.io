library(shiny)
library(leaflet)
library(dplyr)
library(DBI)
library(RSQLite)
library(RPostgreSQL)
library(DT)
library(rsconnect)

postgre_con <- dbConnect(RPostgres::Postgres(),
                         dbname = 'PolicyPortrait', # name of the database
                         host = '127.0.0.1', 
                         port = 5433, 
                         user = 'postgres',
                         password = 'KpmtZ8144122') 
#DEFINE UI
ui<-fluidPage(
  tags$head(
    tags$style(
      HTML(
        "
        body {
          background-color: gray;
          color: black;
        }
        .sidebarLayout, .sidebarPanel, .mainPanel {
          background-color: #008CBA; /* Blue */
          color: black;
          padding: 10px;
        }
        .titlePanel {
          background-color: white;
          color: white;
          padding: 10px;
        }
        "
      )
    )
  ),
  titlePanel(
    div(
      "POLICYPORTRAIT",
      img(src = "C:\\Users\\Leiram\\Documents\\PolicyPortrait\\www\\policyicon.jpg", width ="250px", height= "auto", style= "margin-left:10px;")
    )
  ),
  sidebarLayout(
    sidebarPanel(
      h2("Exploring Policy Proposals, Public Opinion, and Partisanship"),
      selectInput("data_option", "Select Data Option:",
                  choices= c("State Laws And Support","Public Opinion and Votes", "Policy Proposals", "Partisanship Beliefs")),
    ),
    mainPanel(
      h2("Reaching a Compromise on : P O L I C Y"),
      h3("Gun Policy Database System Data"),
      p("The lingering question persists about policy: Can the United States, under any circumstances, reach a compromise on gun legislation, despite the strong presence of polarization in public opinion?
        The lack of knowledge, collaborative communication, and deepening polarization makes it complicated for individuals to voice their opinions or reach a conclusion that could satisfy both the Democratic and Republican sides. Over the course of United States history, mass shootings have impacted and agonized the country for over 4 decades. The phenomenon of mass shootings has multiplied and the dispute towards more gun control has kept citizens apprehensive about what actions should be taken. The central focus of this database is to dissect the opinions of diverse groups across different regions, delving into the perspectives on gun policy. This database will include analysis based on surveys of individuals and aims to show the congruence of their opinions with those of the policy makers who represent them as well as the policies that embody their beliefs.",
      uiOutput("tab_content"),
      leafletOutput("map"),
      h3("Mass Shootings in the United States"),
      p("This interactive map shows the United States. Click on Texas, California, or Florida to view public opinion data specific to that state.")
    )
    )
),
)
#DEFINE SERVER
server <- function(input,output,session) {
  #GettingData
  fetch_data<- function(query) {
    dbGetQuery(postgre_con,query)
  }
  
  #Tables
  output_table <- function(df) {
    datatable(df,rownames=FALSE)
    }
  #"TAB CONTENT"
  output$tab_content <- renderUI ({
    data_option <- input$data_option
    if (data_option == "State Laws And Support") {
      states_df <- fetch_data ("SELECT * FROM states")
      output_table(states_df)
    } else if (data_option == "Public Opinion and Votes") {
      votes_df <- fetch_data("SELECT * FROM votes")
      output_table(votes_df)
    } else if (data_option == "Policy Proposals") {
      policies_df <- fetch_data("SELECT * FROM policies")
      output_table(policies_df)
    } else if (data_option == "Partisanship Beliefs") {
      partisanship_df <- fetch_data("SELECT * FROM partisanship")
      output_table(partisanship_df)
    }
  })
  
  #RENDERING MAP
  output$map <-renderLeaflet({
    map_data <- data.frame(
      state= c("Texas", "California", "Florida"),
      lat = c(31.9686, 36.7783, 27.9944),
      lon = c(-99.9018, -119.4179, -81.7603),
      color= c("red","blue","red")
  )
    
    #Fetch Popup Data
    popups_data <- fetch_data("SELECT state_name, casualties_py FROM states WHERE state_name IN ('Texas', 'California', 'Florida')")
    
  #CreateMap
  m <-leaflet(data = map_data) %>%
    addTiles() %>%
    addCircleMarkers(lng= ~lon,lat= ~lat, radius =5, color= ~color, popup= ~paste("<b>State:</b>", state, "<br><b>Casualties:</b>", popups_data$casualties_py))
  
  #Return 
  m
  })
}
#RUN THE APPLICATION
shinyApp(ui = ui, server = server)
