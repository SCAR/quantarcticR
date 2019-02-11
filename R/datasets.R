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
    lx <- dataset_detail(name, cache_path = cache_directory, refresh_cache = refresh_cache, verbose = verbose)
    path <- dirname(lx$datasource)
    bb <- bb_source(name = lx$layername,
                    id = paste0("Quantarctica: ", lx$layername),
                    description = "Quantarctica data",
                    doc_url = "http://quantarctica.npolar.no/",
                    citation = paste0("Matsuoka, K., Skoglund, A., & Roth, G. (2018). Quantarctica ", lx$layername, ". Norwegian Polar Institute. https://doi.org/10.21334/npolar.2018.8516e961"),
                    source_url = sub("[/\\]+$", "/", paste0(qa_mirror(), path, "/")), ## ensure trailing sep
                    license = "CC-BY 4.0 International",
                    method = list("bb_handler_rget", level = 2, no_host = TRUE, cut_dirs = 1, accept_download_extra = "(cpg|dbf|prj|qix|shp|shx)$"),
                    ## no_host = TRUE and cut_dirs = 1 so that we drop the hostname/Quantarctica3 part of the directory
                    ##collection_size = 0.6,
                    ##data_group = "Topography")
                    )
    ## add the full path to the main file of this data set
    lx$main_file <- file.path(cache_directory, lx$datasource)
    lx$bb_source <- bb
    class(lx) <- c("qa_dataset", class(lx))
    lx
}


#' Available Quantarctica data sets
#'
#' @param cache_directory string: the cache directory to use. As for the \code{path} parameter to the \code{\link{qa_cache_dir}} function
#' @param refresh_cache numeric: as for \code{qa_get}
#' @param verbose logical: show progress messages?
#'
#' @return A tibble with columns \code{layername}, \code{type}, and \code{cached}
#'
#' @seealso \code{\link{qa_get}}
#'
#' @examples
#' \dontrun{
#'   qa_datasets()
#' }
#'
#' @export
qa_datasets <- function(cache_directory = qa_cache_dir(), refresh_cache = 0, verbose = FALSE) {
    cache_directory <- resolve_cache_dir(cache_directory) ## convert "session" or "persistent" to actual paths, if needed
    lxs <- dataset_index(cache_path = cache_directory, refresh_cache = refresh_cache, verbose = verbose)
    if (!is.null(lxs)) {
        lxs$cached <- vapply(lxs$datasource, file.exists, FUN.VALUE = TRUE, USE.NAMES = FALSE)
        lxs[, c("layername", "type", "cached")] ## drop the datasource column
    } else {
        warning("something went wrong")
        NULL
    }
}

## internal function to get dataset index
## cache_path must be an actual path, not "session" or "persistent"

dataset_index <- function(cache_path, refresh_cache = 0, verbose = FALSE) {
    index_file <- fetch_dataset_index(cache_path = cache_path, refresh_cache = refresh_cache, verbose = verbose)
    lx <- xml2::read_xml(index_file)
    lxs <- as_tibble(do.call(rbind, lapply(xml2::xml_find_all(lx, ".//layer-tree-layer"), get_layer_details)))
    lxs <- setNames(lxs, c("layername", "datasource"))
    ## clean bad sources
    for (i in seq_along(lxs$datasource)) {
        if (!grepl("\\.[a-z0-9]$", lxs$datasource[i])) {
            lxs$datasource[i] <- strsplit(lxs$datasource[i], "\\|")[[1]][1]
        }
    }
    lxs$datasource <- sub("^.*Quantarctica3/", "", lxs$datasource)
    lxs_type <- rep("unknown", nrow(lxs))
    lxs_type[grepl("shp$", lxs$datasource, ignore.case = TRUE)] <- "shapefile"
    lxs_type[grepl("(tif|jp2|vrt)$", lxs$datasource, ignore.case = TRUE)] <- "raster"
    lxs$type <- lxs_type
    lxs$datasource <- sub("^\\./", "", lxs$datasource) ## strip leading ./ on path
    lxs$datasource <- file.path(cache_path, lxs$datasource)
    ## remove duplicate entries: there are three. See https://github.com/SCAR-sandpit/quantarcticR/issues/14
    lxs[!duplicated(lxs$layername), ]
}
get_layer_details <- function(z) as.data.frame(as.list(xml2::xml_attrs(z))[c("name", "source")], stringsAsFactors = FALSE)

dataset_detail <- function(name, cache_path, refresh_cache = 0, verbose = FALSE) {
    index_file <- fetch_dataset_index(cache_path = cache_path, refresh_cache = refresh_cache, verbose = verbose)
    lx <- xml2::read_xml(index_file)
    ## if we did not need to pare out duplicate layer names, we could just do:
    ##dx <- xml2::xml_find_all(lx, paste0("//projectlayers/maplayer[layername = '", name, "']"))
    ##if (length(dx) < 1) {
    ##    ## try case-insensitive match on name
    ##    dx <- xml2::xml_find_all(lx, paste0("//projectlayers/maplayer[lower-case(@layername) = '", tolower(name), "']"))
    ##}
    ## but for now, need to get rid of duplicates (until these are removed from the index file by the Quantarctica maintainers)
    lx <- xml2::xml_find_all(lx, "//projectlayers/maplayer")
    lyrs <- sapply(lx, function(z) xml2::xml_text(xml2::xml_child(z, search = "layername")))
    idx <- !is.na(lyrs) & !duplicated(lyrs) & lyrs == name
    if (sum(idx) < 1) {
        ## try case-insensitive match on name
        idx <- !is.na(lyrs) & !duplicated(lyrs) & tolower(lyrs) == tolower(name)
    }
    dx <- lx[idx]

    if (length(dx) < 1) {
        stop("no matching data set found")
    } else if (length(dx) > 1) {
        stop("multiple matching data sets found")
    } else {
        clean_layer(xml2::as_list(dx))
    }
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
    ld <- l[,c("layername", "datasource")]
    if (!grepl("\\.[a-z0-9]$", ld$datasource)) {
        ld$datasource <- strsplit(ld$datasource, "\\|")[[1]][1]
    }
    ld$datasource <- sub("^\\./", "", ld$datasource) ## strip leading ./ on path
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
