#' Get or set the directory used to cache Quantarctica data
#'
#' The cache directory is used to store data locally, so that they can be used offline later. If called with no arguments (i.e. \code{qa_cache_dir()}), this function returns the current cache directory. By default, this is a per-session temporary directory. Calling with a \code{path} argument will set the cache directory to that path.
#'
#' @param path string: (optional) Values can be "session" (a per-session temporary directory will be used, default), "persistent" (the directory returned by \code{rappdirs::user_cache_dir} will be used), or a string giving the path to the directory to use. Use \code{NULL} for no caching. An attempt will be made to create the cache directory if it does not exist
#' @param verbose logical: show progress messages?
#'
#' @return The path to the cache directory
#'
#' @seealso \code{\link{qa_get}}
#'
#' @examples
#'
#' ## return the current cache directory
#' qa_cache_dir()
#'
#' ## set the cache directory to a location that persists across
#' ##  user sessions
#' qa_cache_dir("persistent")
#'
#' ## switch to a per-session cache
#' qa_cache_dir("session")
#'
#' @export
qa_cache_dir <- function(path, verbose = FALSE) {
    if (missing(path)) {
        ## return the current cache_directory
        cd <- qa_opt("cache_dir")
        if (is.na(cd)) {
            ## cache directory has not yet been set
            ## default to "session"
            return(qa_cache_dir("session", verbose = verbose))
        } else {
            return(cd)
        }
    }
    if (is.null(path)) {
        qa_set_opt(cache_dir = NULL)
        return(NULL)
#        ## save to per-request temp dir
#        path <- tempfile(pattern = "quantarcticR_")
    }
    assert_that(is.string(path))
    create_recursively <- FALSE ## default to this for safety
    if (tolower(path) == "session") {
        path <- qa_opt("session_cache_dir")
    } else if (tolower(path) == "persistent") {
        path <- qa_opt("persistent_cache_dir")
        create_recursively <- TRUE ## necessary here
    } else {
        ## path was specified
        ## TODO: warn if the datasets index file does not exist here?
    }
    if (!dir.exists(path)) {
        if (verbose) message("creating data cache directory: ", path, "\n")
        ok <- dir.create(path, recursive = create_recursively)
        if (!ok) stop("could not create cache directory: ", path)
    }
    path <- sub("[/\\]+$", "", path) ## remove trailing file sep
    qa_set_opt(cache_dir = path)
    path
}
