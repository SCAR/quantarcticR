context("Fetch all layers")

test_that("All layers can be read OK", {
    skip("Skipping all-layers read test")
    ## this test is intended to be run manually, rather than as part of the test suite
    qa_cache_dir("/data/Quantarctica3/") ## this needs to point to a complete Quantarctica download
    all_ds <- qa_datasets()
    expect_not_working <- c(6, 46) ## know these ones don't work yet, give rgdal::readOGR "eType not chosen" errors
    not_working <- c()
    for (li in seq_along(all_ds$layername)) {
        not_working <- c(not_working,
                         tryCatch({
                             ll <- all_ds$layername[li]
                             blah <- capture.output(this_d <- qa_get(ll, verbose = TRUE))
                             cat("\n", li, ": ", ll, "\n", paste(blah, sep = "\n", collapse = "\n"), "\n")
                             if (any(grepl("downloading file", blah))) {
                                 ## we should not be actually downloading anything here, it should all already be cached
                                 li
                             } else {
                                 ## ok
                                 NULL
                             }
                         }, error = function(e) li))
    }
    expect_setequal(not_working, expect_not_working)
})

