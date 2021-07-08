#' A list of Quantarctic mirror sites
#'
#' Choose the mirror closest to you for the fastest and most reliable download.
#'
#' @references http://quantarctica.npolar.no/downloads/
#'
#' @return A tibble with columns \code{country}, \code{protocol}, and \code{url}
#'
#' @examples
#'
#' qa_mirrors()
#'
#' @export
qa_mirrors <- function() {
    ## note: these have been hand-coded from http://quantarctica.npolar.no/downloads/
    ## note 2: these need to point to the unzipped dir, where Quantarctica3.qgs resides
    m <- tribble(~country, ~protocol, ~url,
                 "Norway", "ftp", "ftp://ftp.quantarctica.npolar.no/Quantarctica3/",
                 "Australia", "ftp", "ftp://quantarctica.tpac.org.au/quantarctica/Quantarctica3/",
                 "Australia", "http", "http://quantarctica.tpac.org.au/quantarctica/Quantarctica3/",
                 ##"India", "ftp", "ftp://ftp.ncaor.gov.in/Quantarctica3/", ## appears to be unavailable
                 ##"India", "http", "http://ftp.ncaor.gov.in/quantarctica/Quantarctica3/", ## appears to be unavailable
                 "Japan", "http", "https://ads.nipr.ac.jp/gis/quantarctica/Quantarctica3/")
                 ## "USA", "ftp", "ftp://ftp.data.pgc.umn.edu/gis/packages/quantarctica/Quantarctica3/", ## as of Feb 2021 (or earlier), only provided as a single zip archive, which is no good to us
                 ##"USA", "http", "http://data.pgc.umn.edu/gis/packages/quantarctica/Quantarctica3/") ## same
    ## ensure all have trailing /
    m$url <- sub("/+$", "/", paste0(m$url, "/"))
    m
}


#' Get or set the Quantarctica download mirror site to use
#'
#' @param mirror string: the URL of the mirror to use
#'
#' @return If called with no arguments, the current mirror URL will be returned as a string. If called with a \code{mirror} argument, the mirror will be set to that and then the mirror URL returned.
#'
#' @seealso \code{\link{qa_mirrors}}
#'
#' @examples
#'
#' ## current mirror
#' qa_mirror()
#'
#' ## all available mirrors
#' qa_mirrors()
#'
#' ## set to first mirror in that list
#' qa_mirror(qa_mirrors()$url[1])
#'
#' ## or equivalently
#' qa_mirror(qa_mirrors()[1, ])
#'
#' @export
qa_mirror <- function(mirror) {
    if (!missing(mirror)) {
        ## set the mirror
        if (is.data.frame(mirror)) {
            if (nrow(mirror) != 1 || !"url" %in% names(mirror)) stop("mirror must be a string (the URL of the mirror) or a single-row data frame with a 'url' column (e.g. one row from the object returned by qa_mirrors() )")
            mirror <- mirror$url
        }
        assert_that(is.string(mirror))
        qa_set_opt(mirror = mirror)
    }
    qa_opt("mirror")
}
