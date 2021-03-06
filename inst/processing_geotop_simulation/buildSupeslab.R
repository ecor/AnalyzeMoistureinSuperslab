#! .... 

rm(list=ls())


library(soilwater)
library(geotopbricks)
library(horizons)

wpath_pkg <- "/Users/ecor/Dropbox/R-packages/AnalyzeMoistureInSuperslab/inst"
wpath_data <- "/Users/ecor/Dropbox/R-packages/AnalyzeMoistureInSuperslab/data"
wpath_inputdata <- paste(wpath_pkg,"processing_geotop_simulation/inputdata",sep="/")
wpath <- "/Users/ecor/Dropbox/R-packages/AnalyzeMoistureInSuperslab_simulations/geotop_simulation" ######		paste(wpath_pkg,"geotop_simulation",sep="/")

soilprop_tmp <- read.table(paste(wpath_inputdata,"soilprop_tmp.txt",sep="/"),sep=",",header=TRUE) 
#######

inpts.file <- "geotop.inpts"
paramPrefix <- "Header"

WiltingPoint <- get.geotop.inpts.keyword.value(paste(paramPrefix,"WiltingPoint",sep=""),wpath=wpath,inpts.file=inpts.file)
FieldCapacity <- get.geotop.inpts.keyword.value(paste(paramPrefix,"FieldCapacity",sep=""),wpath=wpath,inpts.file=inpts.file)
ThetaSat <- get.geotop.inpts.keyword.value(paste(paramPrefix,"ThetaSat",sep=""),wpath=wpath,inpts.file=inpts.file)
ThetaRes <- get.geotop.inpts.keyword.value(paste(paramPrefix,"ThetaRes",sep=""),wpath=wpath,inpts.file=inpts.file)
VG_Alpha <- get.geotop.inpts.keyword.value(paste(paramPrefix,"Alpha",sep=""),wpath=wpath,inpts.file=inpts.file)
VG_N <- get.geotop.inpts.keyword.value(paste(paramPrefix,"N",sep=""),wpath=wpath,inpts.file=inpts.file)
Dz <- get.geotop.inpts.keyword.value(paste(paramPrefix,"SoilDz",sep=""),wpath=wpath,inpts.file=inpts.file)
SoilInitPres <- get.geotop.inpts.keyword.value(paste(paramPrefix,"SoilInitPres",sep=""),wpath=wpath,inpts.file=inpts.file)




### CORRECT SOIL WATER
alpha <-  soilprop_tmp[,VG_Alpha]
n <- soilprop_tmp[,VG_N]
theta_sat <- soilprop_tmp[,ThetaSat]
theta_res <- soilprop_tmp[,ThetaRes]
###	=alpha,n=n,theta_sat=theta_sat,theta_res=theta_res)
waterdensity <- 1000 ## kg/m^3
gravity <- 9.81 ## m/s^2


psi_WP <- -1500*1000 ## Pa
psi_FC <- -33*1000  ##  Pa

psi_WP <- psi_WP/(waterdensity*gravity)*1000 ## converted to water millimiters according to GEOtop
psi_FC <- psi_FC/(waterdensity*gravity)*1000 ## converted to water millimiters according to GEOtop

soilprop_tmp[,FieldCapacity] <- swc(psi=psi_FC,alpha=alpha,n=n,theta_sat=theta_sat,theta_res=theta_res,type_swc="VanGenuchten")
soilprop_tmp[,WiltingPoint] <- swc(psi=psi_WP,alpha=alpha,n=n,theta_sat=theta_sat,theta_res=theta_res,type_swc="VanGenuchten")
###

write.table(soilprop_tmp,paste(wpath_inputdata,"soilprop.txt",sep="/"),sep=",",quote=FALSE,row.names=FALSE) 

####
#
# BUILD THE HILLSLOPE SOIL PROFILES
#
####

slope <- 0.1
cos_slope <- 1/(1+slope^2)^0.5

xlen <- 100
zdepth <- 5

xres <- 1
zres <- 0.05 

nrows <- round(xlen/xres)
ncols <- round(zdepth/zres)


hillslope_profile <- raster(xmx=xlen,xmn=0,ymx=zdepth,ymn=0,nrows=nrows,ncols=ncols)


hillslope_profile[,] <- 0

slabs_p <- list(
	slab1=data.frame(x=c(8,60),y=(zdepth+c(8,60)*slope)-c(5.8,6.2)),
    slab2=data.frame(x=c(40,60),y=zdepth-c(1.3,1.3))
)



##xy_A <- xyFrom2PointLine(points=data.frame(x=c(0,1),y=c(0,1)),step=0.1)
slabs <- lapply(X=slabs_p,FUN=function(x,r,...) {
			
			out <- xyFrom2PointLine(r=r,points=x,...)
			return(out)
		},r=hillslope_profile,step=zres)

indexslabs <- as.numeric(str_replace(names(slabs),"slab",""))
names(indexslabs) <- names(slabs)

####
####
####

for (it in names(slabs)) {
	
	is <- indexslabs[it]
	slabs[[it]]$value001 <- is
	hillslope_profile[unique(slabs[[it]]$icell)] <- is
	
}

###############
#
# Detecting Soil Classes per each soil column
#
#

soilcols <- array(0,ncol(hillslope_profile))
soilp <- nrow(soilprop_tmp)
for (i in 1:length(soilcols)) {
	
		soilp[i] <- paste(as.matrix(hillslope_profile)[,i],collapse=",")
	
	
	
}

usoilp <- unique(soilp)
iusoilp <- index(usoilp)
names(iusoilp) <- usoilp

soilmap_hillslope <- iusoilp[soilp]
###
### CReate Soil Classes 
###
soilprefix <- get.geotop.inpts.keyword.value("SoilParFile",wpath=wpath,inpts.file=inpts.file,add_wpath=TRUE)			
soilfile <- paste(soilprefix,"%04d.txt",sep="")
row.names(soilprop_tmp)  <- as.character(soilprop_tmp$ID)


dz_layer <- zres*cos_slope*1000
watertabledepth <- zdepth*cos_slope*1000

for (it in names(iusoilp)) {
	
	is <- iusoilp[it]
	soilprofile <- (str_split(it,",")[[1]])
	
	
	
	
	soilclass <- soilprop_tmp[soilprofile,]
	
	soilclass[,Dz] <- dz_layer
	soilclass[,SoilInitPres] <- ((1:nrow(soilclass))*dz_layer-dz_layer/2-watertabledepth)*cos_slope
	
	
	namesSoilClass <- c(Dz,names(soilclass)[!(names(soilclass) %in% Dz)])
	
	soilclass <- soilclass[,namesSoilClass]
	
	write.table(soilclass,sprintf(soilfile,is),sep=",",quote=FALSE,row.names=FALSE) 
	
	
	
}



#######
#
# CREATES HILLSLOPE MAPS
#
#####

soilmapasc <- paste(get.geotop.inpts.keyword.value("SoilMapFile",wpath=wpath,inpts.file=inpts.file,add_wpath=TRUE),".asc",sep="")
elevmapasc <- paste(get.geotop.inpts.keyword.value("DemFile",wpath=wpath,inpts.file=inpts.file,add_wpath=TRUE),".asc",sep="")
landmapasc <- paste(get.geotop.inpts.keyword.value("LandCoverMapFile",wpath=wpath,inpts.file=inpts.file,add_wpath=TRUE),".asc",sep="")
netmapasc <-  paste(get.geotop.inpts.keyword.value("RiverNetwork",wpath=wpath,inpts.file=inpts.file,add_wpath=TRUE),".asc",sep="")


elevmap_hillslope <- ((1:length(soilmap_hillslope))*xres-xres/2)*slope+zdepth
netmap_hillslope <- array(0,length(soilmap_hillslope))
netmap_hillslope[1] <- 1

nrow <- 10

soilmapvalue <- matrix(rep(c(NA,NA,as.numeric(soilmap_hillslope),NA,NA),each=nrow),nrow=nrow)
elevmapvalue <- matrix(rep(c(NA,NA,elevmap_hillslope,NA,NA),each=nrow),nrow=nrow)
netmapvalue <- matrix(rep(c(NA,NA,netmap_hillslope,NA,NA),each=nrow),nrow=nrow)

border <- c(1,2,nrow(soilmapvalue)-1,nrow(soilmapvalue))

soilmapvalue[border,] <- NA
elevmapvalue[border,] <- NA
netmapvalue[border,] <- NA

xstart <- 0
xmin <- xstart-2*xres
xmax <- xmin+ncol(elevmapvalue)*xres

ymin <- 0
ymax <- ymin+nrow(elevmapvalue)*xres

soilmap <- raster(soilmapvalue,xmn=xmin,xmx=xmax,ymn=ymin,ymx=ymax)
elevmap <- raster(elevmapvalue,xmn=xmin,xmx=xmax,ymn=ymin,ymx=ymax)
landmap <- soilmap*0+1
netmap <- raster(netmapvalue,xmn=xmin,xmx=xmax,ymn=ymin,ymx=ymax)

writeRasterxGEOtop(x=soilmap,file=soilmapasc)
writeRasterxGEOtop(x=elevmap,file=elevmapasc)
writeRasterxGEOtop(x=landmap,file=landmapasc)
writeRasterxGEOtop(x=netmap,file=netmapasc)

#### Precipitation data 

rainfall_intensity <- 50 ### mm/hr
rainfall_intensity_mmps <- rainfall_intensity/3600 ### mm/hr
rainfall_duration <- 3*3600 ## seconds



duration <- 12*3600  ## hr 
dt <- 15*60 # 15 minutes, values expressed in seconds
time_counter <- seq(from=0,to=duration,by=dt)

rainfall_depth <- array(0,length(time_counter))
rainfall_depth[time_counter<=rainfall_duration] <- rainfall_intensity_mmps*dt


start <-  get.geotop.inpts.keyword.value("InitDateDDMMYYYYhhmm",date=TRUE,wpath=wpath,inpts.file=inpts.file,tz="GMT")

HeaderDateDDMMYYYYhhmmMeteo <- get.geotop.inpts.keyword.value("HeaderDateDDMMYYYYhhmmMeteo",wpath=wpath,inpts.file=inpts.file)
HeaderIPrec <- get.geotop.inpts.keyword.value("HeaderIPrec",wpath=wpath,inpts.file=inpts.file)
MeteoPrefix <- get.geotop.inpts.keyword.value("MeteoFile",wpath=wpath,inpts.file=inpts.file,add_wpath=TRUE)
meteo <- data.frame( 
        HeaderDateDDMMYYYYhhmmMeteo = start+time_counter,
		TimeCounter=time_counter,
		HeaderIPrec=rainfall_depth)

names(meteo)[names(meteo)=="HeaderDateDDMMYYYYhhmmMeteo"] <- HeaderDateDDMMYYYYhhmmMeteo
names(meteo)[names(meteo)=="HeaderIPrec"] <- HeaderIPrec


index_m <- meteo[,HeaderDateDDMMYYYYhhmmMeteo]

meteo <- meteo[,names(meteo)!=HeaderDateDDMMYYYYhhmmMeteo]

meteo <- as.zoo(meteo)
index(meteo) <- index_m
create.geotop.meteo.files(x=meteo,file_prefix=MeteoPrefix,date_field=HeaderDateDDMMYYYYhhmmMeteo) 
#HeaderIPrec = "Prec"
#


		













