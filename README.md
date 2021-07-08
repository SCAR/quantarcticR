
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![R-CMD-check](https://github.com/SCAR/quantarcticR/workflows/R-CMD-check/badge.svg)](https://github.com/SCAR/quantarcticR/actions)
[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![Codecov test coverage](https://codecov.io/gh/SCAR/quantarcticR/branch/master/graph/badge.svg)](https://codecov.io/gh/SCAR/quantarcticR?branch=master)
<!-- badges: end -->

# quantarcticR

Quantarctica is a collection of Antarctic geographical datasets which
works with the free, cross-platform, open-source software QGIS. It
includes community-contributed, peer-reviewed data from ten different
scientific themes and a professionally-designed basemap.

The `quantarcticR` package provides access to Quantarctica data sets for
R users, **without** needing QGIS to be installed. R users can use these
data sets with e.g. the `raster`, `sp`, or `sf` packages.

## Installation

You can install the development version of quantarcticR from GitHub
with:

``` r
remotes::install_github("SCAR/quantarcticR")
```

## Example

``` r
library(quantarcticR)
```

`quantarcticR` will download data from whichever Quantarctica mirror has
been selected. The USA mirror is chosen by default, but you can change
this: see `help("qa_mirror")`.

List all available datasets:

``` r
ds <- qa_datasets()
head(ds)
#> # A tibble: 6 x 5
#>   layername          main_file                       type   cached download_size
#>   <chr>              <chr>                           <chr>  <lgl>    <fs::bytes>
#> 1 Overview place na… /tmp/Rtmpwzkv9G/quantarcticR-c… shape… FALSE         19.74K
#> 2 COMNAP listed fac… /tmp/Rtmpwzkv9G/quantarcticR-c… shape… FALSE        691.92K
#> 3 Subantarctic stat… /tmp/Rtmpwzkv9G/quantarcticR-c… shape… FALSE        691.92K
#> 4 SCAR Composite ga… /tmp/Rtmpwzkv9G/quantarcticR-c… shape… FALSE        329.05M
#> 5 IBO-IOC GEBCO Fea… /tmp/Rtmpwzkv9G/quantarcticR-c… shape… FALSE          1.25M
#> 6 IBO-IOC GEBCO Fea… /tmp/Rtmpwzkv9G/quantarcticR-c… shape… FALSE          1.25M
```

Fetch one and plot it:

``` r
res <- qa_get("ADD Simple basemap", verbose = TRUE)
#> 
#> Thu Jul  8 11:52:07 2021
#> Synchronizing dataset: ADD Simple basemap
#> Source URL ftp://ftp.quantarctica.npolar.no/Quantarctica3/Miscellaneous/SimpleBasemap/
#> --------------------------------------------------------------------------------------------
#> 
#>  this dataset path is: /tmp/Rtmpwzkv9G/quantarcticR-cache/Miscellaneous//SimpleBasemap
#>  visiting ftp://ftp.quantarctica.npolar.no/Quantarctica3/Miscellaneous/SimpleBasemap/ ... done.
#>  downloading file 1 of 9: ftp://ftp.quantarctica.npolar.no/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.cpg ...  done.
#>  downloading file 2 of 9: ftp://ftp.quantarctica.npolar.no/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.dbf ...  done.
#>  downloading file 3 of 9: ftp://ftp.quantarctica.npolar.no/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.prj ...  done.
#>  downloading file 4 of 9: ftp://ftp.quantarctica.npolar.no/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.qix ...  done.
#>  downloading file 5 of 9: ftp://ftp.quantarctica.npolar.no/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.qmd ...  done.
#>  downloading file 6 of 9: ftp://ftp.quantarctica.npolar.no/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.qml ...  done.
#>  downloading file 7 of 9: ftp://ftp.quantarctica.npolar.no/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.shp ...  done.
#>  downloading file 8 of 9: ftp://ftp.quantarctica.npolar.no/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.shx ...  done.
#>  downloading file 9 of 9: ftp://ftp.quantarctica.npolar.no/Quantarctica3/Miscellaneous/SimpleBasemap/ADD_DerivedLowresBasemap.txt ...  done.
#> 
#> Thu Jul  8 11:52:32 2021 dataset synchronization complete: ADD Simple basemap

library(raster)
plot(res)
```

<img src="man/figures/README-example3-1.png" width="100%" />

See the [introductory
vignette](https://scar.github.io/quantarcticR/articles/intro.html) for
more information.

## See also

[RQGIS](https://cran.r-project.org/package=RQGIS) provides an R-QGIS
interface, via Python middleware.
