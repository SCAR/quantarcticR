#' Fetch a Quantarctica data set
#'
#' @param dataset string or tibble: the name of the data set or a tibble as returned by \code{qa_dataset}
#' @param refresh_cache logical: if TRUE, and data already exist in the cache_directory, they will be refreshed. If FALSE, the cached data will be used
#' @param verbose logical: show progress messages?
#'
#' @return TBD
#'
#' @export
qa_get <- function(dataset, refresh_cache = FALSE, verbose = FALSE) {
    assert_that(is.flag(refresh_cache), !is.na(refresh_cache))
    assert_that(is.flag(verbose), !is.na(verbose))
    cache_directory <- qa_cache_dir()
    if (is.string(dataset)) dataset <- qa_dataset(name = dataset, refresh_cache = refresh_cache, verbose = verbose)
    out <- bb_get(dataset, local_file_root = cache_directory, clobber = as.integer(refresh_cache), verbose = verbose)
    ## add absolute path to main file
    out$main_file <- file.path(cache_directory, dataset$main_file)
    out
}




