.onAttach <- function(libname, pkgname) {
    packageStartupMessage("Quantarctica is made available under a CC-BY license. If you use it, please cite it:\nMatsuoka K, Skoglund A, Roth G (2018) Quantarctica [Data set]. Norwegian Polar Institute. https://doi.org/10.21334/npolar.2018.8516e961\nIn addition, published works produced using Quantarctica are asked to cite each dataset that was used in the work. Please consult the abstract of each data set for the relevant citation.\n\nQuantarcticR is using a temporary data directory for this session: see the `qa_cache_dir` function to change this.")
}


.onLoad <- function(libname, pkgname) {
    ## populate the options slot
    temp <- qa_mirrors()
    ## pick one at random
    idx <- sample.int(nrow(temp), size = 1)
    ## if we are re-loading the package during an existing session, we don't want to override existing options
    existing_options <- qa_opts()
    default_options <- list(
        mirror = temp$url[idx],
        issue_text = "If the problem persists, please lodge an issue at https://github.com/SCAR-sandpit/quantarcticR/issues",
        cache_dir = NA_character_, ## unspecified, will be overridden the first time qa_cache_dir() is called
        session_cache_dir = file.path(tempdir(), "quantarcticR-cache"), ## cache directory to use for cache_directory = "session"
        persistent_cache_dir = user_cache_dir("quantarcticR", "SCAR") ## and for cache_directory = "persistent"
    )
    if (!is.null(existing_options)) {
        for (nm in names(existing_options)) {
            default_options[[nm]] <- existing_options[[nm]]
        }
    }
    options(list(quantarcticR = default_options))
    invisible()
}

