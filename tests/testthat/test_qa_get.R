
context("Fetch Dataset")

res <- qa_get("ADD Simple basemap", verbose = TRUE)

test_that("The dataset from qa_get returns a shapefile or raster, as appropriate",{
    expect_is(res, class = "SpatialPolygonsDataFrame")
    ## TODO add test on raster data
})

