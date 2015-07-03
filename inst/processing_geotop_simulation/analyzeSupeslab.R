#! .... 

rm(list=ls())


library(soilwater)
library(geotopbricks)
library(horizons)

wpath_pkg <- "/Users/ecor/Dropbox/R-packages/AnalyzeMoistureInSuperslab/inst"
wpath_data <- "/Users/ecor/Dropbox/R-packages/AnalyzeMoistureInSuperslab/data"
wpath_inputdata <- paste(wpath_pkg,"processing_geotop_simulation/inputdata",sep="/")
wpath <- "/Users/ecor/Dropbox/R-packages/AnalyzeMoistureInSuperslab_simulations/geotop_simulation" ######		paste(wpath_pkg,"geotop_simulation",sep="/")

inpts.file <- "geotop.inpts"
tz <- "GMT"
DemMap <- get.geotop.inpts.keyword.value("DemFile",wpath=wpath,inpts.file=inpts.file,raster=TRUE)
SlopeMap <- get.geotop.inpts.keyword.value("SlopeMapFile",wpath=wpath,inpts.file=inpts.file,raster=TRUE)
SoilMap <- get.geotop.inpts.keyword.value("SoilMapFile",wpath=wpath,inpts.file=inpts.file,raster=TRUE)

start <-  get.geotop.inpts.keyword.value("InitDateDDMMYYYYhhmm",date=TRUE,wpath=wpath,inpts.file=inpts.file,tz="GMT")

y <- (ymax(DemMap)+ymin(DemMap))/2

## 
x <- c(0,8,40,32,41)
names(x) <- c("Outlet","Slab1","Slab2","A","B")

xy <- data.frame(Name=names(x),x=x,y=y)

xy$cell <- cellFromXY(DemMap,xy[c("x","y")])

time_duration <- 13  # Expressed in hours


time_duration_when <- start+(1:time_duration)*3600

psi <- brickFromOutputSoil3DTensor("SoilLiqWaterPressTensorFile",
		when=time_duration_when, layers = "SoilLayerThicknesses",
		tz=tz,timestep = "OutputSoilMaps",wpath=wpath,inpts.file=inpts.file)
theta <- brickFromOutputSoil3DTensor("SoilLiqContentTensorFile",
		when=time_duration_when, layers = "SoilLayerThicknesses",
		tz=tz,timestep = "OutputSoilMaps",wpath=wpath,inpts.file=inpts.file)


##
#SoilLiqWaterPressTensorFile



save(list=c("psi","theta"),file=paste(wpath_data,"PsiTheta.rda",sep="/"))
