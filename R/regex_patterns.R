

group_it <- function(reg) {
  paste0("(?:", reg, ")")
}


anchor_it <- function(reg) {
  paste0("^", reg, "$")
}


#' Enumerate all combinations of regex patterns
#'
#' @param reg1 A vector of regex patterns.
#' @param reg2 A vector of regex patterns.
#'
#' @return A vector of all combinations of the concatenation of reg1 and reg2.
regex_combn <- function(reg1, reg2) {
  paste(rep(reg1, each = length(reg2)), reg2, sep = "")
}

reg_day <- function() {
  "\\d{1,2}" %>% group_it()
}

reg_month <- function() {
  paste0(toupper(month.abb), collapse = "|") %>% group_it()
}

reg_year <- function() {
  "\\d{4}" %>% group_it()
}

reg_year_dual <- function() {
  "\\d{4}/\\d{2}" %>% group_it()
}

reg_bce <- function() {
  "BCE|BC|B\\.C\\." %>% group_it()
}

#' Construct a regular expression for an xref
#'
#' @param only Whether to allow strings of only xrefs. If FALSE,
#' the regular expression accepts patterns where text can come before or after
#' the xref.
#'
#' @return A regular expression pattern for an xref.
#' @export
reg_xref <- function(only = TRUE) {
  #p31
  reg <- "@[a-zA-Z0-9]{1,20}@"
  ifelse(only, anchor_it(reg), reg)
}

reg_latitude <- function() {
  "^[NS]\\d{1,2}(\\.\\d{1,6})?$"
}

reg_longitude <- function() {
  "^[EW]\\d{1,3}(\\.\\d{2,6})?$"
}

reg_age_at_event <- function() {
  paste0("^(?:[<>] )?",
         c("\\d{1,3}y \\d{1,2}m \\d{1,3}d$",
           "\\d{1,3}y \\d{1,2}m$",
           "\\d{1,3}y \\d{1,3}d$",
           "\\d{1,2}m \\d{1,3}d$",
           "\\d{1,3}y$",
           "\\d{1,2}m$",
           "\\d{1,3}d$")) %>% 
    paste(collapse = "|")
  
}

#' Construct the regex pattern for DATE_EXACT values
#'
#' @tests
#' expect_equal(grepl(reg_date_exact(), "14 JAN 2005"), TRUE)
#' expect_equal(grepl(reg_date_exact(), "14 JAM 2005"), FALSE)
#' expect_equal(grepl(reg_date_exact(), "JAN 2005"), FALSE)
#' expect_equal(grepl(reg_date_exact(), "14 JAN 2005/06"), FALSE)
#' expect_equal(grepl(reg_date_exact(), "5 JUL 2005"), TRUE)
#' expect_equal(grepl(reg_date_exact(), "8 NOV 1956/57"), FALSE)
#' expect_equal(grepl(reg_date_exact(), "2005"), FALSE)
#' expect_equal(grepl(reg_date_exact(), "15 NOV 125"), FALSE)
#' expect_equal(grepl(reg_date_exact(), "JAN 1901/58"), FALSE)
#' expect_equal(grepl(reg_date_exact(), "5 JUL 2005 "), FALSE)
#' expect_equal(grepl(reg_date_exact(), " 5 JUL 2005"), FALSE)
#' @return A regex string
reg_date_exact <- function() {
  paste(reg_day(), reg_month(), reg_year()) %>% anchor_it()
}


#' Construct the regex pattern for DATE values
#'
#' @details The DATE (and subsequent DATE_CALENDAR) pattern can potentially handle several
#' different calendar types, but this package has only implemented the Gregorian calendar.
#' @param flatten A logical value which determines whether a single regex string should be
#' returned (flatten = TRUE) or if a vector of them should be returned (flatten = FALSE).
#' The vector output is used if the regexes need to be combined with other regexes. If they
#' do not, then they are anchored with ^ and $ and separated with | (OR).
#' @tests
#' expect_equal(grepl(reg_date(), "14 JAN 2005"), TRUE)
#' expect_equal(grepl(reg_date(), "14 JAM 2005"), FALSE)
#' expect_equal(grepl(reg_date(), "JAN 2005"), TRUE)
#' expect_equal(grepl(reg_date(), "14 JAN 2005/06"), TRUE)
#' expect_equal(grepl(reg_date(), "5 JUL 2005"), TRUE)
#' expect_equal(grepl(reg_date(), "8 NOV 1956/57"), TRUE)
#' expect_equal(grepl(reg_date(), "2005"), TRUE)
#' expect_equal(grepl(reg_date(), "15 NOV 125"), FALSE)
#' expect_equal(grepl(reg_date(), "JAN 1901/58"), TRUE)
#' expect_equal(grepl(reg_date(), "5 JUL 2005 "), FALSE)
#' expect_equal(grepl(reg_date(), " 5 JUL 2005"), FALSE)
#' @return Either a single regex string or a vector of them
reg_date <- function(flatten = TRUE) {
  reg_date_calendar(flatten)
}

reg_date_calendar <- function(flatten = TRUE) {
  reg_date_gregorian(flatten)
}

reg_date_gregorian <- function(flatten = TRUE) {
  combos <- c(reg_year(),
              paste(reg_year(), reg_bce()),
              paste(reg_month(), reg_year()),
              paste(reg_day(), reg_month(), reg_year()),
              paste(reg_day(), reg_month()),
              paste(reg_month(), reg_year_dual()),
              paste(reg_day(), reg_month(), reg_year_dual()))
  
  if (flatten) {
    combos %>% anchor_it() %>% paste(collapse = "|")
  } else {
    combos
  }
  
}

#' Construct the regex pattern for DATE_PERIOD values
#'
#' @param flatten A logical value which determines whether a single regex string should be
#' returned (flatten = TRUE) or if a vector of them should be returned (flatten = FALSE).
#' The vector output is used if the regexes need to be combined with other regexes. If they
#' do not, then they are anchored with ^ and $ and separated with | (OR).
#' @tests
#' expect_equal(grepl(reg_date_period(), "FROM 14 JAN 2005"), TRUE)
#' expect_equal(grepl(reg_date_period(), "TO 14 JAM 2005"), FALSE)
#' expect_equal(grepl(reg_date_period(), "FROM JAN 2005"), TRUE)
#' expect_equal(grepl(reg_date_period(), "FROM 14 JAN 2005/06 TO 2007"), TRUE)
#' expect_equal(grepl(reg_date_period(), "TO 5 JUL 2005"), TRUE)
#' expect_equal(grepl(reg_date_period(), "TO  8 NOV 1956/57"), FALSE)
#' expect_equal(grepl(reg_date_period(), "FROM 2005"), TRUE)
#' expect_equal(grepl(reg_date_period(), "FROM 15 NOV 125"), FALSE)
#' expect_equal(grepl(reg_date_period(), " TO JAN 1901/58"), FALSE)
#' expect_equal(grepl(reg_date_period(), "FROM 5 JUL 2005 "), FALSE)
#' expect_equal(grepl(reg_date_period(), " TO 5 JUL 2005"), FALSE)
#' @return Either a single regex string or a vector of them
reg_date_period <- function(flatten = TRUE) {
  combos <- c(paste("FROM", reg_date(FALSE)),
              paste("TO", reg_date(FALSE)),
              regex_combn(paste("FROM", reg_date(FALSE)), 
                          paste(" TO", reg_date(FALSE))))
  if (flatten) {
    combos %>% anchor_it() %>% paste(collapse = "|")
  } else {
    combos
  }
}

#' Construct the regex pattern for DATE_RANGE values
#'
#' @param flatten A logical value which determines whether a single regex string should be
#' returned (flatten = TRUE) or if a vector of them should be returned (flatten = FALSE).
#' The vector output is used if the regexes need to be combined with other regexes. If they
#' do not, then they are anchored with ^ and $ and separated with | (OR).
#' @tests
#' expect_equal(grepl(reg_date_range(), "BEF 14 JAN 2005"), TRUE)
#' expect_equal(grepl(reg_date_range(), "AFT 14 JAM 2005"), FALSE)
#' expect_equal(grepl(reg_date_range(), "BEF JAN 2005"), TRUE)
#' expect_equal(grepl(reg_date_range(), "BET 14 JAN 2005/06 AND 2007"), TRUE)
#' expect_equal(grepl(reg_date_range(), "AFT 5 JUL 2005"), TRUE)
#' expect_equal(grepl(reg_date_range(), "AFT  8 NOV 1956/57"), FALSE)
#' expect_equal(grepl(reg_date_range(), "BEF 2005"), TRUE)
#' expect_equal(grepl(reg_date_range(), "BEF 15 NOV 125"), FALSE)
#' expect_equal(grepl(reg_date_range(), " AFT JAN 1901/58"), FALSE)
#' expect_equal(grepl(reg_date_range(), "BEF 5 JUL 2005 "), FALSE)
#' expect_equal(grepl(reg_date_range(), " AFT 5 JUL 2005"), FALSE)
#' @return Either a single regex string or a vector of them
reg_date_range <- function(flatten = TRUE) {
  combos <- c(paste("BEF", reg_date(FALSE)),
              paste("AFT", reg_date(FALSE)),
              regex_combn(paste("BET", reg_date(FALSE)), 
                          paste(" AND", reg_date(FALSE))))
  if (flatten) {
    combos %>% anchor_it() %>% paste(collapse = "|")
  } else {
    combos
  }
}

#' Construct the regex pattern for DATE_APPROXIMATED values
#'
#' @param flatten A logical value which determines whether a single regex string should be
#' returned (flatten = TRUE) or if a vector of them should be returned (flatten = FALSE).
#' The vector output is used if the regexes need to be combined with other regexes. If they
#' do not, then they are anchored with ^ and $ and separated with | (OR).
#' @tests
#' expect_equal(grepl(reg_date_approximated(), "ABT 14 JAN 2005"), TRUE)
#' expect_equal(grepl(reg_date_approximated(), "CAL 14 JAM 2005"), FALSE)
#' expect_equal(grepl(reg_date_approximated(), "EST JAN 2005"), TRUE)
#' expect_equal(grepl(reg_date_approximated(), "ABT 14 JAN 2005/06 AND 2007"), FALSE)
#' expect_equal(grepl(reg_date_approximated(), "EST 5 JUL 2005"), TRUE)
#' expect_equal(grepl(reg_date_approximated(), "CAL  8 NOV 1956/57"), FALSE)
#' expect_equal(grepl(reg_date_approximated(), "ABT 2005"), TRUE)
#' expect_equal(grepl(reg_date_approximated(), "CAL 15 NOV 125"), FALSE)
#' expect_equal(grepl(reg_date_approximated(), " EST JAN 1901/58"), FALSE)
#' expect_equal(grepl(reg_date_approximated(), "CAL 5 JUL 2005 "), FALSE)
#' expect_equal(grepl(reg_date_approximated(), " CAL 5 JUL 2005"), FALSE)
#' @return Either a single regex string or a vector of them
reg_date_approximated <- function(flatten = TRUE) {
  combos <- c(paste("ABT", reg_date(FALSE)),
              paste("CAL", reg_date(FALSE)),
              paste("EST", reg_date(FALSE)))
  if (flatten) {
    combos %>% anchor_it() %>% paste(collapse = "|")
  } else {
    combos
  }
}

#' Construct the regex pattern for DATE_VALUE values
#'
#' @tests
#' expect_equal(grepl(reg_date_value(), "14 JAN 2005"), TRUE)
#' expect_equal(grepl(reg_date_value(), "MAR 1901"), TRUE)
#' expect_equal(grepl(reg_date_value(), "2010"), TRUE)
#' expect_equal(grepl(reg_date_value(), "FROM 14 FEB 2005"), TRUE)
#' expect_equal(grepl(reg_date_value(), "TO JAN 2005"), TRUE)
#' expect_equal(grepl(reg_date_value(), "FROM 14 JAN 2005/06 TO 2007"), TRUE)
#' expect_equal(grepl(reg_date_value(), "BEF 5 JUL 2005"), TRUE)
#' expect_equal(grepl(reg_date_value(), "AFT 8 NOV 1956/57"), TRUE)
#' expect_equal(grepl(reg_date_value(), "BET 2005 AND MAR 2008"), TRUE)
#' expect_equal(grepl(reg_date_value(), "CAL 15 NOV 1925"), TRUE)
#' expect_equal(grepl(reg_date_value(), "EST JAN 1901/58"), TRUE)
#' expect_equal(grepl(reg_date_value(), "ABT 5 JUL 2005"), TRUE)
#' expect_equal(grepl(reg_date_value(), "14 JAN 205"), FALSE)
#' expect_equal(grepl(reg_date_value(), "MAR 1901 "), FALSE)
#' expect_equal(grepl(reg_date_value(), " 2010"), FALSE)
#' expect_equal(grepl(reg_date_value(), "FROM 14 FEBR 2005"), FALSE)
#' expect_equal(grepl(reg_date_value(), "TO  JAN 2005"), FALSE)
#' expect_equal(grepl(reg_date_value(), "FROM 14 JAN 2005/06 AND 2007"), FALSE)
#' expect_equal(grepl(reg_date_value(), "BEF 5 JUL 2005 "), FALSE)
#' expect_equal(grepl(reg_date_value(), "AFT 8 NOV 1956/1957"), FALSE)
#' expect_equal(grepl(reg_date_value(), "BET 2005 TO MAR 2008"), FALSE)
#' expect_equal(grepl(reg_date_value(), "CAL 15 NOV 1925/"), FALSE)
#' expect_equal(grepl(reg_date_value(), "14TH JAN 1901/58"), FALSE)
#' expect_equal(grepl(reg_date_value(), "ABT 5  JUL 2005"), FALSE)
#' @return Either a single regex string or a vector of them
reg_date_value <- function() {
  
  #date_phrase not implemented
  c(reg_date(FALSE),
    reg_date_period(FALSE),
    reg_date_range(FALSE),
    reg_date_approximated(FALSE)) %>% 
    anchor_it() %>% 
    paste(collapse = "|")
}
