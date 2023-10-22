library(rvest)
library(RCurl)
library(glue)
library(stringr)
library(jsonlite)
library(polite)
library(readr)
library(here)

base_url <- "http://px.hagstofa.is/pxis/api/v1/is"

db_ids <- jsonlite::fromJSON(base_url)

cur_url <- str_c(
  base_url,
  db_ids[1, 1],
  sep = "/"
)

data <- list()

process_dbid <- function(tb, url) {

  dbid <- tb[["id"]]

  print(dbid)

  url <- str_c(
    url,
    dbid,
    sep = "/"
  ) |>
    str_replace_all(" ", "%20")

  current_page <- nod(session, url) |>
    scrape(verbose = T)

  for (item in current_page) {
    if (item$type != "t") {
      tb[["id"]] <- item$id
      tb[[item$text]] <- 1
      process_dbid(tb, url)
    } else {

      file_url <- str_c(
        url,
        item$id,
        sep = "/"
      )

      file_name <- item$text

      file_updated <- item$updated

      data[[file_name]] <<- list(
        url = file_url,
        name = file_name,
        cumul_id = tb,
        last_update = file_updated
      )

      data |>
        write_rds(
          here("data-raw", "scraped_data.rds")
        )

    }
  }
}

base_url <- "http://px.hagstofa.is/pxis/api/v1/is"
session <- bow(
  base_url
  )
data <- list()

db_ids <- nod(session, base_url) |>
  scrape(verbose = T)

for (item in db_ids) {
  tb <- list()
  tb[["id"]] <- item$dbid
  tb[[item$text]] <- 1
  process_dbid(tb, base_url)
}




