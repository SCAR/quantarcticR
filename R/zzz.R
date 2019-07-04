.onAttach <- function(libname, pkgname) {
    packageStartupMessage("Quantarctica is made available under a CC-BY license. If you use it, please cite it:\nMatsuoka K, Skoglund A, Roth G (2018) Quantarctica [Data set]. Norwegian Polar Institute. https://doi.org/10.21334/npolar.2018.8516e961\nIn addition, published works produced using Quantarctica are required to cite each dataset that was used in the work. Please consult the abstract of each data set for the relevant citation.")
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
    if (interactive() && is.na(qa_opt("cache_dir"))) {
        ## only run this in an interactive session, and also only if the cache directory has NOT already been set
        ## otherwise if a user re-loads the package they get asked and it will override whatever they already set
        cat("Do you want layers downloaded from Quantarctica to be stored temporarily during this session?", "\n")
        invisible(
            switch(
                menu(c("Yes. Use a temporary cache directory for this session only", "No. Use the persistent cache directory")) + 1,
                cat("Nothing done\n"),
                qa_cache_dir("session"),
                qa_cache_dir("persistent")
            )
        )
    }
    invisible()
}

