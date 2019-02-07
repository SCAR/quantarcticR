
context("Fetch Dataset")

res <- qa_get("ADD Simple basemap", verbose = TRUE)

test_that("Dataset name in qa_datasets is populated and as requested",{
  expect_match(res$name, "ADD Simple basemap")
})

test_that("The dataset from qa_get returns a tibble  (at the moment... to be ...returns the actual data in a raster/sp/etc object.",{
  expect_is(res,class = "tbl_df")
})

test_that("The main_file from qa_get contains a shapefile extension",{
  expect_match( substr(res$main_file, (nchar(res$main_file)-3), nchar(res$main_file)),".shp" )
})

