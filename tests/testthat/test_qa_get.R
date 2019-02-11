
context("Fetch Dataset")


test_that("The dataset from qa_get returns a shapefile or raster, as appropriate", {
    res <- qa_get("ADD Simple basemap", verbose = TRUE)
    expect_is(res, class = "SpatialPolygonsDataFrame")
    ## TODO add test on raster data
})

test_that("qa_get can be passed a custom reader", {
    skip_if_not_installed("sf")
    res <- qa_get("ADD Simple basemap", shapefile_reader = sf::st_read)
    expect_is(res, class = "sf")
})
