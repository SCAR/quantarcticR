
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

quantarcticR
============

Quantarctica is a collection of Antarctic geographical datasets which works with the free, cross-platform, open-source software QGIS. It includes community-contributed, peer-reviewed data from ten different scientific themes and a professionally-designed basemap. This package provides access to Quantarctica data sets.

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
#> Quantarctica is made available under a CC-BY license.
#> If you use it, please cite it:
#> Matsuoka K, Skoglund A, Roth G (2018) Quantarctica [Data set]. Norwegian Polar Institute.
#> https://doi.org/10.21334/npolar.2018.8516e961

res <- qa_get("Miscellaneous/SimpleBasemap", verbose = TRUE)
#> creating data cache directory: C:\Users\ben_ray\AppData\Local\Temp\Rtmp65ZWFW/quatarcticR-cache
#> 
#> Mon Nov 26 12:37:02 2018
#> Synchronizing dataset: SimpleBasemap
#> Source URL http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/
#> --------------------------------------------------------------------------------------------
#> 
#>  this dataset path is: C:\Users\ben_ray\AppData\Local\Temp\Rtmp65ZWFW\quatarcticR-cache/quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap
#>  building file list ... done.
#>  visiting http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ ...
#> No encoding supplied: defaulting to UTF-8.
#>  9 download links, 0 links to visit done.
#>  downloading file 1 of 9: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.cpg ...  done.
#>  downloading file 2 of 9: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.dbf ...  done.
#>  downloading file 3 of 9: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.prj ...  done.
#>  downloading file 4 of 9: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.qix ...  done.
#>  downloading file 5 of 9: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.shp ...  done.
#>  downloading file 6 of 9: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.shx ...  done.
#>  downloading file 7 of 9: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.txt ...  done.
#>  downloading file 8 of 9: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap_Subantarctic.txt ...  done.
#>  downloading file 9 of 9: http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_General.txt ...  done.
#> 
#> Mon Nov 26 12:37:04 2018 dataset synchronization complete: SimpleBasemap

library(raster)
#> Loading required package: sp
x <- shapefile(qa_find_shapefile(res))
plot(x)
```

<img src="man/figures/README-example-1.png" width="100%" />
