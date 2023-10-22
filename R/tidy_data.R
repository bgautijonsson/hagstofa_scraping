library(dplyr)
library(tidyr)
library(readr)
library(here)
library(gt)
library(lubridate)

d <- read_rds(here("data-raw", "scraped_data.rds"))

tibble(data = d) |>
  unnest_wider(data) |>
  select(
    name, last_update, cumul_id, url
  ) |>
  # select(name, cumul_id) |>
  unnest_longer(cumul_id, indices_to = "path") |>
  filter(path != "id") |>
  summarise(
    path = str_c(path, collapse = " - "),
    .by = c(name, last_update, url)
  ) |>
  mutate(
    last_update = as_datetime(last_update)
  ) |>
  arrange(desc(last_update)) |>
  write_csv(
    here("data", "tables.csv")
  )
