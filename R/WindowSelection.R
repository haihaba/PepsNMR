WindowSelection <- function (Spectrum_data, from.ws = 0.2, to.ws = 10, reverse.axis = TRUE) {
  begin_info <- beginTreatment("WindowSelection", Spectrum_data)
  Spectrum_data <- begin_info[["Signal_data"]]
  checkArg(from.ws, "num", can.be.null=TRUE)
  checkArg(to.ws, "num", can.be.null=TRUE)
  checkArg(reverse.axis, "bool")
  m <- ncol(Spectrum_data)
  largestWindowWithoutNA <- function(data, from_index=NULL, to_index=NULL) {
    largestFromOrToWithoutNA <- function(fromorto_index, fromorto, delta) {
      if (is.na(data[fromorto_index])) {
        stop("I should return an empty matrix because there is NA at" + fromorto + "ppm")
      }
      toorfrom_index <- fromorto_index
      while (toorfrom_index > 0 && toorfrom_index <= m && !is.na(data[toorfrom_index])) {
        toorfrom_index <- toorfrom_index + delta
      }
      toorfrom_index <- toorfrom_index - delta
      return(toorfrom_index)
    }
    if (!is.null(from_index) && !is.null(to_index)) {
      if (is.na(sum(data[from_index:to_index]))) {
        warning("There is NA in the selected window")
      }
    } else if (!is.null(from_index)) {
      to_index <- largestFromOrToWithoutNA(from_index, from.ws, 1)
    } else if (!is.null(to_index)) {
      from_index <- largestFromOrToWithoutNA(to_index, to.ws, -1)
    } else {
      # Largest interval without NA
      maxLen <- 0
      curLen <- 0
      for (i in 1:m) {
        if (is.na(data[i])) {
          curLen <- 0
        } else {
          curLen <- curLen + 1
          if (curLen > maxLen) {
            maxLen <- curLen
            from_index <- i - curLen + 1
            to_index <- i
          }
        }
      }
    }
    return(from_index:to_index)
  }
  ppm <- as.numeric(colnames(Spectrum_data))
  if (!is.null(from.ws) && !is.null(to.ws) && from.ws > to.ws) {
    stop(paste("Invalid window selection because ", from.ws, " > ", to.ws))
  }
  from_index <- NULL
  to_index <- NULL
  if (!is.null(from.ws)) {
    from_index <- binarySearch(ppm, from.ws, TRUE)
  }
  if (!is.null(to.ws)) {
    to_index <- binarySearch(ppm, to.ws, FALSE)
  }
  interval <- largestWindowWithoutNA(colSums(Spectrum_data), from_index, to_index)
  if (reverse.axis) {
    interval <- rev(interval)
  }
  return(endTreatment("WindowSelection", begin_info, Spectrum_data[,interval,drop=FALSE]))
}