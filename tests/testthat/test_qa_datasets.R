context("List of datasets from qa_datasets")

ds <- qa_datasets()

test_that("The list of datasets from qa_datasets returns a tibble",{
  expect_is(ds,class = "tbl_df")
})
