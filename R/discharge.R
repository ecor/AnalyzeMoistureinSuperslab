NULL
#'  Lateral Subsurface Discharge
#' 
#' @param psi  soil presssure head. It is  \code{RasterBrick-class} object.
#' @param hsub surface water depth. It is  \code{RasterBrick-class} object. 
#' @param elev                                                                                                               
#' 
#' 
#' @seealso \code{\link{terrain}}
#' @export 
LateralSubsurfaceDischarge <- function(psi,elevation,slope=NULL,aspect=NULL,soilmap,soiltypes,...) {
	
	
	out <- list(x=psi*NA,y=psi*NA)
	
	nl <- nlayers(psi)
	
	nn <- 
	for (l in nl) {
		
		gradient <- terrain(psi[[l]],opt="slope",unit="tangent",...)+slope
		
		## TO DO 
		
	#	out$x[[l]] <- 
		
		
	 #    out$x[[l]] <- 
		
	}
	
	out <- NULL
	
	
	
	
	
	
	
	return(out)
	
	
	
}











NULL
#'  Lateral Surface Discharge - Runoff














