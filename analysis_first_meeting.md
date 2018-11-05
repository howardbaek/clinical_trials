Analysis
================
Jason Baik
10/29/2018

### Load packages

``` r
library(tidyverse)
```

    ## ── Attaching packages ─────────────────────────────────────────────── tidyverse 1.2.1 ──

    ## ✔ ggplot2 3.0.0     ✔ purrr   0.2.5
    ## ✔ tibble  1.4.2     ✔ dplyr   0.7.6
    ## ✔ tidyr   0.8.1     ✔ stringr 1.3.1
    ## ✔ readr   1.1.1     ✔ forcats 0.3.0

    ## ── Conflicts ────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
library(XML)

source("try_aact_ct_database_download.R")
```

    ## Loading required package: RPostgreSQL

    ## Loading required package: DBI

    ## Parsed with column specification:
    ## cols(
    ##   u = col_character(),
    ##   pw = col_character()
    ## )
    ## Parsed with column specification:
    ## cols(
    ##   u = col_character(),
    ##   pw = col_character()
    ## )

### What Nick wants to analyze

  - Latent Direchlet Allocation with MeSH terms from trials
  - Assess the life cycle of a clinical trial
  - Aq ssess the investigation of drugs across clinical trials for
    different
conditions

### Description of List of Tables / Columns

www.ctti-clinicaltrials.org/files/aact201603\_comprehensive\_data\_dictionary\_1.xlsx

### Github Repos

1)  <https://github.com/statwonk/aact>

<!-- end list -->

  - txt format files of AACT data

<!-- end list -->

2)  <https://github.com/kchis/AACT-Sample-Graphs>

<!-- end list -->

  - example graphs summarizing characteristics of interventional trials
    in ClinicalTrials.gov, 2008-2017

<!-- end list -->

3)  <https://github.com/datasciences1/aact>
4)  <https://github.com/Shou-Yu-YAN/AACT_database>

<!-- end list -->

  - Some analysis in R \!\!\!

### Prove AACT pulled data from clinicaltrials.org

``` r
# id_information table from AACT
aact_nct_id <- tbl(con, "id_information") %>% 
  collect() %>% 
  select(nct_id) %>% 
  pull() %>% 
  unique()


# Name (NCT IDs) of all the XML files
test <- list.files(path = "data/AllPublicXML/", pattern = "^NCT",
           recursive = TRUE)
orig_nct_id <- substr(test, 13, nchar(test) - 4)
orig_nct_id <- orig_nct_id %>% unique()

# Intersection
intersect(aact_nct_id, orig_nct_id) %>% length()
```

    ## [1] 288254
