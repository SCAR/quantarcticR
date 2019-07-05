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
