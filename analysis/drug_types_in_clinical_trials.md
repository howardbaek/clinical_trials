Types of drugs tested in clinical trials
================

## Introduction

Here, I’m investigating the types of drugs tested in drug intervention
clinical trials.

Often, drugs are mapped to identifiers so that ambiguity can be
alleviated when identifying drugs. The identifiers belong to certain
standard vocabulary. A well known and used vocabulary is RxNorm - this
vocabulary distinguishes drugs based on their formulation type. Another
vocabulary is the Anatomical Therapeutic Class (ATC) - this v ocabulary
categories drugs based on their mechanism of action.

For this notebook, I am going to map the drug names to vocabularies.

First, looks like I need to know whether a drug trial has a drug
intervention - that’s in the *interventions* table.

I want to use my cleaned *study\_phase\_age\_elibility.csv* file too -
I’ll join the
    two.

``` r
library(tidyverse)
```

    ## ── Attaching packages ────────────────────────────────────── tidyverse 1.2.1 ──

    ## ✔ ggplot2 3.0.0     ✔ purrr   0.2.5
    ## ✔ tibble  1.4.2     ✔ dplyr   0.7.6
    ## ✔ tidyr   0.8.1     ✔ stringr 1.3.1
    ## ✔ readr   1.1.1     ✔ forcats 0.3.0

    ## ── Conflicts ───────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
source("helper_functions.R")
```

    ## Loading required package: RPostgreSQL

    ## Loading required package: DBI

``` r
cleaned_study_age_phase_data <- read_csv("study_phase_age_eligibility.csv")
```

    ## Parsed with column specification:
    ## cols(
    ##   nct_id = col_character(),
    ##   clean_phase = col_character(),
    ##   minimum_master_age = col_integer(),
    ##   maximum_master_age = col_integer(),
    ##   pediatric_trial = col_logical(),
    ##   pediatric_inclusive = col_logical()
    ## )

``` r
con <- aact_connector()
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
interventions <- get_table(con,"interventions") %>% filter(intervention_type=="Drug") %>% collect()

joined <- left_join(cleaned_study_age_phase_data,interventions)
```

    ## Joining, by = "nct_id"

Now I need the RxNorm id of the drug. I don’t think it’s in the database
right now…well, I can join by name for now. Not sure how useful that’ll
be.

``` r
joined
```

    ## # A tibble: 417,688 x 10
    ##    nct_id clean_phase minimum_master_… maximum_master_… pediatric_trial
    ##    <chr>  <chr>                  <int>            <int> <lgl>          
    ##  1 NCT00… 1_2                       14               35 FALSE          
    ##  2 NCT00… <NA>                      NA               NA NA             
    ##  3 NCT00… <NA>                      18               NA NA             
    ##  4 NCT00… <NA>                      18               65 FALSE          
    ##  5 NCT00… <NA>                      17               60 FALSE          
    ##  6 NCT00… <NA>                      50               65 FALSE          
    ##  7 NCT00… <NA>                      18               49 FALSE          
    ##  8 NCT00… 1                         18               NA NA             
    ##  9 NCT00… <NA>                       8               18 FALSE          
    ## 10 NCT00… 3                          6               12 TRUE           
    ## # ... with 417,678 more rows, and 5 more variables:
    ## #   pediatric_inclusive <lgl>, id <int>, intervention_type <chr>,
    ## #   name <chr>, description <chr>

``` r
concept <- read_tsv("../../Research/Projects/pediatrics/vocabulary_download_v5_{d62de2e4-9825-4917-8ccb-d92395a5778e}_1535207123450/CONCEPT.csv") %>% filter(vocabulary_id=="ATC" | vocabulary_id=="RxNorm")
```

    ## Parsed with column specification:
    ## cols(
    ##   concept_id = col_integer(),
    ##   concept_name = col_character(),
    ##   domain_id = col_character(),
    ##   vocabulary_id = col_character(),
    ##   concept_class_id = col_character(),
    ##   standard_concept = col_character(),
    ##   concept_code = col_character(),
    ##   valid_start_date = col_integer(),
    ##   valid_end_date = col_integer(),
    ##   invalid_reason = col_character()
    ## )

``` r
joined_to_drug_id <- left_join(joined,concept,by=c("name"="concept_name"))
```

Are these drugs mapped to RxNorm or ATC vocabularies?

``` r
table(joined_to_drug_id$vocabulary_id)
```

    ## 
    ##    ATC RxNorm 
    ##  30845  54261

Many to RxNorm and ATC.

For ATC encoded drugs, what subclass do they map to?

``` r
joined_to_drug_id %>% 
        filter(vocabulary_id=="ATC") %>% 
        count(concept_class_id) %>% 
  arrange(desc(n))
```

    ## # A tibble: 2 x 2
    ##   concept_class_id     n
    ##   <chr>            <int>
    ## 1 ATC 5th          30175
    ## 2 ATC 4th            670

ATC 4th or 5th, so the most specific ATC categories.

For RxNorm encoded drugs, what subclass do they map to?

``` r
joined_to_drug_id %>% 
        filter(vocabulary_id=="RxNorm") %>% 
        count(concept_class_id) %>% 
  arrange(desc(n))
```

    ## # A tibble: 12 x 2
    ##    concept_class_id        n
    ##    <chr>               <int>
    ##  1 Ingredient          48594
    ##  2 Brand Name           3023
    ##  3 Precise Ingredient   2211
    ##  4 Clinical Drug Form    174
    ##  5 Clinical Drug Comp    101
    ##  6 Clinical Dose Group    73
    ##  7 Branded Dose Group     29
    ##  8 Dose Form              24
    ##  9 Branded Drug Form      18
    ## 10 Clinical Drug          10
    ## 11 Branded Drug Comp       3
    ## 12 Branded Drug            1

It ranges from the very specific drug ingredients to the brand or
clinical drug forms.

Great. The issue is I don’t know how faithful the mapping is since I’m
joining by name. Which can be ambiguous.
