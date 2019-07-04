#' Get or set the directory used to cache Quantarctica data
#'
#' The cache directory is used to store data locally, so that they can be used offline later. If called with no arguments (i.e. \code{qa_cache_dir()}), this function returns the current cache directory. By default, this is a per-session temporary directory. Calling with a \code{path} argument will set the cache directory to that path.
#'
#' @param path string: (optional) Values can be "session" (a per-session temporary directory will be used, default), "persistent" (the directory returned by \code{rappdirs::user_cache_dir} will be used), or a string giving the path to the directory to use. An attempt will be made to create the cache directory if it does not exist
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
    path_was_supplied <- !missing(path)
    if (!path_was_supplied) {
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
    assert_that(is.string(path))
    create_recursively <- tolower(path) == "persistent" ## FALSE if path is "session" or ann actual path (safer not to be recursive), but recursive is necessary for "persistent"
    path <- resolve_cache_dir(path)

    if (path_was_supplied) {
        ## check that the user hasn't provided the parent or child dir
        maybe_parent <- tryCatch(any(vapply(fs::dir_ls(path = path, type = "directory"), function(z) file.exists(file.path(z, qa_index_filename())), FUN.VALUE = TRUE)), error = function(e) FALSE)
        if (maybe_parent) warning("The Quantarctica index file exists in a child directory of the cache path you have supplied. Check that you have supplied the correct path")
        maybe_child <- tryCatch(file.exists(file.path(path, "..", qa_index_filename())), error = function(e) FALSE)
        if (maybe_child) warning("The Quantarctica index file exists in the parent directory of the cache path you have supplied. Check that you have supplied the correct path")
    }

    if (!dir.exists(path)) {
        if (verbose) message("creating data cache directory: ", path, "\n")
        ok <- dir.create(path, recursive = create_recursively)
        if (!ok) stop("could not create cache directory: ", path)
    }
    qa_set_opt(cache_dir = path)
    path
}

## internal function that will take the cache path input and resolve it to an actual directory path on the system
## path can take special values of "session" or "persistent", which are resolved to the values held in the options; otherwise path is assumed to be a path and returned (with trailing file separator removed)
resolve_cache_dir <- function(path) {
    assert_that(is.string(path), !is.na(path))
##    cat("input path: ", path, " --- ")
    if (tolower(path) == "session") {
        path <- qa_opt("session_cache_dir")
    } else if (tolower(path) == "persistent") {
        path <- qa_opt("persistent_cache_dir")
    } else {
        ## path was specified
    }
##    cat("resolved to: ", path, "\n")
    sub("[/\\]+$", "", path) ## remove trailing file sep
}
