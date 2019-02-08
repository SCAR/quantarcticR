
context("Dataset details from qa_dataset")

ds1 <- qa_dataset("ADD Simple basemap")

test_that("The dataset requested from qa_dataset returns a custom class qa_dataset",{
  expect_is(ds1, class = "qa_dataset")
})
