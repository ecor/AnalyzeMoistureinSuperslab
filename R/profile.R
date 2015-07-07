NULL
#' Soil Variable weather Profile
#' 
#'  Vertical or Slope-Normal Integration/Aggregation of soil water content 
#' 
#' 
#' @param map soil variable \code{RasterBrick-class} object
#' @param points ....
# @param psi soil pressure head content \code{RasterBrick-class} object
#@param layers layer thickness. It is a scalar or a vector whose length is equal to the number of \code{theta} layers.
# @param psi_thres threshold value.  It is 0 for separating satureted and unsatureted zones, or \code{NA} if the two zones are not distinguished. 
# @param fun function aggregation 
# @param na.rm a logical value for \code{fun} indicating whether NA values should be stripped before the computation proceeds.
# @param comparison comparison operator for \code{psi} .See \code{\link{Comparison}}. Default is the first element of \code{c("<",">","<=",">=","==","!=")}
# @param indices see \code{\link{stackApply}}
# @param ... further aguments for \code{\link{stackApply}}
#' @export
#' @import raster
#' 
#' @examples 
#' 
#' data(PsiTheta)
#' 
#'  t <- 5
#'  map <- psi[[t]]
#'  yv <- (ymax(map)+ymin(map))/2
#'  points <- data.frame(x=c(32,41),y=yv,id=c("A","B"))
#' 
#' mapProfile <- SoilVariableProfile(map,points[,c("x","y")],names=as.character(points$id))
#' 
#' plot(mapProfile[,1],c(100:1),type="l")
#' lines(mapProfile[,1],c(100:1))
#' 
#' 
#' 

SoilVariableProfile <- function(x,points,names=NULL...) {
	
	if (is.data.frame(points)) {
		
		
		points <- cellFromXY(x,points)
		
		
	}
	
	
	out <- map[points]
	out <- t(out)
	if (!is.null(names)) {
		
		colnames(out) <- names
		
	}
	
	return(out)
	
}


