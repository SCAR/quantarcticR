#' Fetch a Quantarctica data set
#'
#' @param dataset string or tibble: the name of the data set or a tibble as returned by \code{qa_dataset}
#' @param refresh_cache numeric: 0=do not overwrite existing files, 1=overwrite if the remote file is newer than the local copy, 2=always overwrite existing files
#' @param verbose logical: show progress messages?
#'
#' @return TBD
#'
#' @export
qa_get <- function(dataset, refresh_cache = 0, verbose = FALSE) {
    assertthat::assert_that(refresh_cache %in% c(0,1,2), !is.na(refresh_cache), assertthat::is.count(refresh_cache))
    assertthat::assert_that(assertthat::is.flag(verbose), !is.na(verbose))
    cache_directory <- qa_cache_dir()
    if (is.string(dataset)) dataset <- qa_dataset(name = dataset, refresh_cache = refresh_cache, verbose = verbose)
    out <- bb_get(dataset, local_file_root = cache_directory, clobber = refresh_cache, verbose = verbose)
    ## add absolute path to main file
    out$main_file <- file.path(cache_directory, dataset$main_file)
    out
}




