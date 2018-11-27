## functions that appeared at some point but probably no longer needed
## not going through formal deprecation process on these given the early development phase of the package

# Find the shapefiles amongst a set of files
#
# @param result : as returned by \code{qa_get}
#
# @return A character vector of paths to shapefiles
#
# @export
qa_find_shapefile <- function(result) {
    f <- result$files[[1]]
    f[grep("shp$", f$file), ]$file
}
