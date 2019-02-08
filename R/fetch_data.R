#' Fetch a Quantarctica data set
#'
#' @param dataset string or tibble: the name of the data set or a tibble as returned by \code{qa_dataset}
#' @param refresh_cache numeric: 0 = do not overwrite existing files, 1 = overwrite if the remote file is newer than the local copy, 2 = always overwrite existing files
#' @param cache_directory string: the cache directory to use. As for the \code{path} parameter to the \code{\link{qa_cache_dir}} function
#' @param verbose logical: show progress messages?
#' @param shapefile_reader function: function to use to read shapefiles. By default this is \code{raster::shapefile}
#' @param raster_reader function: function to use to read raster files (TIFF, JP2, VRT). By default this is \code{raster::raster}
#'
#' @return TBD
#'
#' @export
qa_get <- function(dataset, cache_directory = qa_cache_dir(), refresh_cache = 0, verbose = FALSE, shapefile_reader, raster_reader) {
    assert_that(refresh_cache %in% c(0, 1, 2), is.scalar(refresh_cache))
    assert_that(is.flag(verbose), !is.na(verbose))
    if (missing(shapefile_reader)) {
        shapefile_reader <- raster::shapefile
    }
    assert_that(is.function(shapefile_reader))
    if (missing(raster_reader)) {
        raster_reader <- raster::raster
    }
    assert_that(is.function(raster_reader))
    cache_directory <- resolve_cache_dir(cache_directory) ## convert "session" or "persistent" to actual paths, if needed
    if (is.string(dataset)) dataset <- qa_dataset(name = dataset, cache_directory = cache_directory, refresh_cache = refresh_cache, verbose = verbose)
    out <- bb_get(dataset$bb_source, local_file_root = cache_directory, clobber = refresh_cache, verbose = verbose)
    ## TODO check success here
    out$main_file <- dataset$main_file
    if (grepl("shp$", dataset$main_file, ignore.case = TRUE)) {
        shapefile_reader(dataset$main_file)
    } else if (grepl("(tif|jp2|vrt)$", dataset$main_file, ignore.case = TRUE)) {
        raster_reader(dataset$main_file)
    } else {
        out
    }
}
