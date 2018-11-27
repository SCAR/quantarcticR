
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

quantarcticR
============

Quantarctica is a collection of Antarctic geographical datasets which works with the free, cross-platform, open-source software QGIS. It includes community-contributed, peer-reviewed data from ten different scientific themes and a professionally-designed basemap. This package provides access to Quantarctica data sets for R users, who can use these data sets with e.g. the `raster`, `sp`, or `sf` packages.

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
```

List all available datasets:

``` r
ds <- qa_datasets()
head(ds)
#> # A tibble: 6 x 3
#>   name                               
#>   <chr>                              
#> 1 Overview place names               
#> 2 COMNAP listed facilities           
#> 3 Subantarctic stations              
#> 4 SCAR Composite gazetteer           
#> 5 IBO-IOC GEBCO Features (point)     
#> 6 IBO-IOC GEBCO Features (multipoint)
#>   source                                                                   
#>   <chr>                                                                    
#> 1 "C:\\Users\\ben_ray\\AppData\\Local\\Temp\\RtmpuAPx70/quantarcticR-cache~
#> 2 "C:\\Users\\ben_ray\\AppData\\Local\\Temp\\RtmpuAPx70/quantarcticR-cache~
#> 3 "C:\\Users\\ben_ray\\AppData\\Local\\Temp\\RtmpuAPx70/quantarcticR-cache~
#> 4 "C:\\Users\\ben_ray\\AppData\\Local\\Temp\\RtmpuAPx70/quantarcticR-cache~
#> 5 "C:\\Users\\ben_ray\\AppData\\Local\\Temp\\RtmpuAPx70/quantarcticR-cache~
#> 6 "C:\\Users\\ben_ray\\AppData\\Local\\Temp\\RtmpuAPx70/quantarcticR-cache~
#>   cached
#>   <lgl> 
#> 1 FALSE 
#> 2 FALSE 
#> 3 FALSE 
#> 4 FALSE 
#> 5 FALSE 
#> 6 FALSE
```

Fetch one and plot it:

``` r
res <- qa_get("ADD Simple basemap", verbose = TRUE)
#> 
#> Tue Nov 27 04:49:49 2018
#> Synchronizing dataset: ADD Simple basemap
#> Source URL http://quantarctica.tpac.org.au/Quantarctica3/Miscellaneous/SimpleBasemap/
#> --------------------------------------------------------------------------------------------
#> 
#>  this dataset path is: C:\Users\ben_ray\AppData\Local\Temp\RtmpuAPx70\quantarcticR-cache/Quantarctica3/Miscellaneous/SimpleBasemap
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
#> Tue Nov 27 04:49:52 2018 dataset synchronization complete: ADD Simple basemap

library(raster)
#> Loading required package: sp
x <- shapefile(res$main_file)
plot(x)
```

<img src="man/figures/README-example3-1.png" width="100%" />
