
shinyUI(pageWithSidebar(
  
  ##########################################
  # STEP 1: The name of the application
  
  headerPanel("A UDJ Regression App"),
  
  ##########################################
  # STEP 2: The left menu, which reads the data as
  # well as all the inputs exactly like the inputs in RunStudy.R
  
  sidebarPanel(
    
    HTML("<center><h4> Please first read the notes below </h4>"),    
    HTML("<hr>"),    
    
    ###########################################################    
    # STEP 2.1: read the data
    
    HTML("<h4>Data Upload </h4>"),
    HTML("<br>"),    
    HTML("Choose a pre-loaded file (Recommended for Testing the App):"),    
    selectInput('datafile_name_coded', '', c("SALES","LIFE"),multiple = FALSE),
    HTML("<br>"),
    checkboxInput("load_choice", "Check box to load your own data (requires fast internet connection).", value=FALSE),
    HTML("<br>"),
    fileInput('datafile_name', ''),
    HTML("<hr>"),
    
    ###########################################################
    # STEP 2.2: read the INPUTS. 
    # THESE ARE THE *SAME* INPUT PARAMETERS AS IN THE RunStudy.R
    
    HTML("<h4>Variable Selection </h4>"),
    HTML("(<strong>press 'ctrl'</strong> to select multiple independent variables)"),
    HTML("<br>"),
    HTML("<br>"),
    selectInput("dependent_variable","Dependent variable",  choices=c("dependent Variable"),selected=NULL, multiple=FALSE),
    #uiOutput("dependent_variable"),
    HTML("<br>"),
    selectInput("independent_variables","Independent variables",  choices = c("independent Variables"), selected=NULL, multiple=TRUE),
    #uiOutput("independent_variables"),
    HTML("<hr>"),
    
    ###########################################################
    # STEP 2.3: buttons to download the new report and new slides 
    
    HTML("<h4>Download the new HTML report </h4>"),
    downloadButton('report', label = "Download"),
    HTML("<hr>"),
    HTML("<h4>Download the new HTML5 slides </h4>"),
    downloadButton('slide', label = "Download"),
    HTML("<hr>"),
    
    HTML("<h4>Notes:</h4> </center>"),
    HTML("<br>"),    
    HTML("Please reload the web page any time the app crashes. <strong> When it crashes the screen turns into grey.</strong> If it only stops reacting it may be because of 
heavy computation or traffic on the server, in which case you should simply wait. This is a test version. </h4>"),
    HTML("<br>"),    
    HTML("<br>"),    
    HTML("If you load your own data, your data file should be a <strong>.csv file in the format of the case with one 
         column per variable and one row per observation, with the first row being the variable names</strong>."),    
    HTML("<br>"),    
    HTML("<br>"),    
    HTML("If you load your own data you need to keep the selection of the <strong>'load your own data'</strong> button above on. Otherwise, to use the pre-loaded data you must uncheck the button"),    
    HTML("<hr>")
    
  ),
  
  ###########################################################
  # STEP 3: The output tabs (these follow more or less the 
  # order of the Rchunks in the report and slides)
  
  mainPanel(
    # Just set it up
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),
    
    # Now these are the taps one by one. 
    # NOTE: each tab has a name that appears in the web app, as well as a
    # "variable" which has exactly the same name as the variables in the 
    # output$ part of code in the server.R file 
    # (e.g. tableOutput('parameters') corresponds to output$parameters in server.r)
    
    tabsetPanel(
      
      tabPanel("Parameters", 
               div(class="row-fluid",
                   div(class="span12",h4("Summary of Key Parameters")),
                   tags$hr(),
                   tableOutput('parameters')
               )
      ),
      
      tabPanel("Summary", tableOutput('summary')),
      
      tabPanel("Histograms",
               div(class="row-fluid",
                   div(class="span12",h4("Select Stock")),
                   textInput("hist_var", "Select the name of the variable to see", "SALES"),
                   tags$hr(),
                   div(class="span6",plotOutput('histogram'))
               )
      ),
      
      tabPanel("Correlations",tableOutput('correlation')),
      
      tabPanel("Scatter Plots", 
               div(class="row-fluid",
                   textInput("scatter1", "Select the variable to plot on the x-axis:", "PRICE"),
                   tags$hr(),
                   textInput("scatter2", "Select the variable to plot on the y-axis:", "SALES"),
                   tags$hr(),
                   div(class="span12",h4("The Scatter Plot")),
                   div(class="span6",plotOutput('scatter'))
               )
      ),               
      
      tabPanel("Regression Output", tableOutput("regression_output")),
      
      tabPanel("Residuals Plot", plotOutput("residuals_plot")),
      
      tabPanel("Residuals Histogram", plotOutput("residuals_hist")),
      
      tabPanel("Residuals Scatter Plots", 
               div(class="row-fluid",
                   textInput("residual_scatter1", "Select the variable to plot the residuals against:", "SALES"),
                   tags$hr(),
                   div(class="span12",h4("The Scatter Plot")),
                   div(class="span6",plotOutput('residuals_scatter'))
               )
      )               
      
      
    )
  )
))