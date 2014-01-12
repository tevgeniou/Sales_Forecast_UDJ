
Sales <- read.csv(paste("data", "SALES.csv", sep = "/"), sep=";", dec=",") # this contains only the matrix ProjectData
Life <- read.csv(paste("data", "LIFE.csv", sep = "/"), sep=";", dec=",") # this contains only the matrix ProjectData
ProjectData <- read.csv(paste("data", "SALES.csv", sep = "/"), sep=";", dec=",") # this contains only the matrix ProjectData

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
