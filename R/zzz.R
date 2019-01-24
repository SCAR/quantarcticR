.onAttach <- function(libname, pkgname) {
    packageStartupMessage("Quantarctica is made available under a CC-BY license.\nIf you use it, please cite it:\nMatsuoka K, Skoglund A, Roth G (2018) Quantarctica [Data set]. Norwegian Polar Institute.\nhttps://doi.org/10.21334/npolar.2018.8516e961")
}


.onLoad <- function(libname, pkgname) {
    ## populate the options slot
    temp <- qa_mirrors()
    ## pick one at random
    idx <- sample.int(nrow(temp), size = 1)
    this_options <- list(
        mirror = temp$url[idx],
        issue_text = "If the problem persists, please lodge an issue at https://github.com/SCAR-sandpit/quantarcticR/issues",
        cache_dir = NA_character_, ## unspecified, will be overridden the first time qa_cache_dir() is called
        session_cache_dir = file.path(tempdir(), "quantarcticR-cache"), ## cache directory to use for cache_directory = "session"
        persistent_cache_dir = rappdirs::user_cache_dir("quantarcticR", "SCAR") ## and for cache_directory = "persistent"
    )
    options(list(quantarcticR = this_options))
    cat("Do you want layers downloaded from quantarcticR to be stored temporarily during this session?", "\n")
    invisible(
        switch(
            menu(c("Yes. Use a temp cache directory", "No. Use the persistent cache directory")) + 1,
            cat("Nothing done\n"),
            qa_cache_dir("session"),
            qa_cache_dir("persistent")
        )
    )
    invisible()
}

