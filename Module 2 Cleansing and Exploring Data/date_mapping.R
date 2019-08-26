date_mapping = function(df, cal_w = NULL){
  
  df$week = week(df$fwk); df$year = year(df$fwk)
  
  # Define weeks starting 1 Jan - we strip off the last day of the year and ignore leap years (1 additional day in week 9)
  cal_w = seq(as.Date(paste("2001","-01-01",sep="")),as.Date(paste("2001","-12-24",sep="")),by="week")
  cal_w = gsub("2001",min(unique(year(df$fwk))),cal_w)
  cal_w = lapply(0:(length(unique(year(df$fwk)))-1),function(x) {gsub(min(unique(year(df$fwk))),unique(year(cal_w))+x,cal_w)})
  cal_w = data.frame("week" = unlist(cal_w), "number" = rep(1:52,length(unique(year(df$fwk)))))
  cal_w$week = as.Date(cal_w$week)
  
  # Define overlap
  overlap = function(x) {
    
    cat(paste(x," "))
    
    lapply(seq_along(cal_w$week),function(y) {
      Overlap(c(cal_w$week[y],cal_w$week[y]+7),c(unique(df$fwk)[x],unique(df$fwk)[x]+7))
    }
    )
  }
  
  # Distributed Execution 
  cl <- makeCluster(detectCores())
  clusterEvalQ(cl, {library(DescTools)}) 
  clusterExport(cl=cl, varlist=c("df","cal_w","overlap"), envir = environment())
  
  t = parallel::parLapply(cl, seq_along(unique(df$fwk)),function(x){overlap(x)})
  
  stopCluster(cl)
  
  # Check 
  # unlist(lapply(t,function(x) {sum(unlist(x))}))
  # unique(df$fwk)[unlist(lapply(t,function(x) {sum(unlist(x))})) != 7] # leap years (feb) and december months that do not start 
  
  # Map actual unit sales to new weeks
  cal_w$sales = 0
  unit_sales = list(list())
  
  for(fwk in df$fwk){
      
    lookup = which(unique(df$fwk) == fwk)
    cal_w[["sales"]][which(unlist(t[[lookup]]) > 0)] = cal_w[["sales"]][which(unlist(t[[lookup]]) > 0)] + df$sales[df$fwk == fwk]*unlist(t[[lookup]])[which(unlist(t[[lookup]]>0))]/7
  }
    
  # Remove leading and trailing 0s
  cal_w = cal_w[which(cal_w$sales > 0)[1]:(nrow(cal_w)-which(rev(cal_w$sales) > 0)+1)[1],]

  return(cal_w)
}

