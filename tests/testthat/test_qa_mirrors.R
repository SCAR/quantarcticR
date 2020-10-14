context("Quantarctica mirrors")

test_that("The list of mirrors looks OK", {
    qm <- qa_mirrors()
    expect_is(qm, class = "tbl_df")
    expect_gt(nrow(qm), 0)
    expect_named(qm, c("country", "protocol", "url"))
})

test_that("qa_mirror returns something that is in the list of mirrors", {
    expect_true(qa_mirror() %in% qa_mirrors()$url)
})

test_that("we can download something from each mirror", {
    qm <- qa_mirrors()
    for (thism in qm$url) {
        qa_cache_dir(tempfile())
        qa_mirror(thism)
        this_ds <- qa_dataset("Overview place names")
        temp <- qa_get(this_ds, verbose = TRUE)
        expect_true(inherits(temp, "SpatialPointsDataFrame"))
    }
})
