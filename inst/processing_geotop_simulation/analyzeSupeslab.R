#! .... 

rm(list=ls())


library(soilwater)
library(geotopbricks)
library(horizons)
library(AnalyzeMoistureInSuperslab)

#source(
######



#				'/home/ecor/Dropbox/R-packages/AnalyzeMoistureInSuperslab/R/SoilWaterStorage.R' )

loadDataFromPackage <- TRUE 

wpath_pkg <- "/home/ecor/Dropbox/R-packages/AnalyzeMoistureInSuperslab/inst"
wpath_data <- "/home/ecor/Dropbox/R-packages/AnalyzeMoistureInSuperslab/data"
wpath_inputdata <- paste(wpath_pkg,"processing_geotop_simulation/inputdata",sep="/")
wpath <- "/home/ecor/Dropbox/R-packages/AnalyzeMoistureInSuperslab_simulations/geotop_simulation" ######		paste(wpath_pkg,"geotop_simulation",sep="/")
file.output.csv <- paste(wpath_pkg,"processing_geotop_simulation/output/geotop.surslab.output.csv",sep="/")

paramPrefix <- "Header"
inpts.file <- "geotop.inpts"
tz <- "GMT"

DemMap <- get.geotop.inpts.keyword.value("DemFile",wpath=wpath,inpts.file=inpts.file,raster=TRUE)
SlopeMap <- get.geotop.inpts.keyword.value("SlopeMapFile",wpath=wpath,inpts.file=inpts.file,raster=TRUE)
SoilMap <- get.geotop.inpts.keyword.value("SoilMapFile",wpath=wpath,inpts.file=inpts.file,raster=TRUE)

start <-  get.geotop.inpts.keyword.value("InitDateDDMMYYYYhhmm",date=TRUE,wpath=wpath,inpts.file=inpts.file,tz="GMT")
#### Soil Properties


DzName <- get.geotop.inpts.keyword.value(paste(paramPrefix,"SoilDz",sep=""),wpath=wpath,inpts.file=inpts.file)
SoilPar <- get.geotop.inpts.keyword.value("SoilParFile",wpath=wpath,inpts.file=inpts.file,data.frame=TRUE,level=unique(SoilMap))			
layer <- SoilPar[[1]][,DzName]


####
y <- (ymax(DemMap)+ymin(DemMap))/2

## 
x <- c(0,8,40,32,41)
names(x) <- c("Outlet","Slab1","Slab2","A","B")

xy <- data.frame(Name=names(x),x=x,y=y)

xy$cell <- cellFromXY(DemMap,xy[c("x","y")])

time_duration <- 13  # Expressed in hours


time_duration_when <- start+(1:time_duration)*3600


if (loadDataFromPackage==TRUE) { 

	psi <- NULL
	theta <- NULL
	data(PsiTheta)
	
} else {
	psi <- brickFromOutputSoil3DTensor("SoilLiqWaterPressTensorFile",
		when=time_duration_when, layers = "SoilLayerThicknesses",
		tz=tz,timestep = "OutputSoilMaps",wpath=wpath,inpts.file=inpts.file)
	theta <- brickFromOutputSoil3DTensor("SoilLiqContentTensorFile",

		when=time_duration_when, layers = "SoilLayerThicknesses",
		tz=tz,timestep = "OutputSoilMaps",wpath=wpath,inpts.file=inpts.file)

	hsup <- rasterFromOutput2DMap("LandSurfaceWaterDepthMapFile",
		
		when=time_duration_when,
		tz=tz,timestep = "OutputSoilMaps",wpath=wpath,inpts.file=inpts.file)


	save(list=c("psi","theta","hsup"),file=paste(wpath_data,"PsiTheta.rda",sep="/"))


}
#################### PREPARE CSV 

t <- 5
dz <- layer/1000  ## 50 millimiters layer depth ##transformed from millimiters to meters
dx <- xres(theta[[1]])


outputCsv <- data.frame(time=(1:time_duration)*3600,geotop_surface_water=NA,
		geotop_soilwater=NA,
		geotop_unsat_soilwater=NA, 
		geotop_groundwt_soilwater=NA
		)

		
		
for (t in 1:time_duration) {
	
	
	unsatWaterVolume <- SoilWaterStorage(theta[[t]],psi[[t]],layer=dz,comparison="<",psi_thres=0,fun=sum)
	satWaterVolume <- SoilWaterStorage(theta[[t]],psi[[t]],layer=dz,comparison=">=",psi_thres=0,fun=sum)
	WaterVolume <- SoilWaterStorage(theta[[t]],NULL,layer=dz,fun=sum)
	transect <- data.frame(x=c(1,100)*dx-dx/2,y=y)


	outputCsv[t,"geotop_soilwater"]<- sum(xyFrom2PointLine(r=WaterVolume,points=transect)$value001,na.rm=TRUE)*dx
	outputCsv[t,"geotop_groundwt_soilwater"]<- sum(xyFrom2PointLine(r=satWaterVolume,points=transect)$value001,na.rm=TRUE)*dx
	outputCsv[t,"geotop_unsat_soilwater"]<- sum(xyFrom2PointLine(r=unsatWaterVolume,points=transect)$value001,na.rm=TRUE)*dx
	outputCsv[t,"geotop_surface_water"]<- sum(xyFrom2PointLine(r=hsup[[t]]/1000,points=transect)$value001,na.rm=TRUE)*dx
}


write.table(outputCsv,file=file.output.csv,quote=FALSE,sep=",",row.names=FALSE)

##
#SoilLiqWaterPressTensorFile








### ADDED 


