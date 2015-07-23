NULL
#'  Craetion of a Physical Variable Map from a Catagory Map
#' 
#' This functions creates physicalvariable maps from catagorical information, e.g. a map of hydraulic conductivity from the map of Soil Categories. 
#' 
#' @param x variable to map
#' @param map catagory input map, i.e. soiltype maps or related GEOtop keyword. 
#' @param metacat list of dataframe containingcatagory definitions, e. g. the list of soil properties for each class or related GEOtop keyword. 
#' @param header header sting using in \code{geotop.inpts} file. Default is \code{"Header"}
#' @param ... further arguments for \code{\link{get.geotop.inpts.keyword.value}} such as \code{wpath} or \code{inpts.file}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       s
#' 
#' 
#' wpath <- system.file("geotop_simulation",package="AnalyzeMoistureInSuperslab")
#' x <- "Alpha"
#' b <- SoilPropertyMap(x,wpath=wpath)
#' 
#' ### BELOW a list of some keywords used for soil property variables
#' #HeaderSoilDz	=	"Dz"
#' #HeaderLateralHydrConductivity	=	"Kh"
#' #HeaderNormalHydrConductivity	=	"Kv"
#' #HeaderThetaRes	=	"vwc_r"
#' #HeaderWiltingPoint	=	"vwc_w"
#' #HeaderFieldCapacity	=	"vwc_fc"
#' #HeaderThetaSat	=	"vwc_s"
#' #HeaderAlpha	=	"alpha"
#' #HeaderN	=	"n"
#' #HeaderSpecificStorativity	=	"stor"
#' #HeaderKthSoilSolids	=	"Kth"
#' #HeaderCthSoilSolids	=	"Cth"
#' #HeaderSoilInitPres = "InitPsi"

SoilPropertyMap <- function(x,map="SoilMapFile",metacat="SoilParFile",header="Header",names=NULL,...) {
	
	
	if (is.character(map)) {
		
		
		map <- get.geotop.inpts.keyword.value(map[1],raster=TRUE,...)
		geotop <- TRUE
		
		
	} else {
		
		geotop <- FALSE
	}
	level <- 1:max(unique(map)) ## map must be contained values ranged from 1 to nsoilclass
	
	if (is.character(metacat)) {
		
		metacat <- get.geotop.inpts.keyword.value(metacat,data.frame=TRUE,level=level,...)
		geotop <- TRUE
		
	} else {
		
		geotop <- FALSE
	}
	
	if (geotop==TRUE) {
		
		
		xheader <- get.geotop.inpts.keyword.value(paste("Header",x,sep=""),add_wpath=FALSE,...)
		
	} else {
		
		xheader <- x
	}
	
	if (is.data.frame(metacat)) metacat <- list(metacat)
	
	nlayer <- nrow(metacat[[1]])
	
	out <- brick(lapply(X=as.list(array(1:nlayer,nlayer)),FUN=function(x,map,metacat,xheader){
				
				values <- unlist(lapply(X=metacat,FUN=function(s,l,xheader) { s[l,xheader]},l=x,xheader=xheader))
				
				
				out <- map
				out[!is.na(map)] <- values[map[!is.na(map)]]
				return(out)
				
				
				
			},map=map,metacat=metacat,xheader=xheader))
	
  
	
	if (!is.null(names)) names(out) <- names
	
	return(out)
	
	
}
