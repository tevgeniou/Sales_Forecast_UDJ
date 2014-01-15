# Required R libraries (need to be installed - it can take a few minutes the first time you run the project)

# installs all necessary libraries from CRAN
get_libraries <- function(filenames_list) { 
  lapply(filenames_list,function(thelibrary){    
    if (do.call(require,list(thelibrary)) == FALSE) 
      do.call(install.packages,list(thelibrary)) 
    do.call(library,list(thelibrary))
  })
}

libraries_used=c("devtools","knitr","graphics","reshape2","RJSONIO","grDevices","xtable","FactoMineR")
get_libraries(libraries_used)

if (require(slidifyLibraries) == FALSE) 
  install_github("slidifyLibraries", "ramnathv")
if (require(slidify) == FALSE) 
  install_github("slidify", "ramnathv") 
if (require(rCharts) == FALSE) 
  install_github('rCharts', 'ramnathv')

########################################################



my_summary <- function(thedata){
  res = apply(thedata, 2, function(r) c(min(r), quantile(r, 0.25), quantile(r, 0.5), mean(r), quantile(r, 0.75), max(r), sd(r)))
  colnames(res) <- colnames(thedata)
  rownames(res) <- c("min", "25%", "median", "mean", "75%", "max", "std")
  res
}

make_b <- function(i) paste("b", i, sep="")
