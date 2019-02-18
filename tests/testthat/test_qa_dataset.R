
context("Dataset details from qa_dataset")


test_that("The dataset requested from qa_dataset returns a custom class qa_dataset",{
    ds1 <- qa_dataset("ADD Simple basemap")
    expect_is(ds1, class = "qa_dataset")
})

test_that("Duplicate data layers have been removed from the dataset list", {
    dss <- qa_datasets()
    expect_false(any(duplicated(dss$layername)))
    ds1 <- qa_dataset("ADD Coastlines (high)") ## will error if duplicates have not been removed
})
