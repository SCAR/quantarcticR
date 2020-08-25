context("Fetch Dataset")

test_that("The dataset from qa_get returns a shapefile or raster, as appropriate", {
    res <- qa_get("ADD Simple basemap")
    expect_is(res, class = "SpatialPolygonsDataFrame")

    res <- qa_get("AntGG Free-air gravity anomaly (10km)")
    expect_is(res, class = "RasterLayer")

    ## TODO also test other raster types:
    ## "LIMA Landsat low-resolution mosaic (240m)" and "RAMP RADARSAT mosaic (100m)" are jp2
    ## "USGS/NASA subantarctic Landsat (15m)" and "LIMA Landsat high-resolution virtual mosaic (15m)" are vrt (virtual rasters). For these, the vrt file points to other actual raster files

    ## res <- qa_get("LIMA Landsat high-resolution virtual mosaic (15m)")
    ## plot(crop(res, extent(c(200e4, 201e4, -1e4, 1e4))))
    ## seems ok
})


test_that("A shapefile dataset downloads only the required files" {
    ds <- qa_dataset("ADD Coastlines (low)")
    res <- bowerbird::bb_get(ds$bb_source, local_file_root = tempdir(), clobber = TRUE)
    expect_equal(nrow(res$files[[1]]), 5)
})

test_that("A tiff/jp2 raster dataset downloads only the required files" {
    ds <- qa_dataset("AntGG Free-air gravity anomaly (10km)")
    res <- bowerbird::bb_get(ds$bb_source, local_file_root = tempdir(), clobber = TRUE)
    expect_equal(nrow(res$files[[1]]), 2) ## the .tif file plus the .tif.aux.xml file

    ds <- qa_dataset("LIMA Landsat low-resolution mosaic (240m)")
    ## don't actually download this one, it's > 1GB
    expect_equal(length(ds$bb_source$method[[1]]$accept_download_extra), 0L)
    expect_equal(ds$bb_source$method[[1]]$accept_download, "LIMA_Mosaic.jp2")
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

test_that("qa_get will warn if passed the wrong type of reader function", {
    expect_warning(qa_get("ADD Simple basemap", raster_reader = raster::raster))
    expect_warning(qa_get("AntGG Free-air gravity anomaly (10km)", shapefile_reader = raster::shapefile))
})
