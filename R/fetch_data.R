## internal helper function
build_src <- function(name, cache_directory) {
    q_mirror <- file.path(sub("/$", "", qa_mirror()), "Quantarctica3")

    ## find name in datasets index
    lx <- dataset_index(cache_directory, refresh_cache = FALSE, verbose = FALSE)
    idx <- lx$name == name
    if (sum(idx) < 1) {
        ## try case-insensitive
        idx <- tolower(lx$name) == tolower(name)
    }
    if (sum(idx) < 1) {
        stop("no matching data set found")
    } else if (sum(idx) > 1) {
        stop("multiple matching data sets found")
    } else {
        path <- dirname(lx$source[idx])
    }
    bb_source(
        name = name,
        id = paste0("Quantarctica: ", name),
        description = "Quantarctica data",
        doc_url = "http://quantarctica.npolar.no/",
        citation = "Matsuoka, K., Skoglund, A., & Roth, G. (2018). Quantarctica [Data set]. Norwegian Polar Institute. https://doi.org/10.21334/npolar.2018.8516e961",
        source_url = sub("//$", "/", paste0(file.path(q_mirror, path), "/")),
        license = "CC-BY 4.0 International",
        method = list("bb_handler_rget", level = 2, accept_download_extra = "(cpg|dbf|prj|qix|shp|shx)$"),
        postprocess = NULL##list("bb_unzip")##,
        ##collection_size = 0.6,
        ##data_group = "Topography")
    )
}



#' Fetch a Quantarctica data set
#'
#' @param dataset string: the name of the data set
#' @param cache_directory string: (optional) cache the data locally in this directory, so that they can be used offline later. Values can be "session" (a per-session temporary directory will be used, default), "persistent" (the directory returned by \code{rappdirs::user_cache_dir} will be used), or a string giving the path to the directory to use. Use \code{NULL} for no caching. An attempt will be made to create the cache directory if it does not exist. Use \code{refresh_cache = TRUE} to refresh the cached data if necessary
#' @param refresh_cache logical: if TRUE, and data already exist in the cache_directory, they will be refreshed. If FALSE, the cached data will be used
#' @param verbose logical: show progress messages?
#'
#' @return TBD
#'
#' @export
qa_get <- function(dataset, cache_directory, refresh_cache = FALSE, verbose = FALSE) {
    assert_that(is.flag(refresh_cache), !is.na(refresh_cache))
    assert_that(is.flag(verbose), !is.na(verbose))
    cache_directory <- deal_with_cache_dir(cache_directory)
    mysrc <- build_src(dataset, cache_directory)
    bb_get(mysrc, local_file_root = cache_directory, clobber = as.integer(refresh_cache), verbose = verbose)
}

## internal function to
deal_with_cache_dir <- function(cache_directory, verbose = FALSE) {
    if (missing(cache_directory)) cache_directory <- "session"
    if (is.null(cache_directory)) {
        ## save to per-request temp dir
        cache_directory <- tempfile(pattern = "quantarcticR_")
        refresh_cache <- 0L
    }
    assert_that(is.string(cache_directory))
    create_recursively <- FALSE ## default to this for safety
    if (tolower(cache_directory) == "session") {
        cache_directory <- qa_opt("session_cache_dir")
    } else if (tolower(cache_directory) == "persistent") {
        cache_directory <- qa_opt("persistent_cache_dir")
        create_recursively <- TRUE ## necessary here
    }
    if (!dir.exists(cache_directory)) {
        if (verbose) message("creating data cache directory: ", cache_directory, "\n")
        ok <- dir.create(cache_directory, recursive = create_recursively)
        if (!ok) stop("could not create cache directory: ", cache_directory)
    }
    cache_directory <- sub("[/\\]+$", "", cache_directory) ## remove trailing file sep
    cache_directory
}

#' Find the shapefiles amongst a set of files
#'
#' @param result : as returned by \code{qa_get}
#'
#' @return A character vector of paths to shapefiles
#'
#' @export
qa_find_shapefile <- function(result) {
    f <- result$files[[1]]
    f[grep("shp$", f$file), ]$file
}



