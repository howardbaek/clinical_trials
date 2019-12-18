AACT database sumary
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

The purpose if this notebook is to simply collect, display, and provide
a a brief descriptive summary of the AACT tables.

## List tables in database

Here I am connecting to the AACT database and just listing the tables to
be investigated in this
notebook.

``` r
if(require("RPostgreSQL")){library(RPostgreSQL)}else{install.packages("RPostgreSQL");library(RPostgreSQL)}
```

    Loading required package: RPostgreSQL

    Loading required package: DBI

``` r
if(require("DBI")){library(DBI)}else{install.packages("DBI");library(DBI)}
if(require("tidyverse")){library(tidyverse)}else{install.packages("tidyverse");library(tidyverse)}
```

    Loading required package: tidyverse

    ── Attaching packages ─────────────────────────────────────────────── tidyverse 1.2.1 ──

    ✔ ggplot2 3.0.0     ✔ purrr   0.2.5
    ✔ tibble  1.4.2     ✔ dplyr   0.7.6
    ✔ tidyr   0.8.1     ✔ stringr 1.3.1
    ✔ readr   1.1.1     ✔ forcats 0.3.0

    ── Conflicts ────────────────────────────────────────────────── tidyverse_conflicts() ──
    ✖ dplyr::filter() masks stats::filter()
    ✖ dplyr::lag()    masks stats::lag()

``` r
if(require("skimr")){library(skimr)}else{devtools::install_github("ropenscilabs/skimr");library(skimr)}
```

    Loading required package: skimr

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

    Parsed with column specification:
    cols(
      u = col_character(),
      pw = col_character()
    )

    Parsed with column specification:
    cols(
      u = col_character(),
      pw = col_character()
    )

``` r
dbTables <- dbListTables(con)

dbTables
```

``` 
 [1] "schema_migrations"          "studies"                   
 [3] "study_references"           "detailed_descriptions"     
 [5] "responsible_parties"        "browse_interventions"      
 [7] "sponsors"                   "baseline_measurements"     
 [9] "drop_withdrawals"           "outcome_measurements"      
[11] "eligibilities"              "facility_contacts"         
[13] "overall_officials"          "facility_investigators"    
[15] "facilities"                 "outcomes"                  
[17] "result_agreements"          "result_contacts"           
[19] "result_groups"              "ipd_information_types"     
[21] "conditions"                 "countries"                 
[23] "design_group_interventions" "documents"                 
[25] "id_information"             "participant_flows"         
[27] "baseline_counts"            "intervention_other_names"  
[29] "pending_results"            "brief_summaries"           
[31] "interventions"              "reported_events"           
[33] "browse_conditions"          "keywords"                  
[35] "calculated_values"          "links"                     
[37] "central_contacts"           "mesh_headings"             
[39] "mesh_terms"                 "milestones"                
[41] "outcome_analyses"           "design_groups"             
[43] "outcome_analysis_groups"    "design_outcomes"           
[45] "designs"                    "outcome_counts"            
```

## Collect AACT tables

Here I’m looping through the tables and collecting their contents from
the AACT database.

``` r
tables <- list()
for(i in 1:length(dbTables)){
  try(tables[[dbTables[i]]] <- tbl(con,dbTables[i]) %>% collect())
}
```

## Display and skim populated AACT tables

``` r
dne <- c()
for(name in dbTables){
  tab <- tables[[name]]
  if(!is.null(tab)){
    cat(paste0(name," table exists\n\n"))
    print(head(tab))
    print(skim(tab))
    cat("\n")
  }else{
    cat(paste0("table ",name," doesn't exist\n\n"))
    dne <- c(dne,name)
  }
}
```

``` 
table schema_migrations doesn't exist

studies table exists

# A tibble: 6 x 64
  nct_id nlm_download_da… study_first_sub… results_first_s…
  <chr>  <chr>            <date>           <date>          
1 NCT03… ClinicalTrials.… 2018-03-21       NA              
2 NCT03… ClinicalTrials.… 2018-04-02       NA              
3 NCT03… ClinicalTrials.… 2018-02-14       NA              
4 NCT03… ClinicalTrials.… 2018-04-10       NA              
5 NCT03… ClinicalTrials.… 2018-03-27       NA              
6 NCT03… ClinicalTrials.… 2018-03-09       NA              
# ... with 60 more variables: disposition_first_submitted_date <date>,
#   last_update_submitted_date <date>,
#   study_first_submitted_qc_date <date>, study_first_posted_date <date>,
#   study_first_posted_date_type <chr>,
#   results_first_submitted_qc_date <date>,
#   results_first_posted_date <date>,
#   results_first_posted_date_type <chr>,
#   disposition_first_submitted_qc_date <date>,
#   disposition_first_posted_date <date>,
#   disposition_first_posted_date_type <chr>,
#   last_update_submitted_qc_date <date>, last_update_posted_date <date>,
#   last_update_posted_date_type <chr>, start_month_year <chr>,
#   start_date_type <chr>, start_date <date>,
#   verification_month_year <chr>, verification_date <date>,
#   completion_month_year <chr>, completion_date_type <chr>,
#   completion_date <date>, primary_completion_month_year <chr>,
#   primary_completion_date_type <chr>, primary_completion_date <date>,
#   target_duration <chr>, study_type <chr>, acronym <chr>,
#   baseline_population <chr>, brief_title <chr>, official_title <chr>,
#   overall_status <chr>, last_known_status <chr>, phase <chr>,
#   enrollment <int>, enrollment_type <chr>, source <chr>,
#   limitations_and_caveats <chr>, number_of_arms <int>,
#   number_of_groups <int>, why_stopped <chr>, has_expanded_access <lgl>,
#   expanded_access_type_individual <lgl>,
#   expanded_access_type_intermediate <lgl>,
#   expanded_access_type_treatment <lgl>, has_dmc <lgl>,
#   is_fda_regulated_drug <lgl>, is_fda_regulated_device <lgl>,
#   is_unapproved_device <lgl>, is_ppsd <lgl>, is_us_export <lgl>,
#   biospec_retention <chr>, biospec_description <chr>,
#   ipd_time_frame <chr>, ipd_access_criteria <chr>, ipd_url <chr>,
#   plan_to_share_ipd <chr>, plan_to_share_ipd_description <chr>,
#   created_at <dttm>, updated_at <dttm>
Skim summary statistics
 n obs: 291109 
 n variables: 64 

── Variable type:character ─────────────────────────────────────────────────────────────
                           variable missing complete      n min  max
                            acronym  217081    74028 291109   1   14
                baseline_population       0   291109 291109   0  350
                biospec_description       0   291109 291109   0 1143
                  biospec_retention  277454    13655 291109  13   19
                        brief_title       0   291109 291109   7  300
               completion_date_type   26118   264991 291109   6   11
              completion_month_year   19211   271898 291109   8   18
 disposition_first_posted_date_type  284758     6351 291109   6    8
                    enrollment_type   16884   274225 291109   6   11
                ipd_access_criteria  289225     1884 291109   3 1000
                     ipd_time_frame  288951     2158 291109   1  806
                            ipd_url  289847     1262 291109   9  156
                  last_known_status  262094    29015 291109  10   23
       last_update_posted_date_type       0   291109 291109   6    8
            limitations_and_caveats       0   291109 291109   0  250
                             nct_id       0   291109 291109  11   11
      nlm_download_date_description       0   291109 291109  59   59
                     official_title   10327   280782 291109  18  598
                     overall_status       0   291109 291109   8   25
                              phase   60124   230985 291109   3   15
                  plan_to_share_ipd  213764    77345 291109   2    9
      plan_to_share_ipd_description  276463    14646 291109   1 1000
       primary_completion_date_type   22356   268753 291109   6   11
      primary_completion_month_year   22291   268818 291109   8   18
     results_first_posted_date_type  257354    33755 291109   6    8
                             source       0   291109 291109   2  147
                    start_date_type  204273    86836 291109   6   11
                   start_month_year    4731   286378 291109   8   18
       study_first_posted_date_type       0   291109 291109   6    8
                         study_type       0   291109 291109   3   32
                    target_duration  286691     4418 291109   5   10
            verification_month_year     803   290306 291109   8   18
                        why_stopped  271768    19341 291109   2  175
  empty n_unique
      0    59832
 282067     7676
 277385    10603
      0        3
      0   289201
      0        2
      0     6677
      0        2
      0        2
      0     1164
      0     1336
      0      240
      0        4
      0        2
 283650     7051
      0   291109
      0        1
      0   278331
      0       14
      0        8
      0        3
      0     9172
      0        2
      0     6247
      0        2
      0    18537
      0        2
      0     6020
      0        2
      0        5
      0      131
      0     1314
      0    14483

── Variable type:Date ──────────────────────────────────────────────────────────────────
                            variable missing complete      n        min
                     completion_date   19211   271898 291109 1900-01-31
       disposition_first_posted_date  284758     6351 291109 2009-08-10
    disposition_first_submitted_date  284758     6351 291109 2008-10-09
 disposition_first_submitted_qc_date  284758     6351 291109 2009-07-10
             last_update_posted_date       0   291109 291109 2005-06-24
          last_update_submitted_date       0   291109 291109 2005-06-23
       last_update_submitted_qc_date       0   291109 291109 2005-06-23
             primary_completion_date   22291   268818 291109 1900-01-31
           results_first_posted_date  257354    33755 291109 2008-09-26
        results_first_submitted_date  257354    33755 291109 2008-09-25
     results_first_submitted_qc_date  257354    33755 291109 2008-09-25
                          start_date    4731   286378 291109 1900-01-31
             study_first_posted_date       0   291109 291109 1999-09-20
          study_first_submitted_date       0   291109 291109 1999-09-17
       study_first_submitted_qc_date       0   291109 291109 1999-09-17
                   verification_date     803   290306 291109 1981-10-31
        max     median n_unique
 2100-12-31 2015-12-31     6333
 2018-11-30 2014-03-04     1523
 2018-11-29 2014-01-16     1921
 2018-11-29 2014-01-30     1924
 2018-11-30 2016-11-02     3313
 2018-11-29 2016-10-30     4545
 2018-11-29 2016-10-30     4545
 2100-12-31 2015-10-31     5922
 2018-11-30 2015-04-16     2425
 2018-11-02 2014-12-12     3134
 2018-11-29 2015-04-07     3081
 2100-01-31 2012-10-31     5814
 2018-11-30 2013-05-27     4429
 2018-11-29 2013-04-29     6111
 2018-11-29 2013-05-23     5911
 2018-11-30 2016-08-31     1285

── Variable type:integer ───────────────────────────────────────────────────────────────
         variable missing complete      n     mean         sd p0 p25 p50
       enrollment    6583   284526 291109 24999.22 2928526.12  0  30  70
   number_of_arms   84319   206790 291109     2.12       1.27  1   1   2
 number_of_groups  254532    36577 291109     1.79       1.19  1   1   1
 p75  p100     hist
 200 1e+09 ▇▁▁▁▁▁▁▁
   2    32 ▇▁▁▁▁▁▁▁
   2    30 ▇▁▁▁▁▁▁▁

── Variable type:logical ───────────────────────────────────────────────────────────────
                          variable missing complete      n    mean
   expanded_access_type_individual  291030       79 291109 1      
 expanded_access_type_intermediate  291080       29 291109 1      
    expanded_access_type_treatment  291066       43 291109 1      
                           has_dmc   52882   238227 291109 0.38   
               has_expanded_access    5067   286042 291109 0.0014 
           is_fda_regulated_device  225665    65444 291109 0.063  
             is_fda_regulated_drug  225602    65507 291109 0.23   
                           is_ppsd  287851     3258 291109 0.00061
              is_unapproved_device  287034     4075 291109 0.21   
                      is_us_export  280249    10860 291109 0.28   
                              count
                NA: 291030, TRU: 79
                NA: 291080, TRU: 29
                NA: 291066, TRU: 43
 FAL: 147645, TRU: 90582, NA: 52882
    FAL: 285643, NA: 5067, TRU: 399
  NA: 225665, FAL: 61343, TRU: 4101
 NA: 225602, FAL: 50676, TRU: 14831
      NA: 287851, FAL: 3256, TRU: 2
    NA: 287034, FAL: 3234, TRU: 841
   NA: 280249, FAL: 7783, TRU: 3077

── Variable type:POSIXct ───────────────────────────────────────────────────────────────
   variable missing complete      n        min        max     median
 created_at       0   291109 291109 2018-12-01 2018-12-02 2018-12-01
 updated_at       0   291109 291109 2018-12-01 2018-12-02 2018-12-01
 n_unique
   291109
   291109

study_references table exists

# A tibble: 6 x 5
       id nct_id   pmid   reference_type citation                         
    <int> <chr>    <chr>  <chr>          <chr>                            
1 1231961 NCT0375… <NA>   reference      Castell BD, Kazantzis N, Moss‐Mo…
2 1232158 NCT0375… 14508… reference      Sundin EC, Horowitz MJ. Horowitz…
3 1231941 NCT0375… 26093… reference      Wallace G, Jodele S, Howell J, M…
4 1231942 NCT0375… 29782… reference      Wallace G, Jodele S, Myers KC, D…
5 1231943 NCT0375… 24910… reference      Hansson ME, Norlin AC, Omazic B,…
6 1231944 NCT0375… 27358… reference      Caballero-Velázquez T, Montero I…
Skim summary statistics
 n obs: 371571 
 n variables: 5 

── Variable type:character ─────────────────────────────────────────────────────────────
       variable missing complete      n min  max empty n_unique
       citation       0   371571 371571   2 5662     0   297634
         nct_id       0   371571 371571  11   11     0    59148
           pmid   21826   349745 371571   1    8     0   276569
 reference_type       0   371571 371571   9   17     0        2

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n       mean        sd      p0       p25
       id       0   371571 371571 1418262.52 107407.04 1231941 1325361.5
     p50       p75    p100     hist
 1418305 1511283.5 1604199 ▇▇▇▇▇▇▇▇

detailed_descriptions table exists

# A tibble: 6 x 3
      id nct_id     description                                           
   <int> <chr>      <chr>                                                 
1 635895 NCT035771… "\n      This SONABRE registry is an ongoing observat…
2 635896 NCT035771… "\n      Galvecta Plus is a combination of Vildaglipt…
3 635897 NCT035771… "\n      This is a Phase 2a, Multi-center, Double-bli…
4 635898 NCT035771… "\n      Polyphenol rich plant foods have been associ…
5 635899 NCT035771… "\n      The overall objective of this study is to de…
6 635900 NCT035771… "\n      Background:\n\n      Twenty percent of older…
Skim summary statistics
 n obs: 188396 
 n variables: 3 

── Variable type:character ─────────────────────────────────────────────────────────────
    variable missing complete      n min   max empty n_unique
 description       0   188396 188396  13 37641     0   187025
      nct_id       0   188396 188396  11    11     0   188396

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n      mean       sd     p0       p25
       id       0   188396 188396 720597.65 54466.66 626073 673460.75
      p50       p75   p100     hist
 720631.5 767763.25 814882 ▇▇▇▇▇▇▇▇

responsible_parties table exists

# A tibble: 6 x 7
      id nct_id  responsible_part… name   title organization affiliation  
   <int> <chr>   <chr>             <chr>  <chr> <chr>        <chr>        
1 898636 NCT037… Sponsor           <NA>   <NA>  <NA>         <NA>         
2 898637 NCT037… Sponsor           <NA>   <NA>  <NA>         <NA>         
3 898595 NCT037… Principal Invest… Marja… Rese… <NA>         Helsinki Uni…
4 898596 NCT037… Principal Invest… Emad … Dire… <NA>         ClinAmygate  
5 898597 NCT037… Sponsor           <NA>   <NA>  <NA>         <NA>         
6 898599 NCT037… Sponsor           <NA>   <NA>  <NA>         <NA>         
Skim summary statistics
 n obs: 271770 
 n variables: 7 

── Variable type:character ─────────────────────────────────────────────────────────────
               variable missing complete      n min max empty n_unique
            affiliation  173199    98571 271770   3 120     0     7140
                   name  145811   125959 271770   1 215     0    67096
                 nct_id       0   271770 271770  11  11     0   271770
           organization  244476    27294 271770   1 206     0    11605
 responsible_party_type   27499   244271 271770   7  22     0        3
                  title  173207    98563 271770   1 254     0    29420

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n  mean       sd    p0       p25   p50
       id       0   271770 271770 1e+06 78566.09 9e+05 966934.25 1e+06
        p75    p100     hist
 1102967.75 1170938 ▇▇▇▇▇▇▇▇

browse_interventions table exists

# A tibble: 6 x 4
       id nct_id      mesh_term                 downcase_mesh_term        
    <int> <chr>       <chr>                     <chr>                     
1 1305521 NCT03760848 Midazolam                 midazolam                 
2 1306168 NCT02493764 MK-7655                   mk-7655                   
3 1306293 NCT00736255 Lisdexamfetamine Dimesyl… lisdexamfetamine dimesyla…
4 1306294 NCT00736255 Dextroamphetamine         dextroamphetamine         
5 1306295 NCT00703326 Docetaxel                 docetaxel                 
6 1306296 NCT00703326 Ramucirumab               ramucirumab               
Skim summary statistics
 n obs: 300923 
 n variables: 4 

── Variable type:character ─────────────────────────────────────────────────────────────
           variable missing complete      n min max empty n_unique
 downcase_mesh_term       0   300923 300923   3 161     0     3165
          mesh_term       0   300923 300923   3 161     0     3165
             nct_id       0   300923 300923  11  11     0   129711

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n       mean       sd    p0       p25
       id       0   300923 300923 1155740.54 86989.29 1e+06 1080469.5
     p50       p75    p100     hist
 1155804 1231067.5 1306316 ▇▇▇▇▇▇▇▇

sponsors table exists

# A tibble: 6 x 5
       id nct_id    agency_class lead_or_collabora… name                  
    <int> <chr>     <chr>        <chr>              <chr>                 
1 1509569 NCT03759… Other        lead               Helsinki University C…
2 1509570 NCT03759… Other        collaborator       Helsinki University   
3 1509571 NCT03759… Other        lead               ClinAmygate           
4 1509572 NCT03759… Other        collaborator       National Research Cen…
5 1509573 NCT03759… Industry     lead               Allergan              
6 1509599 NCT03759… Other        lead               Children's Hospital L…
Skim summary statistics
 n obs: 460941 
 n variables: 5 

── Variable type:character ─────────────────────────────────────────────────────────────
             variable missing complete      n min max empty n_unique
         agency_class     803   460138 460941   3   8     0        4
 lead_or_collaborator       0   460941 460941   4  12     0        2
                 name       0   460941 460941   2 160     0    52924
               nct_id       0   460941 460941  11  11     0   291109

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n       mean        sd      p0     p25
       id       0   460941 460941 1740699.24 133223.74 1509569 1625387
     p50     p75  p100     hist
 1740779 1856063 2e+06 ▇▇▇▇▇▇▇▇

baseline_measurements table exists

# A tibble: 6 x 18
      id nct_id result_group_id ctgov_group_code classification category
   <int> <chr>            <int> <chr>            <chr>          <chr>   
1 2.69e6 NCT02…         2581308 B2               ""             ""      
2 2.69e6 NCT02…         2581309 B1               ""             ""      
3 2.69e6 NCT02…         2581307 B3               ""             Male    
4 2.69e6 NCT02…         2581308 B2               ""             Male    
5 2.69e6 NCT02…         2581309 B1               ""             Male    
6 2.69e6 NCT02…         2581307 B3               ""             Female  
# ... with 12 more variables: title <chr>, description <chr>, units <chr>,
#   param_type <chr>, param_value <chr>, param_value_num <dbl>,
#   dispersion_type <chr>, dispersion_value <chr>,
#   dispersion_value_num <dbl>, dispersion_lower_limit <dbl>,
#   dispersion_upper_limit <dbl>, explanation_of_na <chr>
Skim summary statistics
 n obs: 861552 
 n variables: 18 

── Variable type:character ─────────────────────────────────────────────────────────────
          variable missing complete      n min max  empty n_unique
          category       0   861552 861552   0  50 424672     4148
    classification       0   861552 861552   0  50 568644    24684
  ctgov_group_code       0   861552 861552   2   3      0       33
       description       0   861552 861552   0 600 765005    12954
   dispersion_type       0   861552 861552   0  20 720964        4
  dispersion_value  739250   122302 861552   1  15      0    12910
 explanation_of_na       0   861552 861552   0 246 858837      472
            nct_id       0   861552 861552  11  11      0    33646
        param_type       0   861552 861552   0  28    109       10
       param_value       0   861552 861552   1  11      0    21134
             title       0   861552 861552   2 100      0    19684
             units       0   861552 861552   0  40    134     2797

── Variable type:integer ───────────────────────────────────────────────────────────────
        variable missing complete      n       mean        sd      p0
              id       0   861552 861552 3107962.86 248923.72 2676483
 result_group_id       0   861552 861552   3e+06    244409.52 2573730
        p25       p50        p75    p100     hist
 2892446.75 3107978.5 3323605.25 3539012 ▇▇▇▇▇▇▇▇
 2764300      3e+06   3194335    3403195 ▇▇▇▇▇▇▇▇

── Variable type:numeric ───────────────────────────────────────────────────────────────
               variable missing complete      n    mean        sd    p0
 dispersion_lower_limit  841548    20004 861552  150.68   4078.77 -36.7
 dispersion_upper_limit  841556    19996 861552 6133.81 251714.66 -10.1
   dispersion_value_num  740103   121449 861552  196.73  21697.3    0  
        param_value_num    2590   858962 861552  209.48   9945.79 -58  
   p25   p50   p75       p100     hist
  8    24.6  43     272000    ▇▁▁▁▁▁▁▁
 27.18 66.6  82      3e+07    ▇▁▁▁▁▁▁▁
  4.4   9.05 12.31 3395777.02 ▇▁▁▁▁▁▁▁
  2    14    52    2510890    ▇▁▁▁▁▁▁▁

drop_withdrawals table exists

# A tibble: 6 x 7
      id nct_id  result_group_id ctgov_group_code period  reason     count
   <int> <chr>             <int> <chr>            <chr>   <chr>      <int>
1 796856 NCT036…         2573731 P1               Overal… Protocol …     1
2 796857 NCT036…         2573739 P1               Overal… Study was…    95
3 796858 NCT035…         2573807 P2               Overal… Lost to F…    29
4 796859 NCT035…         2573808 P1               Overal… Lost to F…    26
5 796860 NCT035…         2573820 P2               Analyz… Protocol …     1
6 796861 NCT035…         2573821 P1               Analyz… Protocol …     4
Skim summary statistics
 n obs: 253780 
 n variables: 7 

── Variable type:character ─────────────────────────────────────────────────────────────
         variable missing complete      n min max empty n_unique
 ctgov_group_code       0   253780 253780   2   3     0       26
           nct_id       0   253780 253780  11  11     0    21445
           period       0   253780 253780   4  40     0     4634
           reason       0   253780 253780   2  40     0    15691

── Variable type:integer ───────────────────────────────────────────────────────────────
        variable missing complete      n      mean        sd      p0
           count       0   253780 253780     57.11  23150.49       0
              id       0   253780 253780 923857.75  73289.23   8e+05
 result_group_id       0   253780 253780  3e+06    236119.75 2573731
        p25      p50        p75          p100     hist
       0         1         4          1.2e+07 ▇▁▁▁▁▁▁▁
  860391.75 923870.5  987329.25 1050783       ▇▇▇▇▇▇▇▇
 2838488     3e+06   3245607.25 3403198       ▃▅▆▆▆▆▇▇

outcome_measurements table exists

# A tibble: 6 x 19
      id nct_id outcome_id result_group_id ctgov_group_code classification
   <int> <chr>       <int>           <int> <chr>            <chr>         
1 5.76e6 NCT02…     780984         2579432 O1               Pancreatic: 6…
2 5.76e6 NCT02…     780984         2579432 O1               Pancreatic: 3…
3 5.76e6 NCT02…     780984         2579432 O1               Pancreatic: 2…
4 5.76e6 NCT02…     780984         2579432 O1               Pancreatic: 1…
5 5.76e6 NCT02…     780984         2579432 O1               Pancreatic: <…
6 5.76e6 NCT02…     780984         2579432 O1               Corpus Uteri:…
# ... with 13 more variables: category <chr>, title <chr>,
#   description <chr>, units <chr>, param_type <chr>, param_value <chr>,
#   param_value_num <dbl>, dispersion_type <chr>, dispersion_value <chr>,
#   dispersion_value_num <dbl>, dispersion_lower_limit <dbl>,
#   dispersion_upper_limit <dbl>, explanation_of_na <chr>
Skim summary statistics
 n obs: 1833056 
 n variables: 19 

── Variable type:character ─────────────────────────────────────────────────────────────
          variable missing complete       n min max   empty n_unique
          category     247  1832809 1833056   0  50 1788917     2819
    classification       0  1833056 1833056   0  50  347087   354392
  ctgov_group_code     247  1832809 1833056   2   3       0       39
       description       0  1833056 1833056   0 999  109204   173567
   dispersion_type       0  1833056 1833056   0  34  877734       23
  dispersion_value 1141775   691281 1833056   1  14       0    93468
 explanation_of_na     247  1832809 1833056   0 250 1798381     5032
            nct_id       0  1833056 1833056  11  11       0    32579
        param_type       0  1833056 1833056   0  28     457       10
       param_value     247  1832809 1833056   1  14       0   106055
             title       0  1833056 1833056   2 255       0   192189
             units       0  1833056 1833056   0  40     538    20921

── Variable type:integer ───────────────────────────────────────────────────────────────
        variable missing complete       n       mean        sd      p0
              id       0  1833056 1833056 6662721.85 529396.53 5745517
      outcome_id       0  1833056 1833056  905153.75  72217.86  779326
 result_group_id     247  1832809 1833056   3e+06    239135.56 2573732
        p25       p50        p75    p100     hist
 6204216.75 6662755.5 7121248.25 7579568 ▇▇▇▇▇▇▇▇
  843334     906884    968980.25   1e+06 ▇▇▇▇▇▆▇▇
 2787936      3e+06   3205628    3403240 ▇▇▇▇▇▆▇▇

── Variable type:numeric ───────────────────────────────────────────────────────────────
               variable missing complete       n        mean          sd
 dispersion_lower_limit 1549738   283318 1833056 1e+05           2.4e+07
 dispersion_upper_limit 1550344   282712 1833056     1.1e+09     3.3e+11
   dispersion_value_num 1161568   671488 1833056 55685.43        1.7e+07
        param_value_num   22919  1810137 1833056 16464.58    1e+07      
             p0  p25   p50   p75        p100     hist
 -3724434       0.18  4.2  44.4  6e+09       ▇▁▁▁▁▁▁▁
  -172230.54    2.5  19.82 89        1.3e+14 ▇▁▁▁▁▁▁▁
   -10966.01    0.75  3.66 17.25     1.3e+10 ▇▁▁▁▁▁▁▁
       -4.1e+08 0     4    31.6      6.4e+09 ▇▁▁▁▁▁▁▁

eligibilities table exists

# A tibble: 6 x 11
      id nct_id sampling_method gender minimum_age maximum_age
   <int> <chr>  <chr>           <chr>  <chr>       <chr>      
1 970321 NCT03… Probability Sa… All    3 Years     N/A        
2 970322 NCT03… ""              All    18 Years    N/A        
3 970323 NCT03… ""              All    30 Years    N/A        
4 970324 NCT03… Non-Probabilit… Female 18 Years    45 Years   
5 970325 NCT03… ""              All    21 Years    65 Years   
6 970328 NCT03… ""              All    45 Years    85 Years   
# ... with 5 more variables: healthy_volunteers <chr>, population <chr>,
#   criteria <chr>, gender_description <chr>, gender_based <lgl>
Skim summary statistics
 n obs: 291109 
 n variables: 11 

── Variable type:character ─────────────────────────────────────────────────────────────
           variable missing complete      n min   max  empty n_unique
           criteria       0   291109 291109   0 18929    884   286809
             gender       0   291109 291109   0     6    820        4
 gender_description       0   291109 291109   0   918 289108     1601
 healthy_volunteers       0   291109 291109   0    26   4431        3
        maximum_age       0   291109 291109   0    11    820      432
        minimum_age       0   291109 291109   0    10    820      235
             nct_id       0   291109 291109  11    11      0   291109
         population       0   291109 291109   0  1160 236973    51634
    sampling_method       0   291109 291109   0    22 236936        3

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n       mean       sd     p0   p25     p50
       id       0   291109 291109 1106531.22 84146.93 960515 1e+06 1106584
     p75    p100     hist
 1179399 1252199 ▇▇▇▇▇▇▇▇

── Variable type:logical ───────────────────────────────────────────────────────────────
     variable missing complete      n mean                 count
 gender_based  288081     3028 291109    1 NA: 288081, TRU: 3028

facility_contacts table exists

# A tibble: 6 x 7
       id nct_id   facility_id contact_type name      email       phone   
    <int> <chr>          <int> <chr>        <chr>     <chr>       <chr>   
1 1763580 NCT0375…     8765741 primary      Marja Mä… marja.maki… +358407…
2 1763581 NCT0375…     8765742 primary      Emad Hab… emangate@g… <NA>    
3 1764118 NCT0375…     8766495 primary      <NA>      <NA>        3225413…
4 1763583 NCT0375…     8765745 primary      Christia… christian.… +49 30 …
5 1763584 NCT0375…     8765745 backup       Judith B… judith.bel… <NA>    
6 1763585 NCT0375…     8765747 primary      Paul R K… paul.king2… 716-862…
Skim summary statistics
 n obs: 256021 
 n variables: 7 

── Variable type:character ─────────────────────────────────────────────────────────────
     variable missing complete      n min max empty n_unique
 contact_type       0   256021 256021   6   7     0        2
        email   78025   177996 256021   8  85     0   103828
         name    6924   249097 256021   1 108     0   150169
       nct_id       0   256021 256021  11  11     0    64764
        phone   68657   187364 256021   1  37     0    99557

── Variable type:integer ───────────────────────────────────────────────────────────────
    variable missing complete      n       mean        sd      p0     p25
 facility_id       0   256021 256021 9202167.95 440390.9  8765741 8894609
          id       0   256021 256021 1893278.25  74560.56 1763580 1828846
     p50     p75        p100     hist
 9059260 9356016     1.1e+07 ▇▅▂▁▁▁▁▁
 1893380   2e+06 2e+06       ▇▇▇▇▇▇▇▇

overall_officials table exists

# A tibble: 6 x 5
      id nct_id    role          name          affiliation                
   <int> <chr>     <chr>         <chr>         <chr>                      
1 992735 NCT03759… Study Direct… Aparna Sahoo… Allergan                   
2 992737 NCT03759… Principal In… Sonata Jodel… Children's Hospital Los An…
3 992738 NCT03759… Principal In… Anna-Barbara… University of California, …
4 992739 NCT03759… Principal In… Paul R. King… VA Western New York Health…
5 992740 NCT03759… Study Chair   Robert Greif… University Hospital Bern, …
6 992741 NCT03759… Principal In… Sabine Nabec… University Hospital Bern, …
Skim summary statistics
 n obs: 302359 
 n variables: 5 

── Variable type:character ─────────────────────────────────────────────────────────────
    variable missing complete      n min max empty n_unique
 affiliation    2411   299948 302359   1 255     0    81680
        name       0   302359 302359   1 121     0   196777
      nct_id       0   302359 302359  11  11     0   236426
        role    1428   300931 302359  11  22     0        4

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n      mean       sd     p0       p25
       id       0   302359 302359 1144355.2 87383.99 992735 1068728.5
     p50       p75    p100     hist
 1144405 1220026.5 1295639 ▇▇▇▇▇▇▇▇

facility_investigators table exists

# A tibble: 6 x 5
       id nct_id     facility_id role               name                  
    <int> <chr>            <int> <chr>              <chr>                 
1 1358669 NCT037593…     8765741 Principal Investi… Marja Mäkinen, PhD    
2 1358670 NCT037593…     8765741 Sub-Investigator   Heini Harve-Rytsälä, …
3 1358671 NCT037593…     8765741 Sub-Investigator   Jussi Pirneskoski, MD…
4 1358672 NCT037593…     8765741 Principal Investi… Maaret Castrén, MD, P…
5 1358673 NCT037592…     8765747 Principal Investi… Paul R. King, PhD     
6 1358674 NCT037590…     8765759 Principal Investi… Wee Joo Chng, Prof    
Skim summary statistics
 n obs: 182374 
 n variables: 5 

── Variable type:character ─────────────────────────────────────────────────────────────
 variable missing complete      n min max empty n_unique
     name       0   182374 182374   2  75     0   115139
   nct_id       0   182374 182374  11  11     0    33741
     role       0   182374 182374  11  22     0        3

── Variable type:integer ───────────────────────────────────────────────────────────────
    variable missing complete      n       mean        sd      p0
 facility_id       0   182374 182374 9271421.89 439934.15 8765741
          id       0   182374 182374 1450406.39  52986.29 1358669
        p25       p50        p75          p100     hist
 8929517.25 9151862.5 9487465.75       1.1e+07 ▇▆▃▂▁▁▁▁
 1404529.25 1450261.5 1496466.75 1542072       ▇▇▇▇▇▇▇▇

facilities table exists

# A tibble: 6 x 8
       id nct_id   status     name           city   state   zip   country 
    <int> <chr>    <chr>      <chr>          <chr>  <chr>   <chr> <chr>   
1 8775697 NCT0369… ""         University of… Ottawa Ontario K1Y … Canada  
2 8775698 NCT0369… Recruiting Vanderbilt Un… Nashv… Tennes… 37212 United …
3 8775699 NCT0369… Not yet r… Bordeaux Univ… Borde… ""      33076 France  
4 8775705 NCT0369… Not yet r… St. Paul's Ho… Vanco… Britis… V6Z … Canada  
5 8775706 NCT0369… Recruiting Institut Gutt… Badal… Barcel… 08916 Spain   
6 8775707 NCT0369… ""         IU Health Met… India… Indiana 46202 United …
Skim summary statistics
 n obs: 2076731 
 n variables: 8 

── Variable type:character ─────────────────────────────────────────────────────────────
 variable missing complete       n min max   empty n_unique
     city       0  2076731 2076731   0  63     106    58955
  country       0  2076731 2076731   0  42     106      207
     name  223042  1853689 2076731   1 255       0   453172
   nct_id       0  2076731 2076731  11  11       0   256385
    state       0  2076731 2076731   0  62  835151    10598
   status       0  2076731 2076731   0  23 1686709        9
      zip       0  2076731 2076731   0  30  463940    72031

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete       n       mean    sd      p0       p25
       id       0  2076731 2076731 9816935.45 6e+05 8765741 9295607.5
     p50   p75    p100     hist
 9818970 1e+07 1.1e+07 ▇▇▇▇▇▇▇▇

outcomes table exists

# A tibble: 6 x 13
      id nct_id outcome_type title description time_frame population
   <int> <chr>  <chr>        <chr> <chr>       <chr>      <chr>     
1 789149 NCT02… Secondary    Perc… The percen… 22 Days    Safety An…
2 789150 NCT02… Secondary    Perc… Adverse ev… 22 days    Safety An…
3 789151 NCT02… Secondary    Perc… Participan… 22 Days    Safety An…
4 789152 NCT02… Secondary    Geom… Geometric … Baseline … FAS inclu…
5 789153 NCT02… Secondary    Sero… Seroprotec… Days 1 an… FAS inclu…
6 789154 NCT02… Secondary    GMT … GMT of SRH… Days 1 an… FAS inclu…
# ... with 6 more variables: anticipated_posting_date <date>,
#   anticipated_posting_month_year <chr>, units <chr>,
#   units_analyzed <chr>, dispersion_type <chr>, param_type <chr>
Skim summary statistics
 n obs: 250721 
 n variables: 13 

── Variable type:character ─────────────────────────────────────────────────────────────
                       variable missing complete      n min max  empty
 anticipated_posting_month_year       0   250721 250721   0   7 249639
                    description       0   250721 250721   0 999  26975
                dispersion_type       0   250721 250721   0  34 100581
                         nct_id       0   250721 250721  11  11      0
                   outcome_type       0   250721 250721   7  19      0
                     param_type       0   250721 250721   0  28  17112
                     population       0   250721 250721   0 350  54994
                     time_frame       0   250721 250721   0 255     71
                          title       0   250721 250721   2 255      0
                          units       0   250721 250721   0  40  17141
                 units_analyzed       0   250721 250721   0  40 246276
 n_unique
      122
   183270
       23
    33755
        4
       10
    77388
    73608
   206294
    20995
      516

── Variable type:Date ──────────────────────────────────────────────────────────────────
                 variable missing complete      n        min        max
 anticipated_posting_date  249642     1079 250721 2007-04-30 3333-12-31
     median n_unique
 2018-12-31      119

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n  mean      sd     p0    p25   p50    p75
       id       0   250721 250721 9e+05 72418.3 779326 842094 9e+05 967531
  p100     hist
 1e+06 ▇▇▇▇▇▇▇▇

result_agreements table exists

# A tibble: 6 x 4
      id nct_id   pi_employee                  agreement                  
   <int> <chr>    <chr>                        <chr>                      
1 104003 NCT0367… All Principal Investigators… There is NOT an agreement …
2 104004 NCT0365… All Principal Investigators… There is NOT an agreement …
3 104005 NCT0364… All Principal Investigators… There is NOT an agreement …
4 104006 NCT0364… Principal Investigators are… There is NOT an agreement …
5 104007 NCT0361… Principal Investigators are… There is NOT an agreement …
6 104008 NCT0358… Principal Investigators are… There is NOT an agreement …
Skim summary statistics
 n obs: 33755 
 n variables: 4 

── Variable type:character ─────────────────────────────────────────────────────────────
    variable missing complete     n min max empty n_unique
   agreement     734    33021 33755  15 500     0     2828
      nct_id       0    33755 33755  11  11     0    33755
 pi_employee       0    33755 33755  82  82     0        2

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete     n      mean      sd    p0      p25    p50
       id       0    33755 33755 120896.22 9749.71 1e+05 112453.5 120896
      p75   p100     hist
 129340.5 137781 ▇▇▇▇▇▇▇▇

result_contacts table exists

# A tibble: 6 x 6
      id nct_id   organization            name      phone     email       
   <int> <chr>    <chr>                   <chr>     <chr>     <chr>       
1 104003 NCT0367… Auerbach Hematology an… Michael … 41078040… mauerbachmd…
2 104004 NCT0365… Medical University of … Dr. Gonz… 843-792-… revuelta@mu…
3 104005 NCT0364… Montefiore Medical Cen… Lisa Wie… <NA>      lwiechma@mo…
4 104006 NCT0364… National University Ho… Dr. Davi… +6594550… david_chen@…
5 104007 NCT0361… Al-Kindy College of Me… Lewai Sh… 750 659 … lewaisharki…
6 104008 NCT0358… Medical University of … Dr. Ange… 843-762-… dempsear@mu…
Skim summary statistics
 n obs: 33755 
 n variables: 6 

── Variable type:character ─────────────────────────────────────────────────────────────
     variable missing complete     n min max empty n_unique
        email    4718    29037 33755   9  78     0    14048
         name       0    33755 33755   1 100     0    16889
       nct_id       0    33755 33755  11  11     0    33755
 organization       3    33752 33755   2 213     0     8148
        phone    3289    30466 33755   3  43     0    14764

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete     n      mean      sd    p0      p25    p50
       id       0    33755 33755 120896.22 9749.71 1e+05 112453.5 120896
      p75   p100     hist
 129340.5 137781 ▇▇▇▇▇▇▇▇

result_groups table exists

# A tibble: 6 x 6
       id nct_id  ctgov_group_code result_type title  description         
    <int> <chr>   <chr>            <chr>       <chr>  <chr>               
1 2583691 NCT028… O1               Outcome     Faste… The subjects receiv…
2 2583692 NCT028… O2               Outcome     NovoR… The subjects receiv…
3 2583693 NCT028… O1               Outcome     Faste… The subjects receiv…
4 2583694 NCT028… O2               Outcome     NovoR… The subjects receiv…
5 2583695 NCT028… O1               Outcome     Faste… The subjects receiv…
6 2583696 NCT028… O2               Outcome     NovoR… The subjects receiv…
Skim summary statistics
 n obs: 828859 
 n variables: 6 

── Variable type:character ─────────────────────────────────────────────────────────────
         variable missing complete      n min max empty n_unique
 ctgov_group_code       0   828859 828859   2   3     0      136
      description       0   828859 828859   0 999 17177   137187
           nct_id       0   828859 828859  11  11     0    33755
      result_type       0   828859 828859   7  16     0        4
            title       0   828859 828859   0  62    13    93924

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n  mean        sd      p0       p25   p50
       id       0   828859 828859 3e+06 239407.75 2573730 2781265.5 3e+06
       p75    p100     hist
 3195967.5 3403243 ▇▇▇▇▇▇▇▇

ipd_information_types table exists

# A tibble: 6 x 3
     id nct_id      name                           
  <int> <chr>       <chr>                          
1 24848 NCT03758183 Study Protocol                 
2 24849 NCT03758183 Statistical Analysis Plan (SAP)
3 24850 NCT03758183 Informed Consent Form (ICF)    
4 24851 NCT03758183 Clinical Study Report (CSR)    
5 24852 NCT03758183 Analytic Code                  
6 24858 NCT03757741 Study Protocol                 
Skim summary statistics
 n obs: 6440 
 n variables: 3 

── Variable type:character ─────────────────────────────────────────────────────────────
 variable missing complete    n min max empty n_unique
     name       0     6440 6440  13  31     0        5
   nct_id       0     6440 6440  11  11     0     2138

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete    n     mean      sd    p0      p25     p50
       id       0     6440 6440 28088.37 1871.42 24848 26467.75 28083.5
      p75  p100     hist
 29712.25 31335 ▇▇▇▇▇▇▇▇

conditions table exists

# A tibble: 6 x 4
       id nct_id    name                      downcase_name               
    <int> <chr>     <chr>                     <chr>                       
1 2099444 NCT03599… Fall                      fall                        
2 2099565 NCT03481… Obesity                   obesity                     
3 2100024 NCT02390… Sarcoma                   sarcoma                     
4 2100251 NCT00159… Chronic Obstructive Pulm… chronic obstructive pulmona…
5 2100252 NCT00102… HIV Infections            hiv infections              
6 2100253 NCT00073… Thrombocytopenia          thrombocytopenia            
Skim summary statistics
 n obs: 476863 
 n variables: 4 

── Variable type:character ─────────────────────────────────────────────────────────────
      variable missing complete      n min max empty n_unique
 downcase_name       0   476863 476863   2 160     0    73239
          name       0   476863 476863   2 160     0    74418
        nct_id       0   476863 476863  11  11     0   290295

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n       mean        sd      p0       p25
       id       0   476863 476863 1861594.98 137887.95 1622304 1742231.5
     p50   p75    p100     hist
 1861717 2e+06 2100271 ▇▇▇▇▇▇▇▇

countries table exists

# A tibble: 6 x 4
       id nct_id      name          removed
    <int> <chr>       <chr>         <lgl>  
1 1505961 NCT03759314 Finland       NA     
2 1505962 NCT03759301 Egypt         NA     
3 1505963 NCT03759288 United States NA     
4 1505965 NCT03759249 Germany       NA     
5 1505966 NCT03759236 United States NA     
6 1505967 NCT03759223 United States NA     
Skim summary statistics
 n obs: 421815 
 n variables: 4 

── Variable type:character ─────────────────────────────────────────────────────────────
 variable missing complete      n min max empty n_unique
     name       0   421815 421815   4  44     0      213
   nct_id       0   421815 421815  11  11     0   261340

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n       mean        sd      p0       p25
       id       0   421815 421815 1718378.21 122155.86 1505961 1612709.5
     p50       p75    p100     hist
 1718593 1824133.5 1929634 ▇▇▇▇▇▇▇▇

── Variable type:logical ───────────────────────────────────────────────────────────────
 variable missing complete      n mean                  count
  removed  394707    27108 421815    1 NA: 394707, TRU: 27108

design_group_interventions table exists

# A tibble: 6 x 4
       id nct_id      design_group_id intervention_id
    <int> <chr>                 <int>           <int>
1 2122687 NCT03759301         1674041         1680364
2 2122688 NCT03759301         1674042         1680365
3 2122689 NCT03759288         1674044         1680366
4 2122690 NCT03759288         1674048         1680366
5 2122691 NCT03759288         1674043         1680367
6 2122692 NCT03759288         1674047         1680367
Skim summary statistics
 n obs: 624057 
 n variables: 4 

── Variable type:character ─────────────────────────────────────────────────────────────
 variable missing complete      n min max empty n_unique
   nct_id       0   624057 624057  11  11     0   227757

── Variable type:integer ───────────────────────────────────────────────────────────────
        variable missing complete      n       mean        sd      p0
 design_group_id       0   624057 624057 1928546.94 147941.72 1674041
              id       0   624057 624057 2436212.93 180554.16 2122687
 intervention_id       0   624057 624057 1912969.3  137883    1680364
     p25     p50     p75    p100     hist
 1801507 1923609 2058397 2179914 ▇▇▇▇▇▆▇▇
 2279884 2436455 2592561 2748642 ▇▇▇▇▇▇▇▇
 1795227 1907406   2e+06 2187099 ▇▇▇▇▇▇▆▅

documents table exists

# A tibble: 6 x 6
     id nct_id   document_id document_type        url              comment
  <int> <chr>    <chr>       <chr>                <chr>            <chr>  
1 30686 NCT0375… <NA>        Individual Particip… https://clinica… <NA>   
2 30687 NCT0375… <NA>        Study Protocol       https://clinica… <NA>   
3 30688 NCT0375… <NA>        Statistical Analysi… https://clinica… <NA>   
4 30689 NCT0375… <NA>        Informed Consent Fo… https://clinica… <NA>   
5 30690 NCT0375… <NA>        Clinical Study Repo… https://clinica… <NA>   
6 30691 NCT0375… <NA>        Study-level clinica… https://clinica… <NA>   
Skim summary statistics
 n obs: 9869 
 n variables: 6 

── Variable type:character ─────────────────────────────────────────────────────────────
      variable missing complete    n min max empty n_unique
       comment    1013     8856 9869   8 942     0      475
   document_id    1128     8741 9869   1  30     0     1604
 document_type       0     9869 9869   4 177     0      244
        nct_id       0     9869 9869  11  11     0     2343
           url       0     9869 9869  13 885     0     1025

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete    n  mean      sd    p0   p25   p50   p75
       id       0     9869 9869 35620 2849.08 30686 33153 35620 38087
  p100     hist
 40554 ▇▇▇▇▇▇▇▇

id_information table exists

# A tibble: 6 x 4
       id nct_id      id_type      id_value      
    <int> <chr>       <chr>        <chr>         
1 1368139 NCT03759314 org_study_id §50, 27.3.2018
2 1368140 NCT03759301 org_study_id NRC 0214      
3 1368141 NCT03759288 org_study_id 3150-301-008  
4 1368143 NCT03759262 org_study_id CHLA-18-00362 
5 1368144 NCT03759249 org_study_id SLEEPFAMS     
6 1368145 NCT03759236 org_study_id 48789         
Skim summary statistics
 n obs: 402884 
 n variables: 4 

── Variable type:character ─────────────────────────────────────────────────────────────
 variable missing complete      n min max empty n_unique
  id_type       0   402884 402884   9  12     0        3
 id_value       0   402884 402884   1  30     0   375140
   nct_id       0   402884 402884  11  11     0   291081

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n       mean     sd      p0        p25
       id       0   402884 402884 1570360.15 116484 1368139 1469550.75
       p50        p75    p100     hist
 1570435.5 1671236.25 1771995 ▇▇▇▇▇▇▇▇

participant_flows table exists

# A tibble: 6 x 4
      id nct_id   recruitment_details          pre_assignment_details     
   <int> <chr>    <chr>                        <chr>                      
1 104003 NCT0367… ""                           ""                         
2 104004 NCT0365… ""                           ""                         
3 104005 NCT0364… ""                           ""                         
4 104006 NCT0364… ""                           ""                         
5 104007 NCT0361… Obese females (BMI≥30 kg/m2… Out of the 161 obese femal…
6 104008 NCT0358… ""                           ""                         
Skim summary statistics
 n obs: 33755 
 n variables: 4 

── Variable type:character ─────────────────────────────────────────────────────────────
               variable missing complete     n min max empty n_unique
                 nct_id       0    33755 33755  11  11     0    33755
 pre_assignment_details       0    33755 33755   0 350 20504    12885
    recruitment_details       0    33755 33755   0 350 18642    14921

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete     n      mean      sd    p0      p25    p50
       id       0    33755 33755 120896.22 9749.71 1e+05 112453.5 120896
      p75   p100     hist
 129340.5 137781 ▇▇▇▇▇▇▇▇

baseline_counts table exists

# A tibble: 6 x 7
      id nct_id    result_group_id ctgov_group_code units     scope  count
   <int> <chr>               <int> <chr>            <chr>     <chr>  <int>
1 292404 NCT03670…         2573730 B1               Particip… Overa…   101
2 292405 NCT03651…         2573734 B1               Particip… Overa…    10
3 292406 NCT03648…         2573738 B1               Particip… Overa…     0
4 292407 NCT03647…         2573744 B3               Particip… Overa…    32
5 292408 NCT03647…         2573745 B2               Particip… Overa…    16
6 292409 NCT03647…         2573746 B1               Particip… Overa…    16
Skim summary statistics
 n obs: 94570 
 n variables: 7 

── Variable type:character ─────────────────────────────────────────────────────────────
         variable missing complete     n min max empty n_unique
 ctgov_group_code       0    94570 94570   2   3     0       33
           nct_id       0    94570 94570  11  11     0    33755
            scope       0    94570 94570   7   7     0        1
            units       0    94570 94570   4  28     0       43

── Variable type:integer ───────────────────────────────────────────────────────────────
        variable missing complete     n      mean        sd      p0
           count       0    94570 94570    472.68  16606.95       0
              id       0    94570 94570 339739.26  27316.07  292404
 result_group_id       0    94570 94570  3e+06    240389.76 2573730
        p25      p50        p75    p100     hist
      17        48       140    2738161 ▇▁▁▁▁▁▁▁
  316083.25 339740.5  363398.75  387046 ▇▇▇▇▇▇▇▇
 2781143.25  3e+06   3198427.75 3403195 ▇▇▇▇▇▇▇▇

intervention_other_names table exists

# A tibble: 6 x 4
      id nct_id      intervention_id name      
   <int> <chr>                 <int> <chr>     
1 979099 NCT03759301         1680364 Cetrorelix
2 979100 NCT03759301         1680365 Cetrorelix
3 979101 NCT03759262         1680371 vitamin D 
4 979102 NCT03759223         1680375 E-PST     
5 979103 NCT03759223         1680376 Control   
6 979104 NCT03759119         1680387 Group 1   
Skim summary statistics
 n obs: 253580 
 n variables: 4 

── Variable type:character ─────────────────────────────────────────────────────────────
 variable missing complete      n min max empty n_unique
     name       0   253580 253580   1 200     0    94594
   nct_id       0   253580 253580  11  11     0    89249

── Variable type:integer ───────────────────────────────────────────────────────────────
        variable missing complete      n       mean        sd      p0
              id       0   253580 253580 1106323.21  73327.24  979099
 intervention_id       0   253580 253580 1940544.28 137571.75 1680364
        p25       p50        p75    p100     hist
   1e+06    1106370.5 1169830.25 1233264 ▇▇▇▇▇▇▇▇
 1830100.75 1944608   2053925.75 2187100 ▆▆▇▇▇▇▇▆

pending_results table exists

# A tibble: 6 x 5
     id nct_id      event     event_date_description event_date
  <int> <chr>       <chr>     <chr>                  <date>    
1 67750 NCT03758118 submitted November 28, 2018      2018-11-28
2 67751 NCT03745183 submitted November 28, 2018      2018-11-28
3 67752 NCT03738020 submitted November 27, 2018      2018-11-27
4 67753 NCT03738007 submitted November 27, 2018      2018-11-27
5 67754 NCT03725085 submitted November 19, 2018      2018-11-19
6 67755 NCT03723980 submitted November 4, 2018       2018-11-04
Skim summary statistics
 n obs: 22760 
 n variables: 5 

── Variable type:character ─────────────────────────────────────────────────────────────
               variable missing complete     n min max empty n_unique
                  event       0    22760 22760   8  19     0        3
 event_date_description       0    22760 22760   7  18     0     2767
                 nct_id       0    22760 22760  11  11     0     6810

── Variable type:Date ──────────────────────────────────────────────────────────────────
   variable missing complete     n        min        max     median
 event_date     797    21963 22760 2008-11-20 2018-11-29 2017-08-22
 n_unique
     2766

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete     n    mean      sd    p0      p25     p50
       id       0    22760 22760 79129.5 6570.39 67750 73439.75 79129.5
      p75  p100     hist
 84819.25 90509 ▇▇▇▇▇▇▇▇

brief_summaries table exists

# A tibble: 6 x 3
      id nct_id     description                                           
   <int> <chr>      <chr>                                                 
1 977582 NCT035012… "\n      Participants will be chosen through an initi…
2 977583 NCT035012… "\n      The aim of this study was to evaluate the ef…
3 977584 NCT035012… "\n      This study evaluate topical anaesthesia appl…
4 977585 NCT035011… "\n      The investigators will use two types of mate…
5 977586 NCT035011… "\n      Gait training in stroke is a complex process…
6 977587 NCT035011… "\n      The purpose of this study is to document the…
Skim summary statistics
 n obs: 290305 
 n variables: 3 

── Variable type:character ─────────────────────────────────────────────────────────────
    variable missing complete      n min  max empty n_unique
 description       0   290305 290305  15 5540     0   288709
      nct_id       0   290305 290305  11   11     0   290305

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n       mean       sd     p0   p25     p50
       id       0   290305 290305 1103450.49 83914.53 957837 1e+06 1103503
     p75    p100     hist
 1176117 1248716 ▇▇▇▇▇▇▇▇

interventions table exists

# A tibble: 6 x 5
       id nct_id  intervention_ty… name            description            
    <int> <chr>   <chr>            <chr>           <chr>                  
1 1683415 NCT037… Drug             Placebos        Placebo                
2 1726400 NCT034… Drug             Placebo         Placebo QD             
3 1680559 NCT037… Drug             TAB PIOGLITAZO… INSULIN SENSITIZING AG…
4 1680452 NCT037… Device           High-Intensity… The High-Intensity Foc…
5 1680453 NCT037… Drug             Apatinib        30 patients who progre…
6 1680703 NCT037… Drug             Pomalidomide    Given PO               
Skim summary statistics
 n obs: 505557 
 n variables: 5 

── Variable type:character ─────────────────────────────────────────────────────────────
          variable missing complete      n min  max empty n_unique
       description   91615   413942 505557   1 1000     0   353593
 intervention_type       0   505557 505557   4   19     0       11
              name       0   505557 505557   1  200     0   250010
            nct_id       0   505557 505557  11   11     0   258753

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n       mean        sd      p0     p25
       id       0   505557 505557 1934093.63 146176.97 1680363 1807541
     p50     p75    p100     hist
 1934220 2060678 2187100 ▇▇▇▇▇▇▇▇

reported_events table exists

# A tibble: 6 x 17
      id nct_id result_group_id ctgov_group_code time_frame event_type
   <int> <chr>            <int> <chr>            <chr>      <chr>     
1 1.34e7 NCT02…         2582826 E7               Non-serio… serious   
2 1.34e7 NCT02…         2582827 E6               Non-serio… serious   
3 1.34e7 NCT02…         2582828 E5               Non-serio… serious   
4 1.34e7 NCT02…         2582829 E4               Non-serio… serious   
5 1.34e7 NCT02…         2582830 E3               Non-serio… serious   
6 1.34e7 NCT02…         2582831 E2               Non-serio… serious   
# ... with 11 more variables: default_vocab <chr>,
#   default_assessment <chr>, subjects_affected <int>,
#   subjects_at_risk <int>, description <chr>, event_count <int>,
#   organ_system <chr>, adverse_event_term <chr>,
#   frequency_threshold <int>, vocab <chr>, assessment <chr>
Skim summary statistics
 n obs: 4235622 
 n variables: 17 

── Variable type:character ─────────────────────────────────────────────────────────────
           variable missing complete       n min max   empty n_unique
 adverse_event_term      11  4235611 4235622   1 100       0   102702
         assessment       0  4235622 4235622   0  25 4198499        3
   ctgov_group_code       0  4235622 4235622   2   3       0       32
 default_assessment       0  4235622 4235622   0  25  301758        3
      default_vocab       0  4235622 4235622   0  20  489787     1390
        description       0  4235622 4235622   0 500 1868019    10056
         event_type       0  4235622 4235622   5   7       0        2
             nct_id       0  4235622 4235622  11  11       0    33538
       organ_system       0  4235622 4235622   5  67       0       28
         time_frame       0  4235622 4235622   0 500 1384606    14596
              vocab 4206829    28793 4235622   1  20       0      818

── Variable type:integer ───────────────────────────────────────────────────────────────
            variable missing complete       n          mean         sd
         event_count 2837591  1398031 4235622       5.14         56.8 
 frequency_threshold       0  4235622 4235622       1.49          2.23
                  id       0  4235622 4235622       1.5e+07 1223730.61
     result_group_id       0  4235622 4235622 3060722.14     235147.33
   subjects_affected       2  4235620 4235622       4.72         41.42
    subjects_at_risk    1614  4234008 4235622     526.75       1831.79
            p0           p25           p50           p75          p100
       0             0             1             2         22562      
       0             0             0             5            20      
       1.3e+07       1.4e+07       1.5e+07       1.7e+07       1.8e+07
 2573733       2864288       3081328       3272568       3403243      
       0             0             1             2          9360      
       0            19            66           244        124139      
     hist
 ▇▁▁▁▁▁▁▁
 ▇▃▁▁▁▁▁▁
 ▇▇▇▇▇▇▇▇
 ▂▃▅▅▅▅▆▇
 ▇▁▁▁▁▁▁▁
 ▇▁▁▁▁▁▁▁

browse_conditions table exists

# A tibble: 6 x 4
       id nct_id      mesh_term                 downcase_mesh_term       
    <int> <chr>       <chr>                     <chr>                    
1 1741860 NCT03742466 Carpal Tunnel Syndrome    carpal tunnel syndrome   
2 1741861 NCT03742466 Scleroderma, Systemic     scleroderma, systemic    
3 1741862 NCT03742466 Scleroderma, Diffuse      scleroderma, diffuse     
4 1741863 NCT03742466 Scleroderma, Localized    scleroderma, localized   
5 1741864 NCT03742453 Carcinoma                 carcinoma                
6 1741865 NCT03742453 Carcinoma, Hepatocellular carcinoma, hepatocellular
Skim summary statistics
 n obs: 516751 
 n variables: 4 

── Variable type:character ─────────────────────────────────────────────────────────────
           variable missing complete      n min max empty n_unique
 downcase_mesh_term       0   516751 516751   4  58     0     3886
          mesh_term       0   516751 516751   4  58     0     3886
             nct_id       0   516751 516751  11  11     0   235322

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n  mean        sd      p0       p25   p50
       id       0   516751 516751 2e+06 149398.16 1739679 1869632.5 2e+06
       p75    p100     hist
 2128332.5 2257562 ▇▇▇▇▇▇▇▇

keywords table exists

# A tibble: 6 x 4
       id nct_id      name              downcase_name    
    <int> <chr>       <chr>             <chr>            
1 3597072 NCT03394040 Diarrhea          diarrhea         
2 3597191 NCT03307317 EEG               eeg              
3 3597654 NCT02530658 DNA               dna              
4 3598070 NCT00067054 Leukocyte         leukocyte        
5 3598071 NCT00067054 Healthy Volunteer healthy volunteer
6 3598072 NCT00067054 HV                hv               
Skim summary statistics
 n obs: 828605 
 n variables: 4 

── Variable type:character ─────────────────────────────────────────────────────────────
      variable missing complete      n min max empty n_unique
 downcase_name       0   828605 828605   1 160     0   191262
          name       0   828605 828605   1 160     0   237797
        nct_id       0   828605 828605  11  11     0   195838

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n       mean        sd      p0   p25
       id       0   828605 828605 3183467.47 239491.58 2767839 3e+06
     p50     p75    p100     hist
 3183595 3390863 3598091 ▇▇▇▇▇▇▇▇

calculated_values table exists

# A tibble: 6 x 16
      id nct_id number_of_facil… number_of_nsae_… number_of_sae_s…
   <int> <chr>             <int>            <int>            <int>
1 2.01e7 NCT03…               NA               NA               NA
2 2.01e7 NCT03…                4               NA               NA
3 2.01e7 NCT03…                2               NA               NA
4 2.01e7 NCT03…               NA               NA               NA
5 2.01e7 NCT03…               NA               NA               NA
6 2.01e7 NCT03…               NA               NA               NA
# ... with 11 more variables: registered_in_calendar_year <int>,
#   nlm_download_date <date>, actual_duration <int>,
#   were_results_reported <lgl>, months_to_report_results <int>,
#   has_us_facility <lgl>, has_single_facility <lgl>,
#   minimum_age_num <int>, maximum_age_num <int>, minimum_age_unit <chr>,
#   maximum_age_unit <chr>
Skim summary statistics
 n obs: 291109 
 n variables: 16 

── Variable type:character ─────────────────────────────────────────────────────────────
         variable missing complete      n min max empty n_unique
 maximum_age_unit  139449   151660 291109   4   8     0       12
 minimum_age_unit   24676   266433 291109   5   7     0        6
           nct_id       0   291109 291109  11  11     0   291109

── Variable type:Date ──────────────────────────────────────────────────────────────────
          variable missing complete      n        min        max
 nlm_download_date       0   291109 291109 2018-11-30 2018-11-30
     median n_unique
 2018-11-30        1

── Variable type:integer ───────────────────────────────────────────────────────────────
                    variable missing complete      n     mean       sd
             actual_duration  125493   165616 291109    27.52    27.16
                          id       0   291109 291109 2e+07    84036.07
             maximum_age_num  139449   151660 291109    59.4     31.98
             minimum_age_num   24676   266433 291109    20.15    11.13
    months_to_report_results  257439    33670 291109    27.36    25.18
        number_of_facilities   34724   256385 291109     8.1     38.07
     number_of_nsae_subjects  257571    33538 291109   496.77  2014.3 
      number_of_sae_subjects  257571    33538 291109    99.66   868.91
 registered_in_calendar_year       0   291109 291109  2012.11     4.47
    p0   p25   p50      p75  p100     hist
     0     9    20    37      732 ▇▁▁▁▁▁▁▁
 2e+07 2e+07 2e+07 2e+07    2e+07 ▇▇▇▇▇▇▇▇
     1    45    65    75     6569 ▇▁▁▁▁▁▁▁
     1    18    18    18      730 ▇▁▁▁▁▁▁▁
  -200    11    18    36.75   287 ▁▁▁▇▂▁▁▁
     1     1     1     2     3511 ▇▁▁▁▁▁▁▁
     0     0    53   301    79635 ▇▁▁▁▁▁▁▁
     0     0     4    34    73542 ▇▁▁▁▁▁▁▁
  1999  2009  2013  2016     2018 ▁▁▂▃▃▆▅▇

── Variable type:logical ───────────────────────────────────────────────────────────────
              variable missing complete      n mean
   has_single_facility       0   291109 291109 0.61
       has_us_facility   34738   256371 291109 0.46
 were_results_reported       0   291109 291109 0.12
                               count
     TRU: 177308, FAL: 113801, NA: 0
 FAL: 139534, TRU: 116837, NA: 34738
      FAL: 257354, TRU: 33755, NA: 0

links table exists

# A tibble: 6 x 4
      id nct_id   url                        description                  
   <int> <chr>    <chr>                      <chr>                        
1 176241 NCT0375… https://doi.org/10.1161/C… GUSTO bleeding               
2 176242 NCT0375… http://moffitt.org/clinic… Moffitt Cancer Center Clinic…
3 176243 NCT0375… https://www.cma.ca/En/Lis… The State of Seniors Health …
4 176244 NCT0375… http://www.hpcintegration… What Canadians Say: The Way …
5 176245 NCT0375… https://tspace.library.ut… Episodes of Relationship Com…
6 176247 NCT0375… https://www.ncbi.nlm.nih.… Rationale and evidence for t…
Skim summary statistics
 n obs: 50716 
 n variables: 4 

── Variable type:character ─────────────────────────────────────────────────────────────
    variable missing complete     n min max empty n_unique
 description    4992    45724 50716   1 254     0    19285
      nct_id       0    50716 50716  11  11     0    37901
         url       0    50716 50716  12 853     0    25227

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete     n  mean       sd     p0       p25   p50
       id       0    50716 50716 2e+05 14666.74 176241 189043.75 2e+05
       p75   p100     hist
 214431.25 227120 ▇▇▇▇▇▇▇▇

central_contacts table exists

# A tibble: 6 x 6
      id nct_id    contact_type name            phone     email           
   <int> <chr>     <chr>        <chr>           <chr>     <chr>           
1 407012 NCT03759… primary      Marja Mäkinen,… +3587754… marja.makinen@h…
2 407013 NCT03759… backup       Maaret Castrén… <NA>      maaret.castren@…
3 407014 NCT03759… primary      Emad RH Issak,… +2012722… dr.emad.r.h.iss…
4 407015 NCT03759… backup       Mohamed M Shaf… +2010016… drmshafeek44@ho…
5 407016 NCT03759… primary      Clinical Trial… 877-277-… IR-CTRegistrati…
6 407018 NCT03759… primary      Sandy Tran      (323) 36… satran@chla.usc…
Skim summary statistics
 n obs: 113033 
 n variables: 6 

── Variable type:character ─────────────────────────────────────────────────────────────
     variable missing complete      n min max empty n_unique
 contact_type       0   113033 113033   6   7     0        2
        email    3908   109125 113033   8  68     0    78177
         name       0   113033 113033   1 131     0    90095
       nct_id       0   113033 113033  11  11     0    75977
        phone    8483   104550 113033   1  44     0    77035

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n      mean       sd     p0    p25    p50
       id       0   113033 113033 463860.24 32736.71 407012 435535 463905
    p75   p100     hist
 492210 520501 ▇▇▇▇▇▇▇▇

mesh_headings table exists

# A tibble: 6 x 4
     id qualifier heading                subcategory                      
  <int> <chr>     <chr>                  <chr>                            
1     1 ""        ""                     2017 MeSH Headings by Subcategory
2     2 A02       Musculoskeletal System Abdominal Oblique Muscles        
3     3 A02       Musculoskeletal System Annulus Fibrosus                 
4     4 A02       Musculoskeletal System Aponeurosis                      
5     5 A02       Musculoskeletal System Collateral Ligament, Ulnar       
6     6 A02       Musculoskeletal System Coracoid Process                 
Skim summary statistics
 n obs: 3636 
 n variables: 4 

── Variable type:character ─────────────────────────────────────────────────────────────
    variable missing complete    n min max empty n_unique
     heading       0     3636 3636   0  63     4       88
   qualifier       0     3636 3636   0   3     4       88
 subcategory       0     3636 3636   0  68    12      632

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete    n   mean      sd p0    p25    p50     p75
       id       0     3636 3636 1818.5 1049.77  1 909.75 1818.5 2727.25
 p100     hist
 3636 ▇▇▇▇▇▇▇▇

mesh_terms table exists

# A tibble: 6 x 6
      id qualifier tree_number description mesh_term     downcase_mesh_te…
   <int> <chr>     <chr>       <chr>       <chr>         <chr>            
1 176233 A01       A01         <NA>        Body Regions  body regions     
2 176234 A01       A01.111     <NA>        Anatomic Lan… anatomic landmar…
3 176235 A01       A01.236     <NA>        Breast        breast           
4 176236 A01       A01.236.249 <NA>        Mammary Glan… mammary glands, …
5 176237 A01       A01.236.500 <NA>        Nipples       nipples          
6 176238 A01       A01.378     <NA>        Extremities   extremities      
```

    Warning in min(characters, na.rm = TRUE): no non-missing arguments to min;
    returning Inf

    Warning in max(characters, na.rm = TRUE): no non-missing arguments to max;
    returning -Inf

    Skim summary statistics
     n obs: 58744 
     n variables: 6 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
               variable missing complete     n min  max empty n_unique
            description   58744        0 58744 Inf -Inf     0        0
     downcase_mesh_term       0    58744 58744   2  104     0    28937
              mesh_term       0    58744 58744   2  104     0    28937
              qualifier       0    58744 58744   3    3     0      118
            tree_number       0    58744 58744   3   51     0    58744
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete     n     mean       sd     p0       p25
           id       0    58744 58744 205604.5 16958.08 176233 190918.75
          p50       p75   p100     hist
     205604.5 220290.25 234976 ▇▇▇▇▇▇▇▇
    
    milestones table exists
    
    # A tibble: 6 x 8
          id nct_id result_group_id ctgov_group_code title period description
       <int> <chr>            <int> <chr>            <chr> <chr>  <chr>      
    1 1.05e6 NCT03…         2573731 P1               NOT … Overa… ""         
    2 1.05e6 NCT03…         2573731 P1               COMP… Overa… ""         
    3 1.05e6 NCT03…         2573731 P1               STAR… Overa… ""         
    4 1.05e6 NCT03…         2573735 P1               NOT … Overa… ""         
    5 1.05e6 NCT03…         2573735 P1               COMP… Overa… ""         
    6 1.05e6 NCT03…         2573735 P1               STAR… Overa… ""         
    # ... with 1 more variable: count <int>
    Skim summary statistics
     n obs: 338769 
     n variables: 8 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
             variable missing complete      n min max  empty n_unique
     ctgov_group_code       0   338769 338769   2   3      0       32
          description       0   338769 338769   0 182 322645    10112
               nct_id       0   338769 338769  11  11      0    33755
               period       0   338769 338769   1  40      0     7438
                title       0   338769 338769   2  40      0     4480
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
            variable missing complete      n       mean        sd      p0
               count       0   338769 338769     239.38  30253.87       0
                  id       0   338769 338769 1220732.39  97839.09 1051208
     result_group_id       0   338769 338769   3e+06    238188.04 2573731
         p25     p50     p75          p100     hist
           1      12      49       1.2e+07 ▇▁▁▁▁▁▁▁
     1135993 1220742 1305471 1390175       ▇▇▇▇▇▇▇▇
     2778233   3e+06 3187662 3403198       ▇▇▇▇▇▇▇▇
    
    outcome_analyses table exists
    
    # A tibble: 6 x 22
          id nct_id outcome_id non_inferiority… non_inferiority… param_type
       <int> <chr>       <int> <chr>            <chr>            <chr>     
    1 436064 NCT03…     779334 Superiority      ""               ""        
    2 436065 NCT03…     779334 Other            ""               ""        
    3 436066 NCT03…     779335 Superiority      ""               ""        
    4 436067 NCT03…     779335 Superiority      ""               ""        
    5 436068 NCT03…     779335 Other            ""               ""        
    6 436069 NCT03…     779336 Superiority      ""               ""        
    # ... with 16 more variables: param_value <dbl>, dispersion_type <chr>,
    #   dispersion_value <dbl>, p_value_modifier <chr>, p_value <dbl>,
    #   ci_n_sides <chr>, ci_percent <dbl>, ci_lower_limit <dbl>,
    #   ci_upper_limit <dbl>, ci_upper_limit_na_comment <chr>,
    #   p_value_description <chr>, method <chr>, method_description <chr>,
    #   estimate_description <chr>, groups_description <chr>,
    #   other_analysis_description <chr>
    Skim summary statistics
     n obs: 139260 
     n variables: 22 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
                        variable missing complete      n min max  empty
                      ci_n_sides       0   139260 139260   0   7  61256
       ci_upper_limit_na_comment       0   139260 139260   0 174 139219
                 dispersion_type       0   139260 139260   0  26 113289
            estimate_description       0   139260 139260   0 250 108799
              groups_description       0   139260 139260   0 500  59727
                          method       0   139260 139260   0  40  24742
              method_description       0   139260 139260   0 150 107071
                          nct_id       0   139260 139260  11  11      0
     non_inferiority_description       0   139260 139260   0 500 127924
            non_inferiority_type       0   139260 139260   5  30      0
      other_analysis_description       0   139260 139260   0 988 138845
             p_value_description       0   139260 139260   0 250  97752
                p_value_modifier  100581    38679 139260   1   2      0
                      param_type       0   139260 139260   0  40  46261
     n_unique
            3
            9
            3
         8742
        38164
         2104
         6707
        11957
         4065
            6
          253
        11222
           10
         3268
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
       variable missing complete      n      mean       sd     p0       p25
             id       0   139260 139260 505716.38 40210.61 436064 470893.75
     outcome_id       0   139260 139260 910390.94 72740.63 779334 849845   
          p50       p75   p100     hist
     505719.5 540541.25 575367 ▇▇▇▇▇▇▇▇
     910586   976671.25  1e+06 ▆▆▆▇▆▆▇▇
    
    ── Variable type:numeric ───────────────────────────────────────────────────────────────
             variable missing complete      n    mean        sd         p0
       ci_lower_limit   51884    87376 139260  -51.35   4193.87 -855009   
           ci_percent   49709    89551 139260   94.19      4.12     -42.88
       ci_upper_limit   52203    87057 139260  320.51  38705.86  -20139   
     dispersion_value  113289    25971 139260   17.81    457.09      -1.6 
              p_value   24742   114518 139260    0.44      6.4      -30.79
          param_value   46261    92999 139260 2158.2  630389.64  -63419.4 
        p25   p50   p75        p100     hist
     -2.76  -0.13  0.8  75583.74    ▁▁▁▁▁▁▁▇
     95     95    95      595       ▁▇▁▁▁▁▁▁
      0.19   1.29  6.42 1e+07       ▇▁▁▁▁▁▁▁
      0.13   0.58  2.92 34677.86    ▇▁▁▁▁▁▁▁
      0.001  0.07  0.46  1789       ▇▁▁▁▁▁▁▁
     -0.4    0.43  1.94     1.9e+08 ▇▁▁▁▁▁▁▁
    
    design_groups table exists
    
    # A tibble: 6 x 5
           id nct_id  group_type   title          description                 
        <int> <chr>   <chr>        <chr>          <chr>                       
    1 1674606 NCT037… Active Comp… patients with… <NA>                        
    2 1686512 NCT036… Placebo Com… C1-2           <NA>                        
    3 1674607 NCT037… Sham Compar… patients with… <NA>                        
    4 1674041 NCT037… Active Comp… Growth Hormon… Growth hormone (Somatropin)…
    5 1674042 NCT037… Placebo Com… Placebo salin… Control group consisting of…
    6 1674043 NCT037… Experimental (Stage 1) Bra… Intravenous Brazikumab on D…
    Skim summary statistics
     n obs: 504711 
     n variables: 5 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
        variable missing complete      n min max empty n_unique
     description   70351   434360 504711   1 999     0   402782
      group_type   65336   439375 504711   4  20     0        9
          nct_id       0   504711 504711  11  11     0   243367
           title       0   504711 504711   1  62     0   304351
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n    mean        sd      p0       p25
           id       0   504711 504711 1927337 145926.62 1674041 1801057.5
         p50       p75    p100     hist
     1927464 2053703.5 2179915 ▇▇▇▇▇▇▇▇
    
    outcome_analysis_groups table exists
    
    # A tibble: 6 x 5
          id nct_id      outcome_analysis_id result_group_id ctgov_group_code
       <int> <chr>                     <int>           <int> <chr>           
    1 842502 NCT03615534              436064         2573768 O4              
    2 842503 NCT03615534              436064         2573769 O3              
    3 842504 NCT03615534              436064         2573770 O2              
    4 842505 NCT03615534              436064         2573771 O1              
    5 842506 NCT03615534              436065         2573768 O4              
    6 842507 NCT03615534              436065         2573769 O3              
    Skim summary statistics
     n obs: 269031 
     n variables: 5 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
             variable missing complete      n min max empty n_unique
     ctgov_group_code       0   269031 269031   2   3     0       39
               nct_id       0   269031 269031  11  11     0    11957
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
                variable missing complete      n      mean        sd      p0
                      id       0   269031 269031 977058.64  77679.81  842502
     outcome_analysis_id       0   269031 269031 505638.98  40221.68  436064
         result_group_id       0   269031 269031  3e+06    240932.18 2573768
           p25    p50       p75    p100     hist
      909789.5 977063   1e+06   1111617 ▇▇▇▇▇▇▇▇
      470602.5 505926  540228.5  575367 ▇▇▇▇▇▇▇▇
     2805680    3e+06 3228488   3403240 ▆▆▆▇▆▆▇▇
    
    design_outcomes table exists
    
    # A tibble: 6 x 7
           id nct_id  outcome_type measure  time_frame population description 
        <int> <chr>   <chr>        <chr>    <chr>      <chr>      <chr>       
    1 4939633 NCT037… primary      Summary… Days 0-14… <NA>       Summary of …
    2 4939634 NCT037… secondary    Subject… Days 0-28… <NA>       Subjects ex…
    3 4939635 NCT037… secondary    Subject… Day 0 - a… <NA>       Subjects ex…
    4 4939636 NCT037… secondary    Subject… Days 0 - … <NA>       Subject exp…
    5 4939637 NCT037… secondary    Proport… Days 0, 2… <NA>       Determinati…
    6 4939638 NCT037… secondary    Final O… Days 0, 2… <NA>       Determinati…

    Warning in min(characters, na.rm = TRUE): no non-missing arguments to min;
    returning Inf
    
    Warning in min(characters, na.rm = TRUE): no non-missing arguments to max;
    returning -Inf

    Skim summary statistics
     n obs: 1449626 
     n variables: 7 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
         variable missing complete       n min  max empty n_unique
      description  508666   940960 1449626   1  999     0   789578
          measure       0  1449626 1449626   1  255     0  1076593
           nct_id       0  1449626 1449626  11   11     0   273855
     outcome_type       0  1449626 1449626   5    9     0        3
       population 1449626        0 1449626 Inf -Inf     0        0
       time_frame   54051  1395575 1449626   1  255     0   335017
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete       n       mean     sd      p0        p25
           id       0  1449626 1449626 5648293.66 419408 4919736 5285462.25
           p50   p75    p100     hist
     5648743.5 6e+06 6374006 ▇▇▇▇▇▇▇▇
    
    designs table exists
    
    # A tibble: 6 x 14
          id nct_id allocation intervention_mo… observational_m…
       <int> <chr>  <chr>      <chr>            <chr>           
    1 960538 NCT03… <NA>       Single Group As… <NA>            
    2 960534 NCT03… Randomized Parallel Assign… <NA>            
    3 960535 NCT03… <NA>       <NA>             Cohort          
    4 960536 NCT03… Randomized Parallel Assign… <NA>            
    5 971551 NCT03… <NA>       <NA>             Other           
    6 978860 NCT03… <NA>       <NA>             Cohort          
    # ... with 9 more variables: primary_purpose <chr>,
    #   time_perspective <chr>, masking <chr>, masking_description <chr>,
    #   intervention_model_description <chr>, subject_masked <lgl>,
    #   caregiver_masked <lgl>, investigator_masked <lgl>,
    #   outcomes_assessor_masked <lgl>
    Skim summary statistics
     n obs: 291109 
     n variables: 14 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
                           variable missing complete      n min  max empty
                         allocation  114464   176645 291109  10   14     0
                 intervention_model   66986   224123 291109  19   23     0
     intervention_model_description  277053    14056 291109   1 1000     0
                            masking   65570   225539 291109   6   17     0
                masking_description  283661     7448 291109   1  999     0
                             nct_id       0   291109 291109  11   11     0
                observational_model  238755    52354 291109   5   35     0
                    primary_purpose   68142   222967 291109   5   31     0
                   time_perspective  235514    55595 291109   5   42     0
     n_unique
            3
            5
        13160
            5
         6357
       291109
           12
           10
           12
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n       mean       sd     p0   p25     p50
           id       0   291109 291109 1106531.22 84146.93 960515 1e+06 1106584
         p75    p100     hist
     1179399 1252199 ▇▇▇▇▇▇▇▇
    
    ── Variable type:logical ───────────────────────────────────────────────────────────────
                     variable missing complete      n mean
             caregiver_masked  257256    33853 291109    1
          investigator_masked  232512    58597 291109    1
     outcomes_assessor_masked  241319    49790 291109    1
               subject_masked  219982    71127 291109    1
                      count
     NA: 257256, TRU: 33853
     NA: 232512, TRU: 58597
     NA: 241319, TRU: 49790
     NA: 219982, TRU: 71127
    
    outcome_counts table exists
    
    # A tibble: 6 x 8
          id nct_id outcome_id result_group_id ctgov_group_code scope units
       <int> <chr>       <int>           <int> <chr>            <chr> <chr>
    1 1.83e6 NCT03…     779326         2573732 O1               Meas… Part…
    2 1.83e6 NCT03…     779327         2573736 O1               Meas… Part…
    3 1.83e6 NCT03…     779328         2573740 O1               Meas… Part…
    4 1.83e6 NCT03…     779329         2573741 O1               Meas… Part…
    5 1.83e6 NCT03…     779330         2573742 O1               Meas… Part…
    6 1.83e6 NCT03…     779331         2573749 O2               Meas… Part…
    # ... with 1 more variable: count <int>
    Skim summary statistics
     n obs: 588110 
     n variables: 8 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
             variable missing complete      n min max empty n_unique
     ctgov_group_code       0   588110 588110   2   3     0       39
               nct_id       0   588110 588110  11  11     0    33755
                scope       0   588110 588110   7   7     0        1
                units       0   588110 588110   2  40     0      979
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
            variable missing complete      n       mean        sd      p0
               count       0   588110 588110     448.83  23423.96       0
                  id       0   588110 588110 2123225.6  169870.95 1828843
          outcome_id       0   588110 588110   9e+05     72273.44  779326
     result_group_id       0   588110 588110   3e+06    239308.09 2573732
            p25       p50        p75    p100     hist
          15         43       120    4432481 ▇▁▁▁▁▁▁▁
       2e+06    2123241.5 2270350.75 2417426 ▇▇▇▇▇▇▇▇
      840949      9e+05    965800.75   1e+06 ▇▇▇▇▇▇▇▇
     2780143.25   3e+06   3194444    3403240 ▇▇▇▇▇▇▇▇

``` r
if(length(dne)>0){
  cat("These tables\n",dne,"\n aren't populated in AACT")
  }else{
  cat("All tables are populated!")
  }
```

    These tables
     schema_migrations 
     aren't populated in AACT

<!-- ## Brief overview of target tables -->

<!-- In this section, I'm giving brief points and showing a bit of the data from each table.  -->

<!-- ```{r} -->

<!-- for(name in names(target_tables)){ -->

<!-- tab <- tables[[name]] -->

<!-- if(nrow(tab)>0){ -->

<!--   cat(paste0(name," table exists\t")) -->

<!--   head(tab) -->

<!-- }else{ -->

<!--   cat(paste0("table ",name," doesn't exist\t")) -->

<!-- } -->

<!-- } -->

<!-- ``` -->

<!-- ### outcome analyses -->

<!-- ```{r} -->

<!-- tab <- tables[["outcome_analyses"]] -->

<!-- nrow(tab) -->

<!-- head(tab) -->

<!-- apply(tab,2,skimr::n_missing) -->

<!-- ``` -->

<!-- This table contains 588110 outcome analyses from 588110 clinical trials. I'm not sure what each column means...Luckily, this [document](ClinicalTrials.gov Results Data Element...terventional and Observational Studies) contains that information! The different columns list the types of statistical tests used and their parameters. Alot of these parameters are missing. -->

<!-- ### facility investigators -->

<!-- ```{r} -->

<!-- tab <- tables[["facility_investigators"]] -->

<!-- nrow(tab) -->

<!-- head(tab) -->

<!-- apply(tab,2,skimr::n_missing) -->

<!-- ``` -->

<!-- This table contains 588110 facility roles for 588110 clinical trials.  -->

<!-- ```{r} -->

<!-- tab %>% group_by(role) %>% count() %>% ggplot() + geom_bar(stat="identity",aes(role,n,fill=role)) + coord_flip() -->

<!-- ``` -->

<!-- Apparently, mostly principal investigators are listed and then sub-investigators. But no study chairs.  -->

<!-- ### outcome counts -->

<!-- ```{r} -->

<!-- tab <- tables[["outcome_counts"]] -->

<!-- nrow(tab) -->

<!-- head(tab) -->

<!-- apply(tab,2,skimr::n_missing) -->

<!-- ``` -->

<!-- This table contains the counts of outcomes, about 588110, for 33755 clinical trials. This table is completely filled but only has information on a relatively few clinical trials. -->

<!-- ### drop withdrawals -->

<!-- ```{r} -->

<!-- tab <- tables[["drop_withdrawals"]] -->

<!-- nrow(tab) -->

<!-- head(tab) -->

<!-- apply(tab,2,skimr::n_missing) -->

<!-- ``` -->

<!-- This table contains study drop information for 33755 clinical trials. This table is completely filled but only has information on a relatively few clinical trials. -->

<!-- ###baseline measurements -->

<!-- ```{r} -->

<!-- tab <- tables[["baseline_measurements"]] -->

<!-- nrow(tab) -->

<!-- head(tab) -->

<!-- apply(tab,2,skimr::n_missing) -->

<!-- ``` -->

<!-- This table contains study measurement info for 33755 clinical trials. This table is missing some parameter values and only has information on a relatively few clinical trials. -->

<!-- ### outcome analysis groups -->

<!-- ```{r} -->

<!-- tab <- tables[["outcome_analysis_groups"]] -->

<!-- nrow(tab) -->

<!-- head(tab) -->

<!-- apply(tab,2,skimr::n_missing) -->

<!-- ``` -->

<!-- This table contains study outcome analysis information for 33755 clinical trials. This table is completely filled but only has information on a relatively few clinical trials. And I'm not sire what the ctgov_group_code means... -->

<!-- ### baseline counts -->

<!-- ```{r} -->

<!-- tab <- tables[["baseline_counts"]] -->

<!-- nrow(tab) -->

<!-- head(tab) -->

<!-- apply(tab,2,skimr::n_missing) -->

<!-- ``` -->

<!-- This table contains study baseline counts information for 33755 clinical trials. This table is completely filled but only has information on a relatively few clinical trials. I'm also not sure what these columnns mean... -->

<!-- ### browse interventions -->

<!-- ```{r} -->

<!-- tab <- tables[["browse_interventions"]] -->

<!-- nrow(tab) -->

<!-- head(tab) -->

<!-- apply(tab,2,skimr::n_missing) -->

<!-- ``` -->

<!-- This table contains study baseline counts information for 33755 clinical trials. This table is completely filled but only has information on a relatively few clinical trials. I'm also not sure what these columnns mean... -->

<!-- ### browse interventions -->

<!-- ```{r} -->

<!-- tab <- tables[["browse_interventions"]] -->

<!-- nrow(tab) -->

<!-- head(tab) -->

<!-- apply(tab,2,skimr::n_missing) -->

<!-- ``` -->

<!-- This table contains study baseline counts information for 33755 clinical trials. This table is completely filled but only has information on a relatively few clinical trials. I'm also not sure what these columnns mean... -->

## Notes and tables of interest

The primary key to link the tables in this database is *nct\_id*

The *study\_references* table might be interesting to use since it gives
the PMID number for that clinical trial. The corresponding text can be
analyzed to discover topics and trends amongst clinical trials, using
methods like Latent Direchlet Allocation. Or, it might be interesting to
analyze the missing citations to clinical trials-looks like there’s over
20K publication recordings missing.

In *responsible\_parties* it might be interesting to see who conducts
these trials and what that distribution is like. Though, about 27500
clinical trials don’t have this attribute.

The *design\_outcomes* table doesn’t seem to be documented well…we may
want to investigate this table a bit more.

The *ipd\_information\_types* table shows the types of clinical trials.
There’s on about 6.5K names here.

The *overall\_officials* table might be interesting to look at in
combination with the *responsible\_parties* table. There should be good
agreement.

The *designs\_table* looks at the experimental design for the clinical
trial, like if it was an observational study or the methodology used.

The *keywords* table might be interesting to look at. I wonder how
similar they are to MeSH terms?

The *participant\_flows* table is kind of different-it seems to give a
text description of the trial recruitment and before patients were
assigned their study arm to be in.

The *browse\_interventions* table seems to be similar to the *keywords*
table but here they’re labeled as MeSH terms.

The *facilities* table would be good to look at to find out the location
of these trials.

The *milestones* table is more fully described
[here](https://aact.ctti-clinicaltrials.org/points_to_consider). For the
ctgov\_group\_code, those with P1 are ‘All Milestones &
Drop\_Withdrawals associated with this study’s experimental group link
to this row.’ and P2 are ‘All Milestones & Drop\_Withdrawals associated
with this study’s studies control group link to this row.’. This is one
of the four results tables.

The *result\_agreements* table is another results table but not about
groups.

The *calculated\_values* table seems to be a summary table, but not sure
of what…

The *facility\_contacts* table seems just to have contact info for the
trial’s facilities.

The *baseline\_counts* table is another results table that I think tells
you of the number of participants in the control and experimental
groups. Might be interesting to get the number of participants starting
out in a trial.

The *mesh\_terms* table gives more details on the mesh terms.

The *design\_group\_interventions* table just contains concept ids. This
table links to the *intervention\_other\_names* table for the brand name
drug or device, it seems.
