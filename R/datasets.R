#' Available Quantarctica data sets
#'
#' @param cache_directory string: as for \code{qa_get}
#' @param refresh_cache logical: as for \code{qa_get}
#'
#' @return A tibble with columns \code{id}, \code{name}, \code{source}, and \code{cached}
#'
#' @seealso \code{\link{qa_get}}
#'
#' @examples
#'
#' qa_datasets()
#'
#' @export
qa_datasets <- function(cache_directory, refresh_cache = FALSE, verbose = FALSE) {
    cache_directory <- deal_with_cache_dir(cache_directory, verbose = verbose)
    mirror_dir <- sub("/+$", "", sub("^(http|https|ftp)://", "", qa_mirror())) ## remove protocol prefix and trailing sep
    index_file <- file.path(cache_directory, mirror_dir, "Quantarctica3/Quantarctica3.qgs")
    if (!file.exists(index_file) || refresh_cache) {
        if (!dir.exists(dirname(index_file))) tryCatch(dir.create(dirname(index_file), recursive = TRUE), error = function(e) stop("Could not create cache_directory: ", dirname(index_file)))
        res <- bb_rget(url = paste0(qa_mirror(), "Quantarctica3/Quantarctica3.qgs"), force_local_filename = index_file, use_url_directory = FALSE, verbose = verbose)
    }
    if (file.exists(index_file)) {
        lx <- xml2::read_xml(index_file)
        get_layer_details <- function(z) as.data.frame(as.list(xml2::xml_attrs(z))[c("id", "name", "source")], stringsAsFactors = FALSE)
        lxs <- as_tibble(do.call(rbind, lapply(xml2::xml_find_all(lx, ".//layer-tree-layer"), get_layer_details)))
        lxs$source <- file.path(cache_directory, gsub("^.*Quantarctica3/", "", lxs$source))
        lxs$cached <- vapply(lxs$source, file.exists, FUN.VALUE = TRUE, USE.NAMES = FALSE)
        lxs
    } else {
        warning("something went wrong")
        NULL
    }
}

