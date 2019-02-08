#' Retrieve details of a Quantarctica data set
#'
#' @param name string: the name of the data set
#' @param refresh_cache numeric: 0 = do not overwrite existing files, 1 = overwrite if the remote file is newer than the local copy, 2 = always overwrite existing files
#' @param cache_directory string: the cache directory to use. As for the \code{path} parameter to the \code{\link{qa_cache_dir}} function
#' @param verbose logical: show progress messages?
#'
#' @return A tibble
#'
#' @export
qa_dataset <- function(name, cache_directory = qa_cache_dir(), refresh_cache = 0, verbose = FALSE) {
    cache_directory <- resolve_cache_dir(cache_directory) ## convert "session" or "persistent" to actual paths, if needed
    ## find name in datasets index
    lx <- dataset_index(cache_path = cache_directory, refresh_cache = refresh_cache, verbose = verbose, expand_source = FALSE)
    idx <- lx$layername == name
    if (sum(idx) < 1) {
        ## try case-insensitive
        idx <- tolower(lx$layername) == tolower(name)
    }
    if (sum(idx) < 1) {
        stop("no matching data set found")
    } else if (sum(idx) > 1) {
        stop("multiple matching data sets found")
    } else {
        path <- dirname(lx$datasource[idx])
    }
    out <- bb_source(name = lx$layername[idx],
                     id = paste0("Quantarctica: ", lx$layername[idx]),
                     description = "Quantarctica data",
                     doc_url = "http://quantarctica.npolar.no/",
                     citation = paste0("Matsuoka, K., Skoglund, A., & Roth, G. (2018). Quantarctica ", lx$layername[idx], ". Norwegian Polar Institute. https://doi.org/10.21334/npolar.2018.8516e961"),
                     source_url = sub("[/\\]+$", "/", paste0(qa_mirror(), path, "/")), ## ensure trailing sep
                     license = "CC-BY 4.0 International",
                     method = list("bb_handler_rget", level = 2, no_host = TRUE, cut_dirs = 1, accept_download_extra = "(cpg|dbf|prj|qix|shp|shx)$"),
                     ## no_host = TRUE and cut_dirs = 1 so that we drop the hostname/Quantarctica3 part of the directory
                     postprocess = NULL##list("bb_unzip")##,
                     ##collection_size = 0.6,
                     ##data_group = "Topography")
                     )
    ## add the full path to the main file of this data set
    out$main_file <- file.path(cache_directory, lx$datasource[idx])
    out
}


#' Available Quantarctica data sets
#'
#' @param cache_directory string: the cache directory to use. As for the \code{path} parameter to the \code{\link{qa_cache_dir}} function
#' @param refresh_cache numeric: as for \code{qa_get}
#' @param verbose logical: show progress messages?
#'
#' @return A tibble with columns \code{id}, \code{name}, \code{source}, and \code{cached}
#'
#' @seealso \code{\link{qa_get}}
#'
#' @examples
#'
#' \dontrun{
#' qa_datasets()
#' }
#'
#' @export
qa_datasets <- function(cache_directory = qa_cache_dir(), refresh_cache = 0, verbose = FALSE) {
    cache_directory <- resolve_cache_dir(cache_directory) ## convert "session" or "persistent" to actual paths, if needed
    lxs <- dataset_index(cache_path = cache_directory, refresh_cache = refresh_cache, verbose = verbose, expand_source = TRUE)
    if (!is.null(lxs)) {
        lxs$cached <- vapply(lxs$datasource, file.exists, FUN.VALUE = TRUE, USE.NAMES = FALSE)
        lxs
    } else {
        warning("something went wrong")
        NULL
    }
}

## internal function to get dataset index
## cache_path must be an actual path, not "session" or "persistent"
dataset_index <- function(cache_path, refresh_cache = 0, verbose = FALSE, expand_source = TRUE) {
    index_file <- fetch_dataset_index(cache_path = cache_path, refresh_cache = refresh_cache, verbose = verbose)
    lxs <- dataset_qgs_to_tibble(index_file)
    if (expand_source) lxs$datasource <- file.path(cache_path, lxs$datasource)
    lxs
}

## cache_path must be an actual path, not "session" or "persistent"
fetch_dataset_index <- function(cache_path, refresh_cache = 0, verbose = FALSE) {
    index_file <- file.path(cache_path, "Quantarctica3.qgs")
    if (file.exists(index_file) && refresh_cache < 1) return(index_file) ## don't re-fetch if not needed
    if (!dir.exists(dirname(index_file))) tryCatch(dir.create(dirname(index_file), recursive = TRUE), error = function(e) stop("Could not create cache directory: ", dirname(index_file)))
    res <- bb_rget(url = paste0(qa_mirror(), "Quantarctica3.qgs"), force_local_filename = index_file, use_url_directory = FALSE, verbose = verbose, clobber = refresh_cache)
    if (file.exists(index_file)) {
        index_file
    } else {
        stop("could not retrieve dataset index file")
    }
}

## internal function to clean layer data
clean_layer <- function(layer) {
    l <- as_tibble(t(unlist(layer)))
    ld <- l[,c("id", "datasource", "layername")]
    ld$layer_attributes <- ifelse(any(grepl("pipe", names(layer))),
                                  list(unlist(c(lapply(layer$pipe, attributes), attributes(layer)[-1]))),
                                  list(attributes(layer)[-1])
    )
    ld$srs_attributes <- list(l[c("srs.spatialrefsys.proj4", "srs.spatialrefsys.srsid",
                                  "srs.spatialrefsys.authid", "srs.spatialrefsys.description")])
    ld$provider <- if ("provider" %in% names(l)) l$provider else NA_character_
    ld$abstract <- if ("abstract" %in% names(l)) l$abstract else NA_character_
    if ("extent" %in% names(layer)) {
        ext <- unlist(layer$extent)
        class(ext) <- "numeric" ## from char to numeric
    } else {
        ext <- NULL
    }
    ld$extent <- list(ext)
    ld
}

## internal function to turn Quantarctica3.qgs file into tibble
## parsing the xml file using as_list is slow, so we might want to re-write this using something faster
## but in the meantime, let's just cache the results using memoise, so the xml only needs to be parsed once per session
##
## this is the actual conversion code
## the lx input here should be an xml_document object
do_convert_qgs_xml <- function(lx) {
    lx <- xml2::as_list(lx)[["qgis"]][["projectlayers"]]
    lxs <- do.call(rbind, lapply(lx, clean_layer))
    rownames(lxs) <- NULL
    ## clean bad sources
    for (i in seq_along(lxs$datasource)) {
        if (!grepl("\\.[a-z0-9]$", lxs$datasource[i])) {
            lxs$datasource[i] <- strsplit(lxs$datasource[i], "\\|")[[1]][1]
        }
    }
    lxs$datasource <- sub("^\\./", "", lxs$datasource) ## strip leading ./ on path
    ## remove duplicate entries: there are three. See https://github.com/SCAR-sandpit/quantarcticR/issues/14
    lxs <- lxs[!duplicated(lxs$layername), ]
    lxs
}

## this is a memoised version of that conversion function
m_do_convert_qgs_xml <- memoise(do_convert_qgs_xml)

## and this is the function that gets called, which in turn calls the memoised conversion function
dataset_qgs_to_tibble <- function(index_file) {
    lx <- xml2::read_xml(index_file)
    m_do_convert_qgs_xml(lx)
}
