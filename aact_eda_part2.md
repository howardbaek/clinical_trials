AACT database EDA – Part II
================

## Introduction

The [Clinical Trials Transformatiion
Initiative’s](https://www.ctti-clinicaltrials.org/who-we-are/strategic-plan)
mission is to “To develop and drive adoption of practices that will
increase the quality and efficiency of clinical trials”.

One of their projects is the [Aggregated Content of Clinical
Trials](https://aact.ctti-clinicaltrials.org/), which is “AACT is a
publicly available relational database that contains all information
(protocol and result data elements) about every study registered in
ClinicalTrials.gov.”

The purpose if this notebook is to serve as Part II of the exploratory
data analysis of the tables within this relational
database.

## List tables in database and target tables being explored in this notebook

Here I am connecting to the AACT database and just listing the tables to
be investigated in this
notebook.

``` r
if(require("RPostgreSQL")){library(RPostgreSQL)}else{install.packages("RPostgreSQL");library(RPostgreSQL)}
```

    ## Loading required package: RPostgreSQL

    ## Loading required package: DBI

``` r
if(require("DBI")){library(DBI)}else{install.packages("DBI");library(DBI)}
if(require("tidyverse")){library(tidyverse)}else{install.packages("tidyverse");library(tidyverse)}
```

    ## Loading required package: tidyverse

    ## ── Attaching packages ─────────────────────────────────────────────── tidyverse 1.2.1 ──

    ## ✔ ggplot2 3.0.0     ✔ purrr   0.2.5
    ## ✔ tibble  1.4.2     ✔ dplyr   0.7.6
    ## ✔ tidyr   0.8.1     ✔ stringr 1.3.1
    ## ✔ readr   1.1.1     ✔ forcats 0.3.0

    ## ── Conflicts ────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
if(require("skimr")){library(skimr)}else{devtools::install_github("ropenscilabs/skimr");library(skimr)}
```

    ## Loading required package: skimr

``` r
drv <- dbDriver('PostgreSQL')

con <- dbConnect(drv, 
                 dbname="aact",
                 host="aact-db.ctti-clinicaltrials.org", 
                 port=5432,
                 user=readr::read_tsv(".my.aact.cnf")$u, 
                 password=readr::read_tsv(".my.aact.cnf")$pw
                 )
```

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

``` r
dbTables <- dbListTables(con)

target_tables <- dbTables[floor(length(dbTables)/2):length(dbTables)]


target_tables
```

    ##  [1] "study_references"         "outcome_analyses"        
    ##  [3] "facility_investigators"   "outcome_counts"          
    ##  [5] "drop_withdrawals"         "baseline_measurements"   
    ##  [7] "outcome_analysis_groups"  "baseline_counts"         
    ##  [9] "browse_interventions"     "overall_officials"       
    ## [11] "calculated_values"        "id_information"          
    ## [13] "participant_flows"        "central_contacts"        
    ## [15] "intervention_other_names" "pending_results"         
    ## [17] "conditions"               "interventions"           
    ## [19] "reported_events"          "outcome_measurements"    
    ## [21] "outcomes"                 "countries"               
    ## [23] "ipd_information_types"    "responsible_parties"

## Collect AACT tables

Here I’m looping through the tables and collecting their contents from
the AACT database.

``` r
tables <- list()
for(i in 1:length(target_tables)){
  try(tables[[target_tables[i]]] <- tbl(con,target_tables[i]) %>% collect())
}
```

## Brief overview of target tables

In this section, I’m giving brief points and showing a bit of the data
from each table.

### Skim target tables

### study references

``` r
tab <- tables[["study_references"]]
nrow(tab)
```

    ## [1] 369454

``` r
head(tab)
```

    ## # A tibble: 6 x 5
    ##       id nct_id   pmid    reference_type citation                         
    ##    <int> <chr>    <chr>   <chr>          <chr>                            
    ## 1 817770 NCT0372… 8161995 reference      Goel AR, Kriger J, Bronfman R, L…
    ## 2 819457 NCT0371… 2296123 reference      Stafford RS. Alternative strateg…
    ## 3 819663 NCT0371… <NA>    reference      Agostini P, Knowles N. Autogenic…
    ## 4 817771 NCT0372… 2008387 reference      Rud B, Pedersen NW, Thomsen PB. …
    ## 5 817696 NCT0372… 200822… reference      Unger RZ, Amstutz SP, Seo DH, Hu…
    ## 6 817694 NCT0372… 176521… reference      Rex DK. Dosing considerations in…

``` r
apply(tab,2,skimr::n_missing)
```

    ##             id         nct_id           pmid reference_type       citation 
    ##              0              0          21639              0              0

This table contains the publication records (i.e. citations) for 369454
clinical trials. There are 21639 trials without references.

### outcome analyses

``` r
tab <- tables[["outcome_analyses"]]
nrow(tab)
```

    ## [1] 138638

``` r
head(tab)
```

    ## # A tibble: 6 x 22
    ##       id nct_id outcome_id non_inferiority… non_inferiority… param_type
    ##    <int> <chr>       <int> <chr>            <chr>            <chr>     
    ## 1 286582 NCT03…     514922 Superiority      ""               Least Squ…
    ## 2 286583 NCT03…     514922 Superiority      ""               Least Squ…
    ## 3 287410 NCT02…     516351 Superiority      ""               ""        
    ## 4 286549 NCT03…     514896 Superiority      Test of interac… Mean Diff…
    ## 5 286550 NCT03…     514896 Superiority      ""               Mean Diff…
    ## 6 286551 NCT03…     514896 Superiority      ""               Mean Diff…
    ## # ... with 16 more variables: param_value <dbl>, dispersion_type <chr>,
    ## #   dispersion_value <dbl>, p_value_modifier <chr>, p_value <dbl>,
    ## #   ci_n_sides <chr>, ci_percent <dbl>, ci_lower_limit <dbl>,
    ## #   ci_upper_limit <dbl>, ci_upper_limit_na_comment <chr>,
    ## #   p_value_description <chr>, method <chr>, method_description <chr>,
    ## #   estimate_description <chr>, groups_description <chr>,
    ## #   other_analysis_description <chr>

``` r
apply(tab,2,skimr::n_missing)
```

    ##                          id                      nct_id 
    ##                           0                           0 
    ##                  outcome_id        non_inferiority_type 
    ##                           0                           0 
    ## non_inferiority_description                  param_type 
    ##                           0                           0 
    ##                 param_value             dispersion_type 
    ##                       46057                           0 
    ##            dispersion_value            p_value_modifier 
    ##                      112777                      100045 
    ##                     p_value                  ci_n_sides 
    ##                       24645                           0 
    ##                  ci_percent              ci_lower_limit 
    ##                       49482                       51657 
    ##              ci_upper_limit   ci_upper_limit_na_comment 
    ##                       51974                           0 
    ##         p_value_description                      method 
    ##                           0                           0 
    ##          method_description        estimate_description 
    ##                           0                           0 
    ##          groups_description  other_analysis_description 
    ##                           0                           0

This table contains 138638 outcome analyses from 138638 clinical trials.
I’m not sure what each column means…Luckily, this
[document](ClinicalTrials.gov%20Results%20Data%20Element...terventional%20and%20Observational%20Studies)
contains that information\! The different columns list the types of
statistical tests used and their parameters. Alot of these parameters
are missing.

### facility investigators

``` r
tab <- tables[["facility_investigators"]]
nrow(tab)
```

    ## [1] 182257

``` r
head(tab)
```

    ## # A tibble: 6 x 5
    ##       id nct_id     facility_id role             name                     
    ##    <int> <chr>            <int> <chr>            <chr>                    
    ## 1 921727 NCT037252…     5842261 Principal Inves… Alice Nieuwboer, PhD     
    ## 2 921728 NCT037251…     5842384 Principal Inves… Helen Steed              
    ## 3 921729 NCT037250…     5842386 Principal Inves… Maria Startseva, MD      
    ## 4 921730 NCT037250…     5842387 Principal Inves… Alexander Sobolev, MD    
    ## 5 921731 NCT037250…     5842388 Principal Inves… Tatiana Meleshkevich, MD…
    ## 6 921732 NCT037250…     5842389 Principal Inves… Ashot Mkrtumyan, MD, PhD…

``` r
apply(tab,2,skimr::n_missing)
```

    ##          id      nct_id facility_id        role        name 
    ##           0           0           0           0           0

This table contains 182257 facility roles for 182257 clinical
trials.

``` r
tab %>% group_by(role) %>% count() %>% ggplot() + geom_bar(stat="identity",aes(role,n,fill=role)) + coord_flip()
```

![](aact_eda_part2_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

Apparently, mostly principal investigators are listed and then
sub-investigators. But no study chairs.

### outcome counts

``` r
tab <- tables[["outcome_counts"]]
nrow(tab)
```

    ## [1] 584065

``` r
head(tab)
```

    ## # A tibble: 6 x 8
    ##       id nct_id outcome_id result_group_id ctgov_group_code scope units
    ##    <int> <chr>       <int>           <int> <chr>            <chr> <chr>
    ## 1 1.21e6 NCT03…     514878         1699206 O1               Meas… Part…
    ## 2 1.21e6 NCT03…     514879         1699210 O1               Meas… Part…
    ## 3 1.21e6 NCT03…     514880         1699211 O1               Meas… Part…
    ## 4 1.21e6 NCT03…     514881         1699212 O1               Meas… Part…
    ## 5 1.21e6 NCT03…     514893         1699279 O2               Meas… Part…
    ## 6 1.21e6 NCT03…     514893         1699280 O1               Meas… Part…
    ## # ... with 1 more variable: count <int>

``` r
apply(tab,2,skimr::n_missing)
```

    ##               id           nct_id       outcome_id  result_group_id 
    ##                0                0                0                0 
    ## ctgov_group_code            scope            units            count 
    ##                0                0                0                0

This table contains the counts of outcomes, about 584065, for 33582
clinical trials. This table is completely filled but only has
information on a relatively few clinical trials.

### drop withdrawals

``` r
tab <- tables[["drop_withdrawals"]]
nrow(tab)
```

    ## [1] 252564

``` r
head(tab)
```

    ## # A tibble: 6 x 7
    ##       id nct_id  result_group_id ctgov_group_code period  reason     count
    ##    <int> <chr>             <int> <chr>            <chr>   <chr>      <int>
    ## 1 526522 NCT036…         1699205 P1               Overal… Protocol …     1
    ## 2 526523 NCT036…         1699209 P1               Overal… Study was…    95
    ## 3 526524 NCT035…         1699277 P2               Overal… Lost to F…    29
    ## 4 526525 NCT035…         1699278 P1               Overal… Lost to F…    26
    ## 5 526526 NCT035…         1699290 P2               Analyz… Protocol …     1
    ## 6 526527 NCT035…         1699291 P1               Analyz… Protocol …     4

``` r
apply(tab,2,skimr::n_missing)
```

    ##               id           nct_id  result_group_id ctgov_group_code 
    ##                0                0                0                0 
    ##           period           reason            count 
    ##                0                0                0

This table contains study drop information for 21336 clinical trials.
This table is completely filled but only has information on a relatively
few clinical trials.

\#\#\#baseline measurements

``` r
tab <- tables[["baseline_measurements"]]
nrow(tab)
```

    ## [1] 854306

``` r
head(tab)
```

    ## # A tibble: 6 x 18
    ##       id nct_id result_group_id ctgov_group_code classification category
    ##    <int> <chr>            <int> <chr>            <chr>          <chr>   
    ## 1 1.77e6 NCT02…         1706663 B3               United States  ""      
    ## 2 1.77e6 NCT02…         1706664 B2               United States  ""      
    ## 3 1.77e6 NCT02…         1706665 B1               United States  ""      
    ## 4 1.77e6 NCT02…         1706663 B3               ""             Male    
    ## 5 1.77e6 NCT02…         1706664 B2               ""             Male    
    ## 6 1.77e6 NCT02…         1706665 B1               ""             Male    
    ## # ... with 12 more variables: title <chr>, description <chr>, units <chr>,
    ## #   param_type <chr>, param_value <chr>, param_value_num <dbl>,
    ## #   dispersion_type <chr>, dispersion_value <chr>,
    ## #   dispersion_value_num <dbl>, dispersion_lower_limit <dbl>,
    ## #   dispersion_upper_limit <dbl>, explanation_of_na <chr>

``` r
apply(tab,2,skimr::n_missing)
```

    ##                     id                 nct_id        result_group_id 
    ##                      0                      0                      0 
    ##       ctgov_group_code         classification               category 
    ##                      0                      0                      0 
    ##                  title            description                  units 
    ##                      0                      0                      0 
    ##             param_type            param_value        param_value_num 
    ##                      0                      0                   2590 
    ##        dispersion_type       dispersion_value   dispersion_value_num 
    ##                      0                 733663                 733666 
    ## dispersion_lower_limit dispersion_upper_limit      explanation_of_na 
    ##                 834641                 834675                      0

This table contains study measurement info for 33473 clinical trials.
This table is missing some parameter values and only has information on
a relatively few clinical trials.

### outcome analysis groups

``` r
tab <- tables[["outcome_analysis_groups"]]
nrow(tab)
```

    ## [1] 267779

``` r
head(tab)
```

    ## # A tibble: 6 x 5
    ##       id nct_id      outcome_analysis_id result_group_id ctgov_group_code
    ##    <int> <chr>                     <int>           <int> <chr>           
    ## 1 553325 NCT03582943              286549         1699292 O2              
    ## 2 553326 NCT03582943              286549         1699293 O1              
    ## 3 553327 NCT03582943              286550         1699292 O2              
    ## 4 553328 NCT03582943              286550         1699293 O1              
    ## 5 553329 NCT03582943              286551         1699292 O2              
    ## 6 553330 NCT03582943              286551         1699293 O1

``` r
apply(tab,2,skimr::n_missing)
```

    ##                  id              nct_id outcome_analysis_id 
    ##                   0                   0                   0 
    ##     result_group_id    ctgov_group_code 
    ##                   0                   0

This table contains study outcome analysis information for 11890
clinical trials. This table is completely filled but only has
information on a relatively few clinical trials. And I’m not sire what
the ctgov\_group\_code means…

### baseline counts

``` r
tab <- tables[["baseline_counts"]]
nrow(tab)
```

    ## [1] 93986

``` r
head(tab)
```

    ## # A tibble: 6 x 7
    ##       id nct_id    result_group_id ctgov_group_code units     scope  count
    ##    <int> <chr>               <int> <chr>            <chr>     <chr>  <int>
    ## 1 193306 NCT03670…         1699204 B1               Particip… Overa…   101
    ## 2 193307 NCT03648…         1699208 B1               Particip… Overa…     0
    ## 3 193316 NCT03585…         1699274 B3               Particip… Overa…    81
    ## 4 193317 NCT03585…         1699275 B2               Particip… Overa…    40
    ## 5 193318 NCT03585…         1699276 B1               Particip… Overa…    41
    ## 6 193319 NCT03582…         1699287 B3               Particip… Overa…    69

``` r
apply(tab,2,skimr::n_missing)
```

    ##               id           nct_id  result_group_id ctgov_group_code 
    ##                0                0                0                0 
    ##            units            scope            count 
    ##                0                0                0

This table contains study baseline counts information for 33582 clinical
trials. This table is completely filled but only has information on a
relatively few clinical trials. I’m also not sure what these columnns
mean…

## Outline going forward

Great\! I’m able to collect these tables and I can go through them to
better understand their content to do an analysis
