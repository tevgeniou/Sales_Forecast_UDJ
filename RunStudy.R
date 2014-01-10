
# Project Name: "Sales Forecast Regression Exercise"

rm(list = ls()) # clean up the workspace

######################################################################

# THESE ARE THE PROJECT PARAMETERS NEEDED TO GENERATE THE REPORT

# Please ENTER the name of the file with the data used. The file should contain a matrix with one row per observation (e.g. person) and one column per attribute. THE NAME OF THIS MATRIX NEEDS TO BE ProjectData (otherwise you will need to replace the name of the ProjectData variable below with whatever your variable name is, which you can see in your Workspace window after you load your file)
datafile_name <- "SALES.csv" # this is the default name of the data for a project
###########
# DEFAULT PROJECT DATA FORMAT: File datafile_name must have a matrix called ProjectData of 
# D rows and S columns, where D is the number of days and S the number of stocks
###########

# this loads the selected data
ProjectData <- read.csv(paste("data", datafile_name, sep = "/"), sep=";", dec=",") # this contains only the matrix ProjectData

cat("\nVariables Loaded:", ls(), "\n")

# Please ENTER the dependent variable
dependent_variable <- "SALES"

# Please ENTER the independent variable
independent_variables <- c("PDI", "DEALS", "PRICE", "R.D", "INVEST", 
                           "ADVERTIS", "EXPENSE", "TOTINDAD")


# Would you like to also start a web application once the report and slides are generated?
# 1: start application, 0: do not start it. 
# Note: starting the web application will open a new browser 
# with the application running
start_webapp <- 1


######################################################################
# Define the data used in the slides and report, and run all necessary libraries 

source("R/library.R")
source("R/heatmapOutput.R")

######################################################################
# generate the report, slides, and if needed start the web application

unlink( "TMPdirSlides", recursive = TRUE )      
dir.create( "TMPdirSlides" )
setwd( "TMPdirSlides" )
file.copy( "../doc/SALES_Slides.Rmd","SALES_Slides.Rmd", overwrite = T )
slidify( "SALES_Slides.Rmd" )
file.copy( 'SALES_Slides.html', "../doc/SALES_Slides.html", overwrite = T )
setwd( "../" )
unlink( "TMPdirSlides", recursive = TRUE )      

unlink( "TMPdirReport", recursive = TRUE )      
dir.create( "TMPdirReport" )
setwd( "TMPdirReport" )
file.copy( "../doc/SALES_Report.Rmd","SALES_Report.Rmd", overwrite = T )
knit2html( 'SALES_Report.Rmd', quiet = TRUE )
file.copy( 'SALES_Report.html', "../doc/SALES_Report.html", overwrite = T )
setwd( "../" )
unlink( "TMPdirReport", recursive = TRUE )      

if (start_webapp){

  Sales <- read.csv(paste("data", "SALES.csv", sep = "/"), sep=";", dec=",") # this contains only the matrix ProjectData
  Life <- read.csv(paste("data", "LIFE.csv", sep = "/"), sep=";", dec=",") # this contains only the matrix ProjectData
  ProjectData <- read.csv(paste("data", "SALES.csv", sep = "/"), sep=";", dec=",") # this contains only the matrix ProjectData
  
  runApp("tools")
}
