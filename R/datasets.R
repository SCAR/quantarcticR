#' Retrieve details of a Quantarctica data set
#'
#' @param name string: the name of the data set
#' @param refresh_cache numeric: 0 = do not overwrite existing files, 1 = overwrite if the remote file is newer than the local copy, 2 = always overwrite existing files
#' @param cache_directory string: the cache directory to use. As for the \code{path} parameter to the \code{\link{qa_cache_dir}} function
#' @param verbose logical: show progress messages?
#'
#' @return A tibble
#' @examples
#' \dontrun{
#'   dsx <- qa_dataset("ALBMAP Bed/bathymetry elevation (5km)")
#' }
#' @export
qa_dataset <- function(name, cache_directory = qa_cache_dir(), refresh_cache = 0, verbose = FALSE) {
    cache_directory <- resolve_cache_dir(cache_directory) ## convert "session" or "persistent" to actual paths, if needed
    ## find name in datasets index
    lx <- dataset_detail(name, cache_path = cache_directory, refresh_cache = refresh_cache, verbose = verbose)
    path <- dirname(lx$datasource) ## worst case, we'll grab everything in this directory
    ## refine what we download, if possible
    if (grepl("\\.shp$", tolower(lx$datasource)) && identical(lx$type, "shapefile")) {
        ## for shapefiles, only download files matching the same name (ignoring file extension) as the .shp file
        accept_download <- paste0(fs::path_ext_remove(basename(lx$datasource)), "\\.[^\\.]+$")
        ade <- character()
    } else if (grepl("\\.(tif[f]?|jp2)$", tolower(lx$datasource)) && identical(lx$type, "raster")) {
        ## if it's a tif or jp2 file, then we only need that one .tif file
        accept_download <- basename(lx$datasource)
        ## note that this will also download e.g. filename.tif.aux.xml files, but that's OK
        ade <- character()
    } else {
        accept_download <- bowerbird::bb_rget_default_downloads()
        ade <- "(jp2|vrt|ovr|jpg|jgw|cpg|dbf|prj|qix|shp|shx|xml)$"
    }
    ## the only other type (i.e. dataset$main_file extension) is .vrt
    ## these are virtual files that point to other files, and we can't know what they are without downloading the .vrt file
    ## but we just assume that the required files are kept in the same directory as the .vrt file
    bb <- bb_source(name = lx$layername,
                    id = paste0("Quantarctica: ", lx$layername),
                    description = "Quantarctica data",
                    doc_url = "http://quantarctica.npolar.no/",
                    citation = paste0("Matsuoka, K., Skoglund, A., & Roth, G. (2018). Quantarctica ", lx$layername, ". Norwegian Polar Institute. https://doi.org/10.21334/npolar.2018.8516e961"),
                    source_url = sub("[/\\]+$", "/", paste0(qa_mirror(), path, "/")), ## ensure trailing sep
                    license = "CC-BY 4.0 International",
                    method = list("bb_handler_rget", level = 1, no_host = TRUE, cut_dirs = 1, accept_download = accept_download, accept_download_extra = ade)
                    ## no_host = TRUE and cut_dirs = 1 so that we drop the hostname/Quantarctica3 part of the directory
                    ##collection_size = tryCatch(as.numeric(lx$download_size)/1024^3, error = function(e) NA_real_)
                    ##data_group = "Topography")
                    )
    ## add the full path to the main file of this data set
    lx$main_file <- file.path(cache_directory, lx$datasource)
    lx$bb_source <- bb
    class(lx) <- c("qa_dataset", class(lx))
    lx
}

#' @method print qa_dataset
#' @export
print.qa_dataset <- function(x, ...) {
    ## as a placeholder, we'll just print the dataset object as a data.frame, but hide the bb_source component
    temp <- x
    message("This Quantarctica dataset is made available under a ",temp$bb_source$license," license.\n")
    message("If the abstract provides a specific citation for this dataset, please use the citation in the abstract: \n",temp$abstract,"\n\n" )
    message("Otherwise cite as: ", temp$bb_source$citation)
    class(temp) <- setdiff(class(temp), "qa_dataset")
    dplyr::glimpse(temp)
}

#' Available Quantarctica data sets
#'
#' @param cache_directory string: the cache directory to use. As for the \code{path} parameter to the \code{\link{qa_cache_dir}} function
#' @param refresh_cache numeric: as for \code{qa_get}
#' @param verbose logical: show progress messages?
#'
#' @return A tibble with columns \code{layername}, \code{main_file}, \code{type}, \code{cached}, and \code{download_size}
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
        ## rename datasource to main_file for consistency with qa_dataset
        names(lxs)[names(lxs) == "datasource"] <- "main_file"
        ## add download_size information, which has been pre-cached in the layer_sizes internal data object
        lxs <- merge(lxs, layer_sizes, all.x = TRUE, sort = FALSE)
        lxs$download_size <- fs::as_fs_bytes(lxs$download_size)
        as_tibble(lxs)
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
    lxs$type <- type_from_filename(lxs$datasource)
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
        xmll <- xml2::as_list(dx)
        dx <- clean_layer(xmll)
        dx$palette <- list(get_layer_palette(xmll))
        dx$type <- type_from_filename(dx$datasource)
        ## add download_size information, which has been pre-cached in the layer_sizes internal data object
        szidx <- which(layer_sizes$layername == dx$layername)
        this_size <- if (length(szidx) == 1) layer_sizes$download_size[szidx] else NA
        dx$download_size <- fs::as_fs_bytes(this_size)
        dx
    }
}

## internal function to infer type (shapefile or raster or unknown) from the file extension
type_from_filename <- function(fname) {
    lxs_type <- rep("unknown", length(fname))
    lxs_type[grepl("shp$", fname, ignore.case = TRUE)] <- "shapefile"
    lxs_type[grepl("(tif|jp2|vrt)$", fname, ignore.case = TRUE)] <- "raster"
    lxs_type
}

## internal function to extract the colour paletter from the rasterrenderrer XML element
## xmll is the layer XML converted to a list with xml2::as_list(layer_xml)
get_layer_palette <- function(xmll) {
    if (length(xmll) == 1) xmll <- xmll[[1]]
    if (is.null(xmll$pipe$rasterrenderer$rastershader$colorrampshader)) {
        NULL
    } else {
        temp <- do.call(rbind, lapply(xmll$pipe$rasterrenderer$rastershader$colorrampshader, function(z) as.data.frame(attributes(z), stringsAsFactors = FALSE)))
        temp$value <- as.numeric(temp$value)
        temp
        ##plot(dsx, breaks = temp$value, col = temp$color)
    }
}


## cache_path must be an actual path, not "session" or "persistent"
fetch_dataset_index <- function(cache_path, refresh_cache = 0, verbose = FALSE) {
    index_file <- file.path(cache_path, qa_index_filename())
    if (file.exists(index_file) && refresh_cache < 1) return(index_file) ## don't re-fetch if not needed
    if (!dir.exists(dirname(index_file))) tryCatch(dir.create(dirname(index_file), recursive = TRUE), error = function(e) stop("Could not create cache directory: ", dirname(index_file)))
    res <- bb_rget(url = paste0(qa_mirror(), qa_index_filename()), force_local_filename = index_file, use_url_directory = FALSE, verbose = verbose, clobber = refresh_cache)
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

## internal function that defines the index file name, just so that if in the future it changes we don't have to
## change a lot of hard-coded references to it
qa_index_filename <- function() "Quantarctica3.qgs"
