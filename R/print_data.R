#' Print details of a Quantarctica data set object
#'
#' @param nameobject tibble: the name of the data set output variable assigned to qa_get
#'
#' @return Message and a tibble
#'
#' @export
qa_print <- function(nameobject) {
    # First version of this print method is to replicate the message format from library(quantarticR).
  # The qa_get function does not return license and citation components, is the license or citation expected to change?
  print("Quantarctica is made available under a CC-BY license")
  print(paste0("If you use ",nameobject$name, ", please cite it:"))
  # Print citation
  citation <- paste0("Matsuoka, K., Skoglund, A., & Roth, G. (2018). Quantarctica ", nameobjec$name, ". Norwegian Polar Institute. https://doi.org/10.21334/npolar.2018.8516e961")
  # Placeholder to add cached indicator, ( to be added to qa_get first?)
  # Placeholder to add download date/time , ( to be added to qa_get first?)
  # Placeholder for out

}




