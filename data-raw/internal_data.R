## use an already-downloaded copy of the full Quantarctica data set to establish the size of each layer
library(quantarcticR)
library(fs)
library(usethis)

base_dir <- "c:/data/Quantarctica3"
## adjust to wherever it is on your system
## note, this must be the full collection

qa_cache_dir(base_dir)
ds <- qa_datasets()
download_size <- vapply(seq_len(nrow(ds)), function(k) {
    ## at the moment, the download process just grabs everything in the associated data folder
    ## in some cases this means that a request for data from layer X will also download data from other layers
    ## so the sizes here may be overestimates of the actual data associated with the layer
    ## we might refine the download process later to be more specific, in which case this code here will need adjustment
    ## NOTE, however, that the values given here ARE an accurate representation of the download size
    thisfiles <- dir(dirname(ds$main_file[k]), full.names = TRUE, recursive = TRUE)
    sum(file_info(thisfiles)$size)
}, FUN.VALUE = 1, USE.NAMES = FALSE)
layer_sizes <- data.frame(layername = ds$layername, download_size = download_size, stringsAsFactors = FALSE)


use_data(layer_sizes, internal = TRUE, overwrite = TRUE)
