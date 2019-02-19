#' Fetch a Quantarctica data set
#'
#' @param dataset string or tibble: the name of the data set or a tibble as returned by \code{qa_dataset}
#' @param refresh_cache numeric: 0 = do not overwrite existing files, 1 = overwrite if the remote file is newer than the local copy, 2 = always overwrite existing files
#' @param cache_directory string: the cache directory to use. As for the \code{path} parameter to the \code{\link{qa_cache_dir}} function
#' @param verbose logical: show progress messages?
#' @param shapefile_reader function: function to use to read shapefiles. By default this is \code{raster::shapefile}
#' @param raster_reader function: function to use to read raster files (TIFF, JP2, VRT). By default this is \code{raster::raster}
#'
#' @return By default, an object of class SpatialPolygonsDataFrame (for shapefile layers) or RasterLayer (for raster layers). Objects of other classes may be returned if non-default \code{shapefile_reader} or \code{raster_reader} functions are used
#'
#' @export
qa_get <- function(dataset, cache_directory = qa_cache_dir(), refresh_cache = 0, verbose = FALSE, shapefile_reader, raster_reader) {
    assert_that(refresh_cache %in% c(0, 1, 2), is.scalar(refresh_cache))
    assert_that(is.flag(verbose), !is.na(verbose))
    if (is.string(dataset)) dataset <- qa_dataset(name = dataset, cache_directory = cache_directory, refresh_cache = refresh_cache, verbose = verbose)
    shapefile_reader_specified <- !missing(shapefile_reader)
    raster_reader_specified <- !missing(raster_reader)
    if (!shapefile_reader_specified) {
        shapefile_reader <- raster::shapefile
    } else {
        ## if the user specified ONLY a shapefile reader, and the requested layer isn't a shapefile, let them know
        if (!raster_reader_specified && dataset$type != "shapefile") warning("You have specified a shapefile_reader but the requested dataset is not a shapefile. Did you mean to specify a raster_reader?")
    }
    assert_that(is.function(shapefile_reader))
    if (!raster_reader_specified) {
        raster_reader <- raster::raster
    } else {
        ## if the user specified ONLY a raster reader, and the requested layer isn't a raster, let them know
        if (!shapefile_reader_specified && dataset$type != "raster") warning("You have specified a raster_reader but the requested dataset is not a raster. Did you mean to specify a shapefile_reader?")
    }
    assert_that(is.function(raster_reader))
    cache_directory <- resolve_cache_dir(cache_directory) ## convert "session" or "persistent" to actual paths, if needed
    out <- bb_get(dataset$bb_source, local_file_root = cache_directory, clobber = refresh_cache, verbose = verbose)
    ## TODO check success here
    out$main_file <- dataset$main_file
    if (dataset$type == "shapefile") {
        shapefile_reader(dataset$main_file)
    } else if (dataset$type == "raster") {
        raster_reader(dataset$main_file)
    } else {
        out
    }
}
