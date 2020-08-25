
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis build status](https://travis-ci.org/SCAR-sandpit/quantarcticR.svg?branch=master)](https://travis-ci.org/SCAR-sandpit/quantarcticR) [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/SCAR-sandpit/quantarcticR?branch=master&svg=true)](https://ci.appveyor.com/project/SCAR-sandpit/quantarcticR) [![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental) [![Coverage status](https://codecov.io/gh/SCAR-sandpit/quantarcticR/branch/master/graph/badge.svg)](https://codecov.io/github/SCAR-sandpit/quantarcticR?branch=master)

quantarcticR
============

Quantarctica is a collection of Antarctic geographical datasets which works with the free, cross-platform, open-source software QGIS. It includes community-contributed, peer-reviewed data from ten different scientific themes and a professionally-designed basemap.

The `quantarcticR` package provides access to Quantarctica data sets for R users, **without** needing QGIS to be installed. R users can use these data sets with e.g. the `raster`, `sp`, or `sf` packages.

Installation
------------

You can install the development version of quantarcticR from GitHub with:

``` r
remotes::install_github("SCAR-sandpit/quantarcticR")
```

This is very much a work in progress!

Example
-------

``` r
library(quantarcticR)
```

List all available datasets:

``` r
ds <- qa_datasets()
head(ds)
#> # A tibble: 6 x 5
#>   layername         main_file                   type   cached download_size
#>   <chr>             <chr>                       <chr>  <lgl>    <fs::bytes>
#> 1 Overview place n~ c:/data/Quantarctica3/Misc~ shape~ TRUE          19.74K
#> 2 COMNAP listed fa~ c:/data/Quantarctica3/Misc~ shape~ TRUE         691.92K
#> 3 Subantarctic sta~ c:/data/Quantarctica3/Misc~ shape~ TRUE         691.92K
#> 4 SCAR Composite g~ c:/data/Quantarctica3/Misc~ shape~ TRUE         329.05M
#> 5 IBO-IOC GEBCO Fe~ c:/data/Quantarctica3/Misc~ shape~ TRUE           1.25M
#> 6 IBO-IOC GEBCO Fe~ c:/data/Quantarctica3/Misc~ shape~ TRUE           1.25M
```

Fetch one and plot it:

``` r
res <- qa_get("ADD Simple basemap", verbose = TRUE)
#> 
#> Fri Jul 05 03:26:34 2019
#> Synchronizing dataset: ADD Simple basemap
#> Source URL http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/
#> --------------------------------------------------------------------------------------------
#> 
#>  this dataset path is: c:\data\Quantarctica3/Miscellaneous//SimpleBasemap
#>  visiting http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ ... 9 download links, 0 links to visit done.
#>  file already exists, not downloading: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.cpg ...  file already exists, not downloading: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.dbf ...  file already exists, not downloading: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.prj ...  file already exists, not downloading: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.qix ...  file already exists, not downloading: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.shp ...  file already exists, not downloading: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.shx ...  file already exists, not downloading: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.txt ...  file already exists, not downloading: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap_Subantarctic.txt ...  file already exists, not downloading: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_General.txt ... 
#> Fri Jul 05 03:26:34 2019 dataset synchronization complete: ADD Simple basemap

library(raster)
plot(res)
```

<img src="man/figures/README-example3-1.png" width="100%" />

See the [introductory vignette](https://scar-sandpit.github.io/quantarcticR/articles/intro.html) for more information.

See also
--------

[RQGIS](https://cran.r-project.org/package=RQGIS) provides an R-QGIS interface, via Python middleware.
