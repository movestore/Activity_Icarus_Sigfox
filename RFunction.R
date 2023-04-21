library('move2')
library('broman')
library('data.table')
library('lubridate')
library('foreach')

## first version will plot whole time range for each track (so select that in previous Apps) and one plot per page by trackID (pdf!)
# need to improve timestamp axis

rFunction = function(data, dt=NULL, dt_unit="mins", runm_n=1) {
  
  Sys.setenv(tz="UTC")
  
  if (is.null(dt))
  {
    logger.info("You have not set a time interval of the activity measures. Go back and configure the settings. Here input will be returned.")
    result <- data
  } else
  {
    if (dt_unit=="mins") dt_u <- dt*60 else if(dt_unit=="hours") dt_u <- dt*3600 else dt_u <- dt #default secs
    
    tdiff <- make_difftime(dt_u,unit=dt_unit)
    
    data.split <- split(data,mt_track_id(data))
    
    csv_out <- data.frame("individual_local_identifier"= character(),timestamps_vedba_index=character(),activity_vedba_index=numeric(),"runmean_vedba_index"=numeric())

    pdf(appArtifactPath("activity_vedba_index.pdf"),onefile=TRUE)
    par(mar=c(10, 4, 8, 2))
    
    result_list <- foreach(datai = data.split) %do% {
      
      timestamps_vedba_index <- as.POSIXct(c(apply(matrix(as.character(datai$timestamp)),1,function(x) as.character(rev(as.POSIXct(x)-(0:5)*tdiff)))))
      activity_vedba_index_hx <- c(apply(as.matrix(datai$sigfox_sensor_data_raw),1,function(x) substring(x, seq(1, 11, 2), seq(2, 12, 2))))
      activity_vedba_index <- hex2dec(activity_vedba_index_hx)
      
      plot(timestamps_vedba_index,activity_vedba_index,type="l",col=2,lwd=2,xlab="",main=unique(mt_track_id(datai)),axes=FALSE)
      timestamps_20 <- as.POSIXct(timestamps_vedba_index[seq(1,length(timestamps_vedba_index),by=min(length(timestamps_vedba_index),20))])
      box()
      axis(2,,cex.axis=0.7,las=2)
      axis(1,at=timestamps_20,labels=as.character(timestamps_20),las=2,cex.axis=0.7)
      legend("topright",legend=c("raw value",paste("running mean",runm_n),"hourly mean+sd"),fill=c("red","blue","lightgrey"),cex=0.7)
      
      # running mean
      runmean <- frollmean(activity_vedba_index,n=runm_n,align="center")
      lines(timestamps_vedba_index,runmean,col=4)
      
      #fixed dayly background of hourly means over all data
      ho <- hour(timestamps_vedba_index)
      L <- length(ho)
      background_values <- data.frame("timestamp"=timestamps_vedba_index,activity_vedba_index,"hour"=ho,"bg_mean"=numeric(L),"bg_sd"=numeric(L))
      
      u_hour <- sort(unique(ho))
      bg_mean <- apply(as.matrix(u_hour),1,function(x) mean(background_values$activity_vedba_index[background_values$hour==x]))
      bg_sd <- apply(as.matrix(u_hour),1,function(x) sd(background_values$activity_vedba_index[background_values$hour==x]))
      ubg <- data.frame(u_hour,bg_mean,bg_sd)
      
      for (i in seq(along=ubg[,1]))
      {
        ix <- which(background_values$hour==ubg$u_hour[i])
        background_values$bg_mean[ix] <- ubg$bg_mean[i]
        background_values$bg_sd[ix] <- ubg$bg_sd[i]
      }
      
      polygon(x=c(timestamps_vedba_index,rev(timestamps_vedba_index)),y=c(background_values$bg_mean+background_values$bg_sd,rev(background_values$bg_mean-background_values$bg_sd)),density=NA,col="lightgrey")
      
      lines(timestamps_vedba_index,activity_vedba_index,col=2,lwd=2)
      lines(timestamps_vedba_index,runmean,col=4,lwd=2)
      
      
      #csv with all data
      
      csv_outi <- data.frame("individual_local_identifier"= rep(datai$individual_local_identifier,6),timestamps_vedba_index,activity_vedba_index,"runmean_vedba_index"=runmean)
      csv_out <- rbind(csv_out,csv_outi)
      
      # add activity_vedba_index to datai as vector to result
      index_mx <- apply(as.matrix(datai$sigfox_sensor_data_raw),1,function(x) substring(x, seq(1, 11, 2), seq(2, 12, 2)))
      activity_vedba_index_4res <- character(ncol(index_mx))
      for (k in 1:ncol(index_mx))
      {
        activity_vedba_index_4res[k] <- paste(hex2dec(index_mx[,k]),collapse=", ")
      }
      resulti <- datai
      resulti$activity_vedba_index <- activity_vedba_index_4res
      resulti
    }
    dev.off()
    
    names(csv_out)[which(names(csv_out)=="runmean_vedba_index")] <- paste0("runmean",runm_n,"_vedba_index")   
    write.csv(csv_out,appArtifactPath("activity_vedba_index.csv"),row.names=FALSE)
    
    result <- mt_stack(result_list)
  }
  
  return(result)
}
