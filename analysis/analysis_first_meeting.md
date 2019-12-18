Analysis
================
Howard Baek
10/29/2018

### Load packages

``` r
library(tidyverse)
```

    ## ── Attaching packages ──────────────────────────────────── tidyverse 1.2.1 ──

    ## ✓ ggplot2 3.2.1     ✓ purrr   0.3.3
    ## ✓ tibble  2.1.3     ✓ dplyr   0.8.3
    ## ✓ tidyr   1.0.0     ✓ stringr 1.4.0
    ## ✓ readr   1.3.1     ✓ forcats 0.4.0

    ## ── Conflicts ─────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library(tidytext)
library(topicmodels)

if(require("RPostgreSQL")){library(RPostgreSQL)}else{install.packages("RPostgreSQL");library(RPostgreSQL)}
```

    ## Loading required package: RPostgreSQL

    ## Loading required package: DBI

``` r
if(require("DBI")){library(DBI)}else{install.packages("DBI");library(DBI)}
if(require("tidyverse")){library(tidyverse)}else{install.packages("tidyverse");library(tidyverse)}

drv <- dbDriver('PostgreSQL')
con <- dbConnect(drv, 
                 dbname="aact",
                 host="aact-db.ctti-clinicaltrials.org", 
                 port=5432,
                 user=readr::read_csv("id_pw.csv")$id, 
                 password=readr::read_csv("id_pw.csv")$pw
                 )
```

    ## Parsed with column specification:
    ## cols(
    ##   id = col_character(),
    ##   pw = col_character()
    ## )

    ## Parsed with column specification:
    ## cols(
    ##   id = col_character(),
    ##   pw = col_character()
    ## )

``` r
dbListTables(con) %>% View("List of Tables")



aact_connect <- function(user, password) {

  drv <- DBI::dbDriver('PostgreSQL')
  con <- DBI::dbConnect(drv,
                   dbname = "aact",
                   host = "aact-db.ctti-clinicaltrials.org",
                   port = 5432,
                   user = user,
                   password = password)
  
  return(con)
}
```

### What Nick wants to analyze

  - Latent Direchlet Allocation with MeSH terms from trials
  - Assess the life cycle of a clinical trial
  - Assess the investigation of drugs across clinical trials for
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

### EDA

``` r
# Observe the first 22 tables
tbl(con, "documents") %>% 
  collect() %>% 
  head()
```

    ## # A tibble: 6 x 6
    ##      id nct_id  document_id    document_type        url           comment       
    ##   <int> <chr>   <chr>          <chr>                <chr>         <chr>         
    ## 1 10114 NCT042… <NA>           Individual Particip… https://www.… We are organi…
    ## 2 10115 NCT042… <NA>           Individual Particip… https://yare… The data of t…
    ## 3 10116 NCT041… <NA>           web-site link        http://perit… <NA>          
    ## 4 10117 NCT041… <NA>           Protocol, Validatio… https://hidr… Password will…
    ## 5 10118 NCT041… <NA>           Statistical Analysi… http://aktiv… Pre-defined s…
    ## 6 10119 NCT041… NSCLC Radiomi… Individual Particip… https://wiki… <NA>

eligibilities -\> `minimum_age` is a quantitative variable
brief\_summaries -\> text values of summaries facilities -\> text
description of institutions where study was held browse\_conditions -\>
`nct_id` / mesh terms schema\_migrations -\> Does not exist links -\>
`url` of study result\_contacts -\> contact info for researchers
design\_outcomes -\> text description of outcomes mesh\_headings -\>
heading / subcategory result\_groups -\> text descriptions (example:
Subjects were administered with insulin glargine (IGlar: 100 U/mL)
subcutaneously (s.c.) once daily for a duration of 26 weeks) sponsors
-\> list of all the sponsors designs -\> design of experiment milestones
-\> studies -\> date values of dates related to study
detailed\_descriptions -\> more detailed descriptions… documents -\>
`document_type` seems important / interesting

#### eligibilities

``` r
theme_set(theme_light())

elig <- tbl(con, "eligibilities") %>% 
  collect() 

names(elig)
```

    ##  [1] "id"                 "nct_id"             "sampling_method"   
    ##  [4] "gender"             "minimum_age"        "maximum_age"       
    ##  [7] "healthy_volunteers" "population"         "criteria"          
    ## [10] "gender_description" "gender_based"

``` r
## Distribution of Minimum Age for Trial
elig %>% 
  count(minimum_age, sort = TRUE) %>% 
  filter(n > 1000,
         minimum_age != "N/A") %>% 
  mutate(minimum_age = as.character(parse_number(minimum_age))) %>% 
  mutate(minimum_age = fct_reorder(minimum_age, n)) %>% 
  ggplot(aes(minimum_age, n)) +
  geom_col() +
  labs(x = "Minimum Age for Trial",
       y = "Count") +
  ggtitle("Distribution of Minimum Age for Trial",
          subtitle = "Count > 1000")
```

![](analysis_first_meeting_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

``` r
## Distribution of Maximum Age for Trial
elig %>% 
  count(maximum_age, sort = TRUE) %>% 
  filter(n > 1000,
         maximum_age != "N/A") %>% 
  mutate(maximum_age = as.character(parse_number(maximum_age))) %>% 
  mutate(maximum_age = fct_reorder(maximum_age, n)) %>% 
  ggplot(aes(maximum_age, n)) +
  geom_col() +
  labs(x = "Maximum Age for Trial",
       y = "Count") +
  ggtitle("Distribution of Maximum Age for Trial")
```

![](analysis_first_meeting_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

``` r
data("AssociatedPress")
AssociatedPress
```

    ## <<DocumentTermMatrix (documents: 2246, terms: 10473)>>
    ## Non-/sparse entries: 302031/23220327
    ## Sparsity           : 99%
    ## Maximal term length: 18
    ## Weighting          : term frequency (tf)

``` r
ap_lda <- LDA(AssociatedPress, k = 2, control = list(seed = 1234))

ap_topics <- tidy(ap_lda, matrix = "beta")
ap_topics
```

    ## # A tibble: 20,946 x 3
    ##    topic term           beta
    ##    <int> <chr>         <dbl>
    ##  1     1 aaron      1.69e-12
    ##  2     2 aaron      3.90e- 5
    ##  3     1 abandon    2.65e- 5
    ##  4     2 abandon    3.99e- 5
    ##  5     1 abandoned  1.39e- 4
    ##  6     2 abandoned  5.88e- 5
    ##  7     1 abandoning 2.45e-33
    ##  8     2 abandoning 2.34e- 5
    ##  9     1 abbott     2.13e- 6
    ## 10     2 abbott     2.97e- 5
    ## # … with 20,936 more rows

``` r
ap_top_terms <- ap_topics %>% 
  group_by(topic) %>% 
  top_n(10, beta) %>% 
  ungroup() %>% 
  arrange(topic, -beta)

ap_top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()
```

![](analysis_first_meeting_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

``` r
beta_spread <- ap_topics %>%
  mutate(topic = paste0("topic", topic)) %>%
  spread(topic, beta) %>%
  filter(topic1 > .001 | topic2 > .001) %>%
  mutate(log_ratio = log2(topic2 / topic1))

beta_spread
```

    ## # A tibble: 198 x 4
    ##    term              topic1      topic2 log_ratio
    ##    <chr>              <dbl>       <dbl>     <dbl>
    ##  1 administration 0.000431  0.00138         1.68 
    ##  2 ago            0.00107   0.000842       -0.339
    ##  3 agreement      0.000671  0.00104         0.630
    ##  4 aid            0.0000476 0.00105         4.46 
    ##  5 air            0.00214   0.000297       -2.85 
    ##  6 american       0.00203   0.00168        -0.270
    ##  7 analysts       0.00109   0.000000578   -10.9  
    ##  8 area           0.00137   0.000231       -2.57 
    ##  9 army           0.000262  0.00105         2.00 
    ## 10 asked          0.000189  0.00156         3.05 
    ## # … with 188 more rows

``` r
ap_documents <- tidy(ap_lda, matrix = "gamma")

tidy(AssociatedPress) %>% 
  filter(document == 6) %>% 
  arrange(desc(count))
```

    ## # A tibble: 287 x 3
    ##    document term           count
    ##       <int> <chr>          <dbl>
    ##  1        6 noriega           16
    ##  2        6 panama            12
    ##  3        6 jackson            6
    ##  4        6 powell             6
    ##  5        6 administration     5
    ##  6        6 economic           5
    ##  7        6 general            5
    ##  8        6 i                  5
    ##  9        6 panamanian         5
    ## 10        6 american           4
    ## # … with 277 more rows
