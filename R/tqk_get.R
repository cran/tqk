#' Get quantitative data from korea
#'
#' @return a [tibble][tibble::tibble-package]
#' @param x Stock x. only Korean type like "005930" is samsung.
#' @param from Optional for various time series functions. A character string representing a start date in YYYY-MM-DD format.
#' @param to Optional for various time series functions. A character string representing a end date in YYYY-MM-DD format.
#' @export
#' @examples
#' \donttest{
#'   tqk_get(x = "005930")
#'   tqk_get(x = "005930", from = "2018-05-01")
#'   tqk_get(x = "005930", from = "2018-05-01", to = "2018-05-31")
#' }
#' @importFrom httr POST content
#' @importFrom jsonlite fromJSON
#' @importFrom tibble as_tibble
#' @importFrom dplyr transmute
tqk_get <- function(x,
                    from = "1900-01-01",
                    to = Sys.Date()) {
  . <-
    TRD_DD <-
    TDD_OPNPRC <-
    TDD_HGPRC <- TDD_LWPRC <- TDD_CLSPRC <- ACC_TRDVOL <- NULL

  x <- as.character(x)
  stopifnot(valid_code_format(x))
  stopifnot(check_code_exist(x))

  code_full <-
    krcodedata[krcodedata$code == x, "code_full"]

  "http://data.krx.co.kr/comm/bldAttendant/getJsonData.cmd" %>%
    httr::POST(
      body = list(
        bld = "dbms/MDC/STAT/standard/MDCSTAT01701",
        locale = "ko_KR",
        isuCd = code_full,
        strtDd = gsub("-", "", from),
        endDd = gsub("-", "", to),
        csvxls_isNo = "false"
      ),
      encode = "form"
    ) %>%
    httr::content("text") %>%
    jsonlite::fromJSON() %>%
    .$output %>%
    tibble::as_tibble() %>%
    dplyr::transmute(
      date = as.Date(TRD_DD),
      open = to_int(TDD_OPNPRC),
      high = to_int(TDD_HGPRC),
      low = to_int(TDD_LWPRC),
      close = to_int(TDD_CLSPRC),
      volume = to_int(ACC_TRDVOL)
    ) %>%
    return()
}


