if (!exists("local_directory")) {  
  local_directory <- "~/Sales_Forecast_UDJ" 
  source(paste(local_directory,"R/library.R",sep="/"))
  source(paste(local_directory,"R/heatmapOutput.R",sep="/"))
} 

# To be able to upload data up to 30MB
options(shiny.maxRequestSize=30*1024^2)
options(rgl.useNULL=TRUE)
options(scipen = 50)

shinyServer(function(input, output,session) {
  
  ############################################################
  # STEP 1: Read the data 
  read_dataset <- reactive({
    input$datafile_name_coded
    
    # First read the pre-loaded file, and if the user loads another one then replace 
    # ProjectData with the filethe user loads
    ProjectData <- read.csv(paste("../data", paste(input$datafile_name_coded, "csv", sep="."), sep = "/"), sep=";", dec=",") # this contains only the matrix ProjectData
    
    updateSelectInput(session, "dependent_variable","Dependent variable",  colnames(ProjectData), selected=NULL)
    updateSelectInput(session, "independent_variables","Independent variables",  colnames(ProjectData), selected=NULL)
    
    ProjectData
  })
  
  user_inputs <- reactive({
    input$datafile_name_coded
    input$dependent_variable
    input$independent_variables
    
    list(ProjectData = read_dataset(), 
         dependent_variable = input$dependent_variable, 
         independent_variables = setdiff(input$independent_variables,input$dependent_variable))
  }) 
  
  ############################################################
  # STEP 2: create a "reactive function" as well as an "output" 
  # for each of the R code chunks in the report/slides to use in the web application. 
  # These also correspond to the tabs defined in the ui.R file. 
  
  # The "reactive function" recalculates everything the tab needs whenever any of the inputs 
  # used (in the left pane of the application) for the calculations in that tab is modified by the user 
  # The "output" is then passed to the ui.r file to appear on the application page/
  
  ########## The Parameters Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_parameters_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$dependent_variable
    input$independent_variables
    input$action_parameters
      
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    dependent_variable <- all_inputs$dependent_variable
    independent_variables <- all_inputs$independent_variables
    
    if (is.null(dependent_variable) | is.null(independent_variables)){
      res <- matrix(0,ncol=1)
      colnames(res) <- "Waiting for variable selection"
      return(res)
    }
    
    allparameters=c(nrow(ProjectData),ncol(ProjectData), colnames(ProjectData),
                    dependent_variable, independent_variables)
    allparameters <- matrix(allparameters,ncol=1)    
    rownames(allparameters)<-c("Number of Observations", "Number of Variables",
                               paste("Variable:",1:ncol(ProjectData)),
                               "Dependent Variable", 
                               paste("Independent Variable:",1:length(independent_variables)))
    colnames(allparameters)<-NULL
    
    allparameters
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$parameters<-renderTable({
    the_parameters_tab()
  })
  
  ########## The Summary Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_summary_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$dependent_variable
    input$independent_variables
    input$action_summary
    
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    dependent_variable <- all_inputs$dependent_variable
    independent_variables <- all_inputs$independent_variables
    
    my_summary(ProjectData)
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$summary <- renderTable({        
    the_summary_tab()
  })
  
  ########## The Histograms Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_histogram_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$dependent_variable
    input$independent_variables
    input$hist_var
    input$action_Histograms
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    dependent_variable <- all_inputs$dependent_variable
    independent_variables <- all_inputs$independent_variables
    
    ProjectData <- data.matrix(read_dataset() )# call the data reading reactive FUNCTION (hence we need "()" )
    if (!length(intersect(colnames(ProjectData), input$hist_var))){ 
      res = NULL
    } else {
      res = ProjectData[,input$hist_var, drop=F]
    }
    res
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$histogram<-renderPlot({ 
    data_to_plot = the_histogram_tab()
    if (!length(data_to_plot)) {
      hist(0, main = "VARIABLE DOES NOT EXIST" )      
    } else {
      hist(data_to_plot, main = paste("Histogram of", as.character(input$hist_var), sep=" "), xlab=as.character(input$hist_var),breaks = max(5,round(length(data_to_plot)/5)))      
    }
  })
  
  
  ########## The Correlations Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_correlation_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$dependent_variable
    input$independent_variables
    input$action_correlations
    
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    dependent_variable <- all_inputs$dependent_variable
    independent_variables <- all_inputs$independent_variables
    
    if ((length(intersect(colnames(ProjectData),independent_variables)) & length(intersect(colnames(ProjectData),dependent_variable)))){
      data_reorder=cbind(ProjectData[,independent_variables,drop=F],ProjectData[,dependent_variable,drop=F])
    } else {
      data_reorder=ProjectData[,1,drop=F]
    }
    thecor=cor(data_reorder)
    colnames(thecor)<-colnames(thecor)
    rownames(thecor)<-rownames(thecor)
    thecor    
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$correlation<-renderHeatmap({ 
    the_correlation_tab()
  })
  
  
  ########## The Scatter Plots Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_scatter_plots_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$dependent_variable
    input$independent_variables
    input$scatter1    
    input$scatter2  
    input$action_scatterplots
    
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    dependent_variable <- all_inputs$dependent_variable
    independent_variables <- all_inputs$independent_variables
    
    ProjectData <- data.matrix(read_dataset() )# call the data reading reactive FUNCTION (hence we need "()" )
    
    if ((length(intersect(colnames(ProjectData),independent_variables)) & length(intersect(colnames(ProjectData),dependent_variable)))){
      res = ProjectData[, c(input$scatter1,input$scatter2)]      
    } else {
      res = 0*ProjectData[,1:2]
      colnames(res)<- c("Not Valid Variable Name", "Not Valid Variable Name")
    }
    res
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$scatter<-renderPlot({   
    thedata <- the_scatter_plots_tab()
    plot(thedata[,1], thedata[,2], xlab=colnames(thedata)[1], ylab=colnames(thedata)[2])
  })  
  
  ########## The Regression Output Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_regression_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$dependent_variable
    input$independent_variables
    input$action_regression
    
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    dependent_variable <- all_inputs$dependent_variable
    independent_variables <- all_inputs$independent_variables
    
    if ((length(intersect(colnames(ProjectData),independent_variables)) & length(intersect(colnames(ProjectData),dependent_variable)))){
      if (length(independent_variables) == 1){ 
        regression_model=paste(paste(dependent_variable, "~",sep=""), independent_variables,sep="")
      } else {
        res=independent_variables[1]
        for (iter in 2:(length(independent_variables)-1))
          res=paste(res,independent_variables[iter],sep="+")
        res=paste(res,tail(independent_variables,1),sep="+")
        regression_model = paste(dependent_variable, res, sep="~")  
      }
      the_fit<-lm(regression_model,data=ProjectData)
    } else {      
      regression_model = paste(paste(colnames(ProjectData)[1], "~",sep=""), colnames(ProjectData)[2],sep="")
      the_fit<-lm(regression_model,data=ProjectData)      
    }
    the_fit
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$regression_output <- renderTable({
    the_fit = the_regression_tab()
    summary(the_fit)
  })
  
  
  ########## The Residuals plot Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_residuals_plot_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$dependent_variable
    input$independent_variables
    input$action_residuals
    input$action_residualshist
    
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    dependent_variable <- all_inputs$dependent_variable
    independent_variables <- all_inputs$independent_variables
    
    the_fit = the_regression_tab()    
    residuals(the_fit)       
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$residuals_plot<-renderPlot({    
    plot(the_residuals_plot_tab(),xlab="Observations",ylab="Residuals",main="The Residuals")
  })
  
  
  ########## The Residuals Histogram Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  # this one uses the same reactive function as the previous tab...
  
  # Now pass to ui.R what it needs to display this tab
  output$residuals_hist<-renderPlot({    
    dataused = the_residuals_plot_tab()
    hist(dataused, main = "Histogram of the Residuals", breaks = max(5,round(length(dataused)/5)))
  })
  
  ########## The Residuals Scatter Plots Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_residuals_scatter_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$dependent_variable
    input$independent_variables
    input$residual_scatter1
    input$action_residuals_scatter
    
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    dependent_variable <- all_inputs$dependent_variable
    independent_variables <- all_inputs$independent_variables
    
    ProjectData <- data.matrix(read_dataset() )# call the data reading reactive FUNCTION (hence we need "()" )    
    the_residuals <- the_residuals_plot_tab()
    
    if (length(intersect(colnames(ProjectData),input$residual_scatter1))){
      res = cbind(ProjectData[, input$residual_scatter1], the_residuals)
      colnames(res)<- c(input$residual_scatter1, "Residuals")
    } else {
      res = 0*ProjectData[,1:2]
      colnames(res)<- c("Not Valid Variable Name", "Not Valid Variable Name")
    }
    res
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$residuals_scatter<-renderPlot({    
    thedata <- the_residuals_scatter_tab()
    
    plot(thedata[,1],thedata[,2],xlab=colnames(thedata)[1],ylab=colnames(thedata)[2])
  })
  
  # Now the report and slides  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_slides_and_report <-reactive({
    input$datafile_name_coded
    input$dependent_variable
    input$independent_variables
    
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    dependent_variable <- all_inputs$dependent_variable
    independent_variables <- all_inputs$independent_variables
    
    #############################################################
    # A list of all the (SAME) parameters that the report takes from RunStudy.R
    list(ProjectData = ProjectData, independent_variables = independent_variables,
         dependent_variable = dependent_variable)
  })
  
  # The new report 
  
  output$report = downloadHandler(
    filename <- function() {paste(paste('SALES_Report',Sys.time() ),'.html')},
    
    content = function(file) {
      
      filename.Rmd <- paste('SALES_Report', 'Rmd', sep=".")
      filename.md <- paste('SALES_Report', 'md', sep=".")
      filename.html <- paste('SALES_Report', 'html', sep=".")
      
      #############################################################
      # All the (SAME) parameters that the report takes from RunStudy.R
      reporting_data<- the_slides_and_report()
      ProjectData<-reporting_data$ProjectData
      dependent_variable <- reporting_data$dependent_variable
      independent_variables <- reporting_data$independent_variables
      #############################################################
      
      if (file.exists(filename.html))
        file.remove(filename.html)
      unlink(".cache", recursive=TRUE)      
      unlink("assets", recursive=TRUE)      
      unlink("figures", recursive=TRUE)      
      
      file.copy(paste(local_directory,"doc/SALES_Report.Rmd",sep="/"),filename.Rmd,overwrite=T)
      out = knit2html(filename.Rmd,quiet=TRUE)
      
      unlink(".cache", recursive=TRUE)      
      unlink("assets", recursive=TRUE)      
      unlink("figures", recursive=TRUE)      
      file.remove(filename.Rmd)
      file.remove(filename.md)
      
      file.rename(out, file) # move pdf to file for downloading
    },    
    contentType = 'application/pdf'
  )
  
  # The new slide 
  
  output$slide = downloadHandler(
    filename <- function() {paste(paste('SALES_Slides',Sys.time() ),'.html')},
    
    content = function(file) {
      
      filename.Rmd <- paste('SALES_Slides', 'Rmd', sep=".")
      filename.md <- paste('SALES_Slides', 'md', sep=".")
      filename.html <- paste('SALES_Slides', 'html', sep=".")
      
      #############################################################
      # All the (SAME) parameters that the report takes from RunStudy.R
      reporting_data<- the_slides_and_report()
      ProjectData<-reporting_data$ProjectData
      dependent_variable <- reporting_data$dependent_variable
      independent_variables <- reporting_data$independent_variables
      #############################################################
      
      if (file.exists(filename.html))
        file.remove(filename.html)
      unlink(".cache", recursive=TRUE)     
      unlink("assets", recursive=TRUE)    
      unlink("figures", recursive=TRUE)      
      
      file.copy(paste(local_directory,"doc/SALES_Slides.Rmd",sep="/"),filename.Rmd,overwrite=T)
      slidify(filename.Rmd)
      
      unlink(".cache", recursive=TRUE)     
      unlink("assets", recursive=TRUE)    
      unlink("figures", recursive=TRUE)      
      file.remove(filename.Rmd)
      file.remove(filename.md)
      file.rename(filename.html, file) # move pdf to file for downloading      
    },    
    contentType = 'application/pdf'
  )
  
})
