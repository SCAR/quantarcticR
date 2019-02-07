
context("Dataset details from qa_dataset")

ds1 <- qa_dataset("ADD Simple basemap")

# This is currently failing as code is classing ds1 to "tbl_df"     "tbl"        "data.frame" whereas it should be as an object of class `qa_dataset`
test_that("The dataset requested from qa_dataset returns a custom class qa_dataset",{
  expect_is(ds1,class = "qa_dataset")
})
