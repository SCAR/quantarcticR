context("Fetch Dataset")

test_that("The dataset from qa_get returns a shapefile or raster, as appropriate", {
    res <- qa_get("ADD Simple basemap")
    expect_is(res, class = "SpatialPolygonsDataFrame")

    res <- qa_get("ETOPO1/IBCSO/RAMP2 Hillshade (50x v. exag.)")
    expect_is(res, class = "RasterLayer")

    ## TODO also test other raster types:
    ## "LIMA Landsat low-resolution mosaic (240m)" and "RAMP RADARSAT mosaic (100m)" are jp2
    ## "USGS/NASA subantarctic Landsat (15m)" and "LIMA Landsat high-resolution virtual mosaic (15m)" are vrt (virtual rasters). For these, the vrt file points to other actual raster files

    ## res <- qa_get("LIMA Landsat high-resolution virtual mosaic (15m)")
    ## plot(crop(res, extent(c(200e4, 201e4, -1e4, 1e4))))
    ## seems ok
})

test_that("qa_get can be passed either a dataset name as a string or a qa_dataset object", {
    res1 <- qa_get("ADD Simple basemap")
    res2 <- qa_get(qa_dataset("ADD Simple basemap"))
    expect_identical(res1, res2)
})

test_that("qa_get can be passed a custom reader", {
    skip_if_not_installed("sf")
    res <- qa_get("ADD Simple basemap", shapefile_reader = sf::st_read)
    expect_is(res, class = "sf")
})
