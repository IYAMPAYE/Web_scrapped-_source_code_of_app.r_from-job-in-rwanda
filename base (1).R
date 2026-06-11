library(rvest)
library(dplyr)

url <- "https://www.jobinrwanda.com/jobs/featured"

webpage <- read_html(url)

# Extract job titles
job_titles <- webpage %>%
  html_nodes("article .card-title span") %>%
  html_text(trim = TRUE)

# Extract job links using XPath to find <a> tags that have <h5 class="card-title"> inside
job_links_relative <- webpage %>%
  html_nodes(xpath = "//article//a[h5[@class='card-title']]") %>%
  html_attr("href")

# Prepend the base URL to make full links
base_url <- "https://www.jobinrwanda.com"
job_links <- paste0(base_url, job_links_relative)

# Extract company names
job_companies <- webpage %>%
  html_nodes("article .card-text a:first-of-type") %>%
  html_text(trim = TRUE)

# Extract job description text (used to parse location and date)
job_description <- webpage %>%
  html_nodes("article .card-text") %>%
  html_text(trim = TRUE)

# Extract locations and publication dates using regex
job_locations <- gsub(".*\\| (Kigali|[^|]+)\\s*\\|.*", "\\1", job_description)
date_published <- gsub(".*Published on ([0-9-]+).*", "\\1", job_description)

# Extract deadlines
job_deadlines <- webpage %>%
  html_nodes("article time") %>%
  html_text(trim = TRUE)

# Create data frame
jobs_data <- data.frame(
  Title = job_titles,
  Company = job_companies,
  Location = job_locations,
  Date_Published = date_published,
  Deadline = job_deadlines,
  Link = job_links,
  stringsAsFactors = FALSE
)

# Preview and save
print(jobs_data)
write.csv(jobs_data, "jobs_data.csv", row.names = FALSE)
