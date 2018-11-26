.onAttach <- function(libname, pkgname) {
    packageStartupMessage("Quantarctica is made available under a CC-BY license.\nIf you use it, please cite it:\nMatsuoka K, Skoglund A, Roth G (2018) Quantarctica [Data set]. Norwegian Polar Institute.\nhttps://doi.org/10.21334/npolar.2018.8516e961")
}


.onLoad <- function(libname, pkgname) {
    ## populate the options slot
    temp <- qa_mirrors()
    ## pick one at random
    ##idx <- sample.int(nrow(temp), size = 1)
    ## for now, just use Aus http
    idx <- which(temp$country == "Australia" & temp$protocol == "http")
    this_options <- list(
        mirror = temp$url[idx],
        issue_text = "If the problem persists, please lodge an issue at https://github.com/SCAR-sandpit/quantarcticR/issues",
        session_cache_dir = file.path(tempdir(), "quatarcticR-cache"), ## cache directory to use for cache_directory = "session"
        persistent_cache_dir = rappdirs::user_cache_dir("quantarcticR", "SCAR") ## and for cache_directory = "persistent"
    )
    options(list(quantarcticR = this_options))
    invisible()
}
