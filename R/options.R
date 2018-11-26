## internal helper functions for dealing with package options

qa_opts <- function() getOption("quantarcticR")
qa_opt <- function(optname) qa_opts()[[optname]]
qa_set_opt <- function(...) {
    opts <- qa_opts()
    newopts <- list(...)
    for (nm in names(newopts)) opts[[nm]] <- newopts[[nm]]
    options(list(quantarcticR = opts))
}
