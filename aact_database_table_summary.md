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
 [1] "schema_migrations"          "outcome_analyses"          
 [3] "result_contacts"            "central_contacts"          
 [5] "facility_investigators"     "result_groups"             
 [7] "outcome_counts"             "design_groups"             
 [9] "interventions"              "outcomes"                  
[11] "outcome_analysis_groups"    "studies"                   
[13] "browse_conditions"          "eligibilities"             
[15] "baseline_measurements"      "documents"                 
[17] "mesh_headings"              "reported_events"           
[19] "brief_summaries"            "drop_withdrawals"          
[21] "id_information"             "countries"                 
[23] "study_references"           "responsible_parties"       
[25] "design_outcomes"            "ipd_information_types"     
[27] "overall_officials"          "designs"                   
[29] "keywords"                   "participant_flows"         
[31] "browse_interventions"       "facilities"                
[33] "milestones"                 "result_agreements"         
[35] "calculated_values"          "facility_contacts"         
[37] "baseline_counts"            "mesh_terms"                
[39] "design_group_interventions" "intervention_other_names"  
[41] "outcome_measurements"       "sponsors"                  
[43] "conditions"                 "detailed_descriptions"     
[45] "links"                      "pending_results"           
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

    table schema_migrations doesn't exist
    
    outcome_analyses table exists
    
    # A tibble: 6 x 22
          id nct_id outcome_id non_inferiority… non_inferiority… param_type
       <int> <chr>       <int> <chr>            <chr>            <chr>     
    1 286582 NCT03…     514922 Superiority      ""               Least Squ…
    2 286583 NCT03…     514922 Superiority      ""               Least Squ…
    3 287410 NCT02…     516351 Superiority      ""               ""        
    4 286549 NCT03…     514896 Superiority      Test of interac… Mean Diff…
    5 286550 NCT03…     514896 Superiority      ""               Mean Diff…
    6 286551 NCT03…     514896 Superiority      ""               Mean Diff…
    # ... with 16 more variables: param_value <dbl>, dispersion_type <chr>,
    #   dispersion_value <dbl>, p_value_modifier <chr>, p_value <dbl>,
    #   ci_n_sides <chr>, ci_percent <dbl>, ci_lower_limit <dbl>,
    #   ci_upper_limit <dbl>, ci_upper_limit_na_comment <chr>,
    #   p_value_description <chr>, method <chr>, method_description <chr>,
    #   estimate_description <chr>, groups_description <chr>,
    #   other_analysis_description <chr>
    Skim summary statistics
     n obs: 139228 
     n variables: 22 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
                        variable missing complete      n min max  empty
                      ci_n_sides       0   139228 139228   0   7  61250
       ci_upper_limit_na_comment       0   139228 139228   0 174 139187
                 dispersion_type       0   139228 139228   0  26 113257
            estimate_description       0   139228 139228   0 250 108772
              groups_description       0   139228 139228   0 500  59703
                          method       0   139228 139228   0  40  24721
              method_description       0   139228 139228   0 150 107039
                          nct_id       0   139228 139228  11  11      0
     non_inferiority_description       0   139228 139228   0 500 127901
            non_inferiority_type       0   139228 139228   5  30      0
      other_analysis_description       0   139228 139228   0 988 138822
             p_value_description       0   139228 139228   0 250  97722
                p_value_modifier  100550    38678 139228   1   2      0
                      param_type       0   139228 139228   0  40  46255
     n_unique
            3
            9
            3
         8739
        38156
         2103
         6707
        11952
         4063
            6
          249
        11220
           10
         3265
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
       variable missing complete      n      mean       sd     p0       p25
             id       0   139228 139228 359284.68 41543.7  286549 323690.75
     outcome_id       0   139228 139228 650903.51 74178.85 514896 589852   
          p50       p75   p100     hist
     359527.5 394467.25 436063 ▇▇▇▇▇▇▇▆
     650638.5 717433    779325 ▆▅▆▇▆▆▇▆
    
    ── Variable type:numeric ───────────────────────────────────────────────────────────────
             variable missing complete      n    mean        sd         p0
       ci_lower_limit   51875    87353 139228  -51.37   4194.42 -855009   
           ci_percent   49700    89528 139228   94.19      4.12     -42.88
       ci_upper_limit   52194    87034 139228  320.59  38710.97  -20139   
     dispersion_value  113257    25971 139228   17.81    457.09      -1.6 
              p_value   24721   114507 139228    0.44      6.4      -30.79
          param_value   46255    92973 139228 2158.8  630477.78  -63419.4 
        p25   p50   p75        p100     hist
     -2.77  -0.13  0.8  75583.74    ▁▁▁▁▁▁▁▇
     95     95    95      595       ▁▇▁▁▁▁▁▁
      0.19   1.29  6.41 1e+07       ▇▁▁▁▁▁▁▁
      0.13   0.58  2.92 34677.86    ▇▁▁▁▁▁▁▁
      0.001  0.07  0.46  1789       ▇▁▁▁▁▁▁▁
     -0.4    0.43  1.94     1.9e+08 ▇▁▁▁▁▁▁▁
    
    result_contacts table exists
    
    # A tibble: 6 x 6
         id nct_id   organization           name           phone   email      
      <int> <chr>    <chr>                  <chr>          <chr>   <chr>      
    1 68842 NCT0367… Auerbach Hematology a… Michael Auerb… 410780… mauerbachm…
    2 68843 NCT0364… Montefiore Medical Ce… Lisa Wiechmann <NA>    lwiechma@m…
    3 68846 NCT0358… Medical University of… Dr. Angela De… 843-76… dempsear@m…
    4 68847 NCT0358… Washington University… Dr. Catherine… 314-28… langc@wust…
    5 68848 NCT0357… Portola Pharmaceutica… Head of Clini… 650-24… <NA>       
    6 68849 NCT0355… Portola Pharmaceutica… Head of Clini… 650-24… <NA>       
    Skim summary statistics
     n obs: 33740 
     n variables: 6 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
         variable missing complete     n min max empty n_unique
            email    4718    29022 33740   9  78     0    14045
             name       0    33740 33740   1 100     0    16884
           nct_id       0    33740 33740  11  11     0    33740
     organization       3    33737 33740   2 213     0     8147
            phone    3289    30451 33740   3  39     0    14760
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete     n    mean      sd    p0      p25     p50
           id       0    33740 33740 86093.1 9904.99 68842 77561.75 86113.5
          p75  p100     hist
     94625.25 1e+05 ▇▇▇▇▇▇▇▆
    
    central_contacts table exists
    
    # A tibble: 6 x 6
          id nct_id    contact_type name          phone    email              
       <int> <chr>     <chr>        <chr>         <chr>    <chr>              
    1 270597 NCT03725… primary      Nicholas D'C… +321637… nicholas.dcruz@kul…
    2 270598 NCT03725… backup       Pieter Ginis… +321637… pieter.ginis@kuleu…
    3 270599 NCT03725… primary      ABBVIE CALL … 847.283… abbvieclinicaltria…
    4 270600 NCT03725… primary      Ryan Abbott,… 310-794… CEWM@mednet.ucla.e…
    5 270601 NCT03725… primary      Jeremiah E F… 435-797… jeremiah.fruge@agg…
    6 270602 NCT03725… primary      David Church… 0190269… david.churchill1@n…
    Skim summary statistics
     n obs: 112989 
     n variables: 6 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
         variable missing complete      n min max empty n_unique
     contact_type       0   112989 112989   6   7     0        2
            email    3908   109081 112989   8  68     0    78152
             name       0   112989 112989   1 131     0    90067
           nct_id       0   112989 112989  11  11     0    75949
            phone    8487   104502 112989   1  44     0    77009
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n      mean       sd     p0   p25    p50
           id       0   112989 112989 333817.91 36482.49 270597 3e+05 333505
        p75   p100     hist
     363615 406879 ▇▇▇▇▇▇▆▃
    
    facility_investigators table exists
    
    # A tibble: 6 x 5
           id nct_id     facility_id role             name                    
        <int> <chr>            <int> <chr>            <chr>                   
    1 1314488 NCT037502…     8588624 Principal Inves… Guillaume Sood, MD      
    2 1355605 NCT037593…     8733928 Principal Inves… Marja Mäkinen, PhD      
    3 1355606 NCT037593…     8733928 Sub-Investigator Heini Harve-Rytsälä, MD…
    4 1314491 NCT037502…     8588627 Principal Inves… Carlo E Traverso, MD    
    5 1314492 NCT037502…     8588628 Principal Inves… Augusto Azuara-Blanco, …
    6 1314493 NCT037500…     8588635 Principal Inves… Klaus Pfeifer, Prof. Dr.
    Skim summary statistics
     n obs: 182365 
     n variables: 5 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
     variable missing complete      n min max empty n_unique
         name       0   182365 182365   2  75     0   115137
       nct_id       0   182365 182365  11  11     0    33735
         role       0   182365 182365  11  22     0        3
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
        variable missing complete      n       mean        sd      p0     p25
     facility_id       0   182365 182365 6856923.53 974181.69 5842261 6095613
              id       0   182365 182365 1078949.44 126630.51  921727  987530
         p50     p75    p100     hist
     6446384 7405351 8765614 ▇▅▃▁▁▁▁▃
       1e+06 1099113 1358613 ▇▇▇▃▁▁▁▅
    
    result_groups table exists
    
    # A tibble: 6 x 6
           id nct_id  ctgov_group_code result_type title    description       
        <int> <chr>   <chr>            <chr>       <chr>    <chr>             
    1 1709255 NCT027… O1               Outcome     Contrast "All subjects wil…
    2 1709256 NCT027… E1               Reported E… Contrast "All subjects wil…
    3 1709257 NCT027… B3               Baseline    Total    Total of all repo…
    4 1709258 NCT027… B2               Baseline    Muse De… "Participants in …
    5 1709259 NCT027… B1               Baseline    Spire D… "Participants wil…
    6 1709260 NCT027… P2               Participan… Muse De… "Participants in …
    Skim summary statistics
     n obs: 828340 
     n variables: 6 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
             variable missing complete      n min max empty n_unique
     ctgov_group_code       0   828340 828340   2   3     0      136
          description       0   828340 828340   0 999 17177   137123
               nct_id       0   828340 828340  11  11     0    33740
          result_type       0   828340 828340   7  16     0        4
                title       0   828340 828340   0  62    13    93879
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n      mean        sd      p0        p25
           id       0   828340 828340 2126583.1 244760.48 1699204 1916630.75
           p50        p75    p100     hist
     2128026.5 2336702.25 2573729 ▇▇▇▇▇▇▇▆
    
    outcome_counts table exists
    
    # A tibble: 6 x 8
          id nct_id outcome_id result_group_id ctgov_group_code scope units
       <int> <chr>       <int>           <int> <chr>            <chr> <chr>
    1 1.21e6 NCT03…     514878         1699206 O1               Meas… Part…
    2 1.21e6 NCT03…     514879         1699210 O1               Meas… Part…
    3 1.21e6 NCT03…     514880         1699211 O1               Meas… Part…
    4 1.21e6 NCT03…     514881         1699212 O1               Meas… Part…
    5 1.21e6 NCT03…     514893         1699279 O2               Meas… Part…
    6 1.21e6 NCT03…     514893         1699280 O1               Meas… Part…
    # ... with 1 more variable: count <int>
    Skim summary statistics
     n obs: 587670 
     n variables: 8 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
             variable missing complete      n min max empty n_unique
     ctgov_group_code       0   587670 587670   2   3     0       39
               nct_id       0   587670 587670  11  11     0    33740
                scope       0   587670 587670   7   7     0        1
                units       0   587670 587670   2  40     0      979
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
            variable missing complete      n       mean        sd      p0
               count       0   587670 587670     449.13  23432.72       0
                  id       0   587670 587670 1510646.67 173845.07 1206838
          outcome_id       0   587670 587670  643709.75  74185.28  514878
     result_group_id       0   587670 587670 2126414.03 245050.31 1699206
            p25       p50        p75    p100     hist
          15         43       120    4432481 ▇▁▁▁▁▁▁▁
     1361722.25 1511825.5 1659721.75 1828842 ▇▇▇▇▇▇▇▆
      580331.25  644149    706836.75  779325 ▇▇▇▇▇▇▇▆
     1916651.25 2127939.5 2337367.75 2573727 ▇▇▇▇▇▇▇▆
    
    design_groups table exists
    
    # A tibble: 6 x 5
           id nct_id   group_type   title          description                
        <int> <chr>    <chr>        <chr>          <chr>                      
    1 1113104 NCT0372… <NA>         Participants … <NA>                       
    2 1112406 NCT0372… Active Comp… Magnesium Sul… Continuous intravenous inf…
    3 1112407 NCT0372… Experimental Lidocaine      Continuous intravenous inf…
    4 1112408 NCT0372… Experimental Split-Belt Tr… Split-Belt Training with a…
    5 1112409 NCT0372… Experimental Split-Belt Tr… Split-Belt Training with a…
    6 1112410 NCT0372… Experimental Split-Belt Tr… Split-Belt Training with c…
    Skim summary statistics
     n obs: 504501 
     n variables: 5 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
        variable missing complete      n min max empty n_unique
     description   70331   434170 504501   1 999     0   402602
      group_type   65295   439206 504501   4  20     0        9
          nct_id       0   504501 504501  11  11     0   243276
           title       0   504501 504501   1  62     0   304202
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n       mean        sd      p0     p25
           id       0   504501 504501 1381467.57 152501.37 1112406 1251103
         p50     p75    p100     hist
     1382465 1510718 1673804 ▇▇▇▇▇▇▇▃
    
    interventions table exists
    
    # A tibble: 6 x 5
           id nct_id   intervention_type name          description            
        <int> <chr>    <chr>             <chr>         <chr>                  
    1 1129179 NCT0362… Other             tVNS          Intervention           
    2 1116946 NCT0372… Drug              Magnesium Su… Magnesium Sulfate 15mg…
    3 1116947 NCT0372… Drug              Lidocaine     Lidocaine 1,5mg/kg/h   
    4 1116948 NCT0372… Behavioral        Split-Belt T… One session of 6 x 5 m…
    5 1116949 NCT0372… Drug              Upadacitinib  It will be administere…
    6 1116950 NCT0372… Drug              Corticostero… It will be administere…
    Skim summary statistics
     n obs: 505405 
     n variables: 5 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
              variable missing complete      n min  max empty n_unique
           description   91629   413776 505405   1 1000     0   353419
     intervention_type       0   505405 505405   4   19     0       11
                  name       0   505405 505405   1  200     0   249905
                nct_id       0   505405 505405  11   11     0   258668
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n       mean        sd      p0     p25
           id       0   505405 505405 1386890.83 152875.28 1116946 1256340
         p50     p75    p100     hist
     1388010 1516352 1680168 ▇▇▇▇▇▇▇▃
    
    outcomes table exists
    
    # A tibble: 6 x 13
          id nct_id outcome_type title description time_frame population
       <int> <chr>  <chr>        <chr> <chr>       <chr>      <chr>     
    1 525132 NCT02… Secondary    Abso… The TSQM i… Baseline,… FAS. Here…
    2 525133 NCT02… Secondary    Abso… Z-score is… Baseline,… FAS. Here…
    3 525134 NCT02… Secondary    Abso… ""          Baseline,… FAS. Here…
    4 543969 NCT02… Primary      Chan… ""          Baseline … ""        
    5 525135 NCT02… Secondary    Abso… Z-score is… Baseline,… FAS. Here…
    6 525136 NCT02… Secondary    Abso… ""          Baseline,… FAS. Here…
    # ... with 6 more variables: anticipated_posting_date <date>,
    #   anticipated_posting_month_year <chr>, units <chr>,
    #   units_analyzed <chr>, dispersion_type <chr>, param_type <chr>
    Skim summary statistics
     n obs: 250587 
     n variables: 13 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
                           variable missing complete      n min max  empty
     anticipated_posting_month_year       0   250587 250587   0   7 249505
                        description       0   250587 250587   0 999  26962
                    dispersion_type       0   250587 250587   0  34 100525
                             nct_id       0   250587 250587  11  11      0
                       outcome_type       0   250587 250587   7  19      0
                         param_type       0   250587 250587   0  28  17108
                         population       0   250587 250587   0 350  54955
                         time_frame       0   250587 250587   0 255     71
                              title       0   250587 250587   2 255      0
                              units       0   250587 250587   0  40  17137
                     units_analyzed       0   250587 250587   0  40 246142
     n_unique
          122
       183159
           23
        33740
            4
           10
        77354
        73559
       206182
        20986
          516
    
    ── Variable type:Date ──────────────────────────────────────────────────────────────────
                     variable missing complete      n        min        max
     anticipated_posting_date  249508     1079 250587 2007-04-30 3333-12-31
         median n_unique
     2018-12-31      119
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n      mean       sd     p0      p25
           id       0   250587 250587 644198.16 73994.38 514878 580621.5
        p50      p75   p100     hist
     644555 707702.5 779325 ▇▇▇▇▇▇▇▆
    
    outcome_analysis_groups table exists
    
    # A tibble: 6 x 5
          id nct_id      outcome_analysis_id result_group_id ctgov_group_code
       <int> <chr>                     <int>           <int> <chr>           
    1 553325 NCT03582943              286549         1699292 O2              
    2 553326 NCT03582943              286549         1699293 O1              
    3 553327 NCT03582943              286550         1699292 O2              
    4 553328 NCT03582943              286550         1699293 O1              
    5 553329 NCT03582943              286551         1699292 O2              
    6 553330 NCT03582943              286551         1699293 O1              
    Skim summary statistics
     n obs: 268970 
     n variables: 5 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
             variable missing complete      n min max empty n_unique
     ctgov_group_code       0   268970 268970   2   3     0       39
               nct_id       0   268970 268970  11  11     0    11952
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
                variable missing complete      n       mean        sd      p0
                      id       0   268970 268970  693865.98  80321.74  553325
     outcome_analysis_id       0   268970 268970  359281.46  41592.12  286549
         result_group_id       0   268970 268970 2150066.61 245266.24 1699292
            p25       p50        p75    p100     hist
      625020.25  694324.5  761817.75  842501 ▇▇▇▇▇▇▇▆
      323402.25  359782    394412     436063 ▇▇▇▇▇▇▇▆
     1945908.25 2154399.5 2371312    2573727 ▆▅▆▇▆▆▇▆
    
    studies table exists
    
    # A tibble: 6 x 64
      nct_id nlm_download_da… study_first_sub… results_first_s…
      <chr>  <chr>            <date>           <date>          
    1 NCT00… ClinicalTrials.… 2007-03-18       NA              
    2 NCT00… ClinicalTrials.… 2007-03-19       NA              
    3 NCT00… ClinicalTrials.… 2007-03-17       NA              
    4 NCT00… ClinicalTrials.… 2007-03-19       NA              
    5 NCT00… ClinicalTrials.… 2007-03-19       NA              
    6 NCT00… ClinicalTrials.… 2007-03-19       NA              
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
     n obs: 291016 
     n variables: 64 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
                               variable missing complete      n min  max
                                acronym  217017    73999 291016   1   14
                    baseline_population       0   291016 291016   0  350
                    biospec_description       0   291016 291016   0 1143
                      biospec_retention  277367    13649 291016  13   19
                            brief_title       0   291016 291016   7  300
                   completion_date_type   26125   264891 291016   6   11
                  completion_month_year   19217   271799 291016   8   18
     disposition_first_posted_date_type  284667     6349 291016   6    8
                        enrollment_type   16884   274132 291016   6   11
                    ipd_access_criteria  289138     1878 291016   3 1000
                         ipd_time_frame  288866     2150 291016   1  806
                                ipd_url  289759     1257 291016   9  156
                      last_known_status  262593    28423 291016  10   23
           last_update_posted_date_type       0   291016 291016   6    8
                limitations_and_caveats       0   291016 291016   0  250
                                 nct_id       0   291016 291016  11   11
          nlm_download_date_description       0   291016 291016  58   59
                         official_title   10328   280688 291016  18  598
                         overall_status       0   291016 291016   8   25
                                  phase   60098   230918 291016   3   15
                      plan_to_share_ipd  213758    77258 291016   2    9
          plan_to_share_ipd_description  276395    14621 291016   1 1000
           primary_completion_date_type   22357   268659 291016   6   11
          primary_completion_month_year   22292   268724 291016   8   18
         results_first_posted_date_type  257276    33740 291016   6    8
                                 source       0   291016 291016   2  147
                        start_date_type  204319    86697 291016   6   11
                       start_month_year    4731   286285 291016   8   18
           study_first_posted_date_type       0   291016 291016   6    8
                             study_type       0   291016 291016   3   32
                        target_duration  286605     4411 291016   5   10
                verification_month_year     803   290213 291016   8   18
                            why_stopped  271670    19346 291016   2  175
      empty n_unique
          0    59809
     281979     7672
     277298    10598
          0        3
          0   289104
          0        2
          0     6673
          0        2
          0        2
          0     1162
          0     1334
          0      240
          0        4
          0        2
     283561     7047
          0   291016
          0       16
          0   278230
          0       14
          0        8
          0        3
          0     9164
          0        2
          0     6245
          0        2
          0    18538
          0        2
          0     6017
          0        2
          0        5
          0      131
          0     1315
          0    14490
    
    ── Variable type:Date ──────────────────────────────────────────────────────────────────
                                variable missing complete      n        min
                         completion_date   19217   271799 291016 1900-01-31
           disposition_first_posted_date  284667     6349 291016 2009-08-10
        disposition_first_submitted_date  284667     6349 291016 2008-10-09
     disposition_first_submitted_qc_date  284667     6349 291016 2009-07-10
                 last_update_posted_date       0   291016 291016 2005-06-24
              last_update_submitted_date       0   291016 291016 2005-06-23
           last_update_submitted_qc_date       0   291016 291016 2005-06-23
                 primary_completion_date   22292   268724 291016 1900-01-31
               results_first_posted_date  257276    33740 291016 2008-09-26
            results_first_submitted_date  257276    33740 291016 2008-09-25
         results_first_submitted_qc_date  257276    33740 291016 2008-09-25
                              start_date    4731   286285 291016 1900-01-31
                 study_first_posted_date       0   291016 291016 1999-09-20
              study_first_submitted_date       0   291016 291016 1999-09-17
           study_first_submitted_qc_date       0   291016 291016 1999-09-17
                       verification_date     803   290213 291016 1981-10-31
            max     median n_unique
     2100-12-31 2015-12-31     6329
     2018-11-29 2014-03-03     1522
     2018-11-27 2014-01-15     1919
     2018-11-27 2014-01-30     1922
     2018-11-29 2016-11-02     3312
     2018-11-28 2016-10-28     4544
     2018-11-28 2016-10-28     4544
     2100-12-31 2015-10-31     5920
     2018-11-29 2015-04-15     2424
     2018-11-02 2014-12-12     3134
     2018-11-27 2015-04-07     3079
     2100-01-31 2012-10-31     5811
     2018-11-29 2013-05-24     4428
     2018-11-28 2013-04-29     6110
     2018-11-28 2013-05-22     5910
     2018-11-30 2016-08-31     1286
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
             variable missing complete      n     mean         sd p0 p25 p50
           enrollment    6583   284433 291016 24981.38 2928973.87  0  30  70
       number_of_arms   84297   206719 291016     2.12       1.27  1   1   2
     number_of_groups  254459    36557 291016     1.79       1.19  1   1   1
     p75  p100     hist
     200 1e+09 ▇▁▁▁▁▁▁▁
       2    32 ▇▁▁▁▁▁▁▁
       2    30 ▇▁▁▁▁▁▁▁
    
    ── Variable type:logical ───────────────────────────────────────────────────────────────
                              variable missing complete      n    mean
       expanded_access_type_individual  290937       79 291016 1      
     expanded_access_type_intermediate  290987       29 291016 1      
        expanded_access_type_treatment  290973       43 291016 1      
                               has_dmc   52863   238153 291016 0.38   
                   has_expanded_access    5064   285952 291016 0.0014 
               is_fda_regulated_device  225692    65324 291016 0.063  
                 is_fda_regulated_drug  225629    65387 291016 0.23   
                               is_ppsd  287764     3252 291016 0.00062
                  is_unapproved_device  286949     4067 291016 0.21   
                          is_us_export  280175    10841 291016 0.28   
                                  count
                    NA: 290937, TRU: 79
                    NA: 290987, TRU: 29
                    NA: 290973, TRU: 43
     FAL: 147590, TRU: 90563, NA: 52863
        FAL: 285553, NA: 5064, TRU: 399
      NA: 225692, FAL: 61231, TRU: 4093
     NA: 225629, FAL: 50584, TRU: 14803
          NA: 287764, FAL: 3250, TRU: 2
        NA: 286949, FAL: 3226, TRU: 841
       NA: 280175, FAL: 7768, TRU: 3073
    
    ── Variable type:POSIXct ───────────────────────────────────────────────────────────────
       variable missing complete      n        min        max     median
     created_at       0   291016 291016 2018-11-01 2018-11-30 2018-11-01
     updated_at       0   291016 291016 2018-11-01 2018-11-30 2018-11-01
     n_unique
       291016
       291016
    
    browse_conditions table exists
    
    # A tibble: 6 x 4
           id nct_id      mesh_term        downcase_mesh_term
        <int> <chr>       <chr>            <chr>             
    1 1551968 NCT00684931 Disease          disease           
    2 1316644 NCT02462213 Cardiomyopathies cardiomyopathies  
    3 1426813 NCT01612039 Colitis          colitis           
    4 1171652 NCT03594994 Obesity          obesity           
    5 1428716 NCT01597245 Psoriasis        psoriasis         
    6 1290356 NCT02666391 Ischemia         ischemia          
    Skim summary statistics
     n obs: 516627 
     n variables: 4 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
               variable missing complete      n min max empty n_unique
     downcase_mesh_term       0   516627 516627   4  58     0     3886
              mesh_term       0   516627 516627   4  58     0     3886
                 nct_id       0   516627 516627  11  11     0   235257
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n       mean        sd      p0       p25
           id       0   516627 516627 1431241.31 157080.47 1155006 1297337.5
         p50       p75    p100     hist
     1431952 1563374.5 1739486 ▇▇▇▇▇▇▇▃
    
    eligibilities table exists
    
    # A tibble: 6 x 11
          id nct_id sampling_method gender minimum_age maximum_age
       <int> <chr>  <chr>           <chr>  <chr>       <chr>      
    1 649126 NCT03… ""              Female 18 Years    75 Years   
    2 649127 NCT03… ""              All    18 Years    N/A        
    3 649161 NCT03… ""              Female 18 Years    N/A        
    4 649129 NCT03… ""              All    20 Years    64 Years   
    5 649130 NCT03… ""              All    18 Years    70 Years   
    6 649131 NCT03… ""              All    18 Years    80 Years   
    # ... with 5 more variables: healthy_volunteers <chr>, population <chr>,
    #   criteria <chr>, gender_description <chr>, gender_based <lgl>
    Skim summary statistics
     n obs: 291016 
     n variables: 11 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
               variable missing complete      n min   max  empty n_unique
               criteria       0   291016 291016   0 18929    884   286706
                 gender       0   291016 291016   0     6    820        4
     gender_description       0   291016 291016   0   918 289015     1601
     healthy_volunteers       0   291016 291016   0    26   4424        3
            maximum_age       0   291016 291016   0    11    820      432
            minimum_age       0   291016 291016   0    10    820      235
                 nct_id       0   291016 291016  11    11      0   291016
             population       0   291016 291016   0  1160 236907    51606
        sampling_method       0   291016 291016   0    22 236870        3
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n      mean       sd     p0       p25
           id       0   291016 291016 792016.25 87551.83 637958 717120.75
          p50       p75   p100     hist
     792471.5 866294.25 960392 ▇▇▇▇▇▇▇▃
    
    ── Variable type:logical ───────────────────────────────────────────────────────────────
         variable missing complete      n mean                 count
     gender_based  287989     3027 291016    1 NA: 287989, TRU: 3027
    
    baseline_measurements table exists
    
    # A tibble: 6 x 18
          id nct_id result_group_id ctgov_group_code classification category
       <int> <chr>            <int> <chr>            <chr>          <chr>   
    1 1.77e6 NCT02…         1706744 B5               ""             ""      
    2 1.77e6 NCT02…         1706745 B4               ""             ""      
    3 1.77e6 NCT02…         1706746 B3               ""             ""      
    4 1.77e6 NCT02…         1706747 B2               White          ""      
    5 1.77e6 NCT02…         1706747 B2               ""             ""      
    6 1.77e6 NCT02…         1706748 B1               ""             ""      
    # ... with 12 more variables: title <chr>, description <chr>, units <chr>,
    #   param_type <chr>, param_value <chr>, param_value_num <dbl>,
    #   dispersion_type <chr>, dispersion_value <chr>,
    #   dispersion_value_num <dbl>, dispersion_lower_limit <dbl>,
    #   dispersion_upper_limit <dbl>, explanation_of_na <chr>
    Skim summary statistics
     n obs: 860935 
     n variables: 18 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
              variable missing complete      n min max  empty n_unique
              category       0   860935 860935   0  50 617698     4140
        classification       0   860935 860935   0  50 374913    24677
      ctgov_group_code       0   860935 860935   2   3      0       33
           description       0   860935 860935   0 600 764422    12950
       dispersion_type       0   860935 860935   0  20 720442        4
      dispersion_value  739525   121410 860935   1  15      0    12897
     explanation_of_na       0   860935 860935   0 246 858223      470
                nct_id       0   860935 860935  11  11      0    33631
            param_type       0   860935 860935   0  28    109       10
           param_value       0   860935 860935   1  11      0    21126
                 title       0   860935 860935   2 100      0    19675
                 units       0   860935 860935   0  40    140     2812
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
            variable missing complete      n       mean        sd      p0
                  id       0   860935 860935 2205745.63 255898.02 1758403
     result_group_id       0   860935 860935 2125005.83 251331.54 1699204
         p25     p50       p75    p100     hist
       2e+06 2207203 2424901.5 2676482 ▇▇▇▇▇▇▇▆
     1904425 2121826 2343863   2573695 ▇▇▇▇▇▇▇▆
    
    ── Variable type:numeric ───────────────────────────────────────────────────────────────
                   variable missing complete      n    mean        sd    p0
     dispersion_lower_limit  841170    19765 860935  152.47   4103.32 -36.7
     dispersion_upper_limit  841204    19731 860935 6216.12 253398.44 -10.1
       dispersion_value_num  739550   121385 860935  196.83  21703.02   0  
            param_value_num    2590   858345 860935  209.61   9949.36 -58  
      p25   p50   p75       p100     hist
      8.7 25    43.6   272000    ▇▁▁▁▁▁▁▁
     29   67    82      3e+07    ▇▁▁▁▁▁▁▁
      4.4  9.05 12.31 3395777.02 ▇▁▁▁▁▁▁▁
      2   14    52    2510890    ▇▁▁▁▁▁▁▁
    
    documents table exists
    
    # A tibble: 6 x 6
         id nct_id  document_id  document_type    url         comment         
      <int> <chr>   <chr>        <chr>            <chr>       <chr>           
    1 20547 NCT037… StateData001 Clinical Study … http://www… These are measu…
    2 20548 NCT037… <NA>         Individual Part… https://cl… <NA>            
    3 20549 NCT037… <NA>         Study Protocol   https://cl… <NA>            
    4 20550 NCT037… <NA>         Statistical Ana… https://cl… <NA>            
    5 20551 NCT037… <NA>         Informed Consen… https://cl… <NA>            
    6 20552 NCT037… <NA>         Clinical Study … https://cl… <NA>            
    Skim summary statistics
     n obs: 9874 
     n variables: 6 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
          variable missing complete    n min max empty n_unique
           comment    1015     8859 9874   6 942     0      478
       document_id    1133     8741 9874   1  30     0     1604
     document_type       0     9874 9874   4 177     0      246
            nct_id       0     9874 9874  11  11     0     2347
               url       0     9874 9874  13 885     0     1030
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete    n     mean      sd    p0      p25     p50
           id       0     9874 9874 25556.35 2877.97 20547 23067.25 25557.5
          p75  p100     hist
     28040.75 30685 ▇▇▇▇▇▇▇▇
    
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
     n obs: 2727 
     n variables: 4 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
        variable missing complete    n min max empty n_unique
         heading       0     2727 2727   0  63     3       88
       qualifier       0     2727 2727   0   3     3       88
     subcategory       0     2727 2727   0  68     9      632
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete    n mean     sd p0   p25  p50    p75 p100
           id       0     2727 2727 1364 787.36  1 682.5 1364 2045.5 2727
         hist
     ▇▇▇▇▇▇▇▇
    
    reported_events table exists
    
    # A tibble: 6 x 17
          id nct_id result_group_id ctgov_group_code time_frame event_type
       <int> <chr>            <int> <chr>            <chr>      <chr>     
    1 8.82e6 NCT02…         1708460 E5               NHV: from… other     
    2 8.82e6 NCT02…         1708461 E4               NHV: from… other     
    3 8.82e6 NCT02…         1708462 E3               NHV: from… other     
    4 8.82e6 NCT02…         1708463 E2               NHV: from… other     
    5 8.82e6 NCT02…         1708464 E1               NHV: from… other     
    6 8.82e6 NCT02…         1708454 E11              NHV: from… other     
    # ... with 11 more variables: default_vocab <chr>,
    #   default_assessment <chr>, subjects_affected <int>,
    #   subjects_at_risk <int>, description <chr>, event_count <int>,
    #   organ_system <chr>, adverse_event_term <chr>,
    #   frequency_threshold <int>, vocab <chr>, assessment <chr>
    Skim summary statistics
     n obs: 4233645 
     n variables: 17 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
               variable missing complete       n min max   empty n_unique
     adverse_event_term      11  4233634 4233645   1 100       0   102646
             assessment       0  4233645 4233645   0  25 4196522        3
       ctgov_group_code       0  4233645 4233645   2   3       0       32
     default_assessment       0  4233645 4233645   0  25  301649        3
          default_vocab       0  4233645 4233645   0  20  489419     1390
            description       0  4233645 4233645   0 500 1867511    10049
             event_type       0  4233645 4233645   5   7       0        2
                 nct_id       0  4233645 4233645  11  11       0    33523
           organ_system       0  4233645 4233645   5  67       0       28
             time_frame       0  4233645 4233645   0 500 1383982    14587
                  vocab 4204852    28793 4233645   1  20       0      818
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
                variable missing complete       n          mean         sd
             event_count 2836164  1397481 4233645       5.14         56.81
     frequency_threshold       0  4233645 4233645       1.49          2.23
                      id       0  4233645 4233645       1.1e+07 1265427.37
         result_group_id       0  4233645 4233645 2201646.55     237621.18
       subjects_affected       2  4233643 4233645       4.72         41.43
        subjects_at_risk    1614  4232031 4233645     526.97       1832.19
          p0     p25           p50           p75          p100     hist
           0       0       1             2         22562       ▇▁▁▁▁▁▁▁
           0       0       0             5            20       ▇▃▁▁▁▁▁▁
     8811072 9942920       1.1e+07       1.2e+07       1.3e+07 ▇▇▇▇▇▇▇▆
     1699207   2e+06 2226407       2414334       2573729       ▃▅▅▆▆▆▇▇
           0       0       1             2          9360       ▇▁▁▁▁▁▁▁
           0      19      66           244        124139       ▇▁▁▁▁▁▁▁
    
    brief_summaries table exists
    
    # A tibble: 6 x 3
          id nct_id     description                                           
       <int> <chr>      <chr>                                                 
    1 669392 NCT032908… "\n      Recently published work has suggested that m…
    2 669393 NCT032908… "\n      Prospectively evaluate newly established gui…
    3 669394 NCT032908… "\n      15 healthy males will be studied with PET/CT…
    4 951336 NCT037506… "\n      Age-related cognitive decline has a profound…
    5 669395 NCT032908… "\n      The effectiveness of robotic over convention…
    6 669396 NCT032908… "\n      Nasopharyngeal carcinoma (NPC) is one of the…
    Skim summary statistics
     n obs: 290212 
     n variables: 3 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
        variable missing complete      n min  max empty n_unique
     description       0   290212 290212  15 5540     0   288613
          nct_id       0   290212 290212  11   11     0   290212
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n      mean      sd     p0       p25
           id       0   290212 290212 789794.79 87308.6 636172 715107.75
          p50       p75   p100     hist
     790247.5 863866.25 957714 ▇▇▇▇▇▇▇▃
    
    drop_withdrawals table exists
    
    # A tibble: 6 x 7
          id nct_id  result_group_id ctgov_group_code period  reason     count
       <int> <chr>             <int> <chr>            <chr>   <chr>      <int>
    1 526522 NCT036…         1699205 P1               Overal… Protocol …     1
    2 526523 NCT036…         1699209 P1               Overal… Study was…    95
    3 526524 NCT035…         1699277 P2               Overal… Lost to F…    29
    4 526525 NCT035…         1699278 P1               Overal… Lost to F…    26
    5 526526 NCT035…         1699290 P2               Analyz… Protocol …     1
    6 526527 NCT035…         1699291 P1               Analyz… Protocol …     4
    Skim summary statistics
     n obs: 253674 
     n variables: 7 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
             variable missing complete      n min max empty n_unique
     ctgov_group_code       0   253674 253674   2   3     0       26
               nct_id       0   253674 253674  11  11     0    21434
               period       0   253674 253674   4  40     0     4631
               reason       0   253674 253674   2  40     0    15689
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
            variable missing complete      n       mean        sd      p0
               count       0   253674 253674      57.13  23155.33       0
                  id       0   253674 253674  658682.39  75318.68  526522
     result_group_id       0   253674 253674 2170539.18 238948.07 1699205
           p25       p50        p75          p100     hist
          0          1         4          1.2e+07 ▇▁▁▁▁▁▁▁
     594050.25  659283.5  723258.75   8e+05       ▇▇▇▇▇▇▇▆
      2e+06    2186959   2382654    2573697       ▅▅▆▆▆▆▇▆
    
    id_information table exists
    
    # A tibble: 6 x 4
          id nct_id      id_type      id_value      
       <int> <chr>       <chr>        <chr>         
    1 908403 NCT03724383 org_study_id H18-01441     
    2 908327 NCT03725228 org_study_id tccRenato2018 
    3 908328 NCT03725215 org_study_id S60876        
    4 908329 NCT03725202 org_study_id M16-852       
    5 908330 NCT03725202 secondary_id 2017-003978-13
    6 908331 NCT03725189 org_study_id 00000         
    Skim summary statistics
     n obs: 402761 
     n variables: 4 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
     variable missing complete      n min max empty n_unique
      id_type       0   402761 402761   9  12     0        3
     id_value       0   402761 402761   1  30     0   375017
       nct_id       0   402761 402761  11  11     0   290988
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n       mean        sd     p0   p25
           id       0   402761 402761 1124173.59 122771.96 908327 1e+06
         p50     p75    p100     hist
     1124528 1227032 1367998 ▇▇▇▇▇▇▇▃
    
    countries table exists
    
    # A tibble: 6 x 4
          id nct_id      name      removed
       <int> <chr>       <chr>     <lgl>  
    1 998917 NCT03725228 Brazil    NA     
    2 998918 NCT03725215 Belgium   NA     
    3 998919 NCT03725215 Germany   NA     
    4 998920 NCT03725202 Australia NA     
    5 998921 NCT03725202 Austria   NA     
    6 998922 NCT03725202 Belgium   NA     
    Skim summary statistics
     n obs: 421725 
     n variables: 4 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
     variable missing complete      n min max empty n_unique
         name       0   421725 421725   4  44     0      213
       nct_id       0   421725 421725  11  11     0   261267
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n       mean        sd    p0     p25
           id       0   421725 421725 1236322.42 133657.42 1e+06 1124987
         p50     p75    p100     hist
     1237017 1344685 1505883 ▆▇▇▇▇▇▆▃
    
    ── Variable type:logical ───────────────────────────────────────────────────────────────
     variable missing complete      n mean                  count
      removed  394618    27107 421725    1 NA: 394618, TRU: 27107
    
    study_references table exists
    
    # A tibble: 6 x 5
          id nct_id   pmid    reference_type citation                         
       <int> <chr>    <chr>   <chr>          <chr>                            
    1 817770 NCT0372… 8161995 reference      Goel AR, Kriger J, Bronfman R, L…
    2 819457 NCT0371… 2296123 reference      Stafford RS. Alternative strateg…
    3 819663 NCT0371… <NA>    reference      Agostini P, Knowles N. Autogenic…
    4 817771 NCT0372… 2008387 reference      Rud B, Pedersen NW, Thomsen PB. …
    5 817696 NCT0372… 200822… reference      Unger RZ, Amstutz SP, Seo DH, Hu…
    6 817694 NCT0372… 176521… reference      Rex DK. Dosing considerations in…
    Skim summary statistics
     n obs: 371456 
     n variables: 5 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
           variable missing complete      n min  max empty n_unique
           citation       0   371456 371456   2 5662     0   297510
             nct_id       0   371456 371456  11   11     0    59130
               pmid   21801   349655 371456   1    8     0   276469
     reference_type       0   371456 371456   9   17     0        2
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n  mean        sd     p0       p25   p50
           id       0   371456 371456 1e+06 112148.04 817694 916910.75 1e+06
            p75    p100     hist
     1108009.25 1231784 ▇▇▇▇▇▇▇▃
    
    responsible_parties table exists
    
    # A tibble: 6 x 7
          id nct_id  responsible_part… name   title  organization affiliation 
       <int> <chr>   <chr>             <chr>  <chr>  <chr>        <chr>       
    1 596986 NCT037… Sponsor           <NA>   <NA>   <NA>         <NA>        
    2 597207 NCT037… Sponsor           <NA>   <NA>   <NA>         <NA>        
    3 596937 NCT037… Principal Invest… Gabri… Head … <NA>         Brasilia Un…
    4 596938 NCT037… Principal Invest… Alice… Senio… <NA>         KU Leuven   
    5 596939 NCT037… Sponsor           <NA>   <NA>   <NA>         <NA>        
    6 596940 NCT037… Principal Invest… Kakit… Princ… <NA>         University …
    Skim summary statistics
     n obs: 271676 
     n variables: 7 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
                   variable missing complete      n min max empty n_unique
                affiliation  173157    98519 271676   3 120     0     7138
                       name  145768   125908 271676   1 215     0    67082
                     nct_id       0   271676 271676  11  11     0   271676
               organization  244381    27295 271676   1 206     0    11605
     responsible_party_type   27500   244176 271676   7  22     0        3
                      title  173165    98511 271676   1 254     0    29406
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n      mean       sd    p0       p25
           id       0   271676 271676 741097.46 81930.35 6e+05 670977.75
          p50       p75  p100     hist
     741551.5 810556.25 9e+05 ▇▇▇▇▇▇▇▃
    
    design_outcomes table exists
    
    # A tibble: 6 x 7
           id nct_id  outcome_type measure  time_frame population description 
        <int> <chr>   <chr>        <chr>    <chr>      <chr>      <chr>       
    1 3288799 NCT036… primary      Percent… 16 weeks   <NA>       The effect …
    2 3288800 NCT036… secondary    Effect … 16 weeks   <NA>       Sleep archi…
    3 3288801 NCT036… secondary    Effect … 16 weeks   <NA>       Sleep archi…
    4 3289029 NCT036… secondary    Energy … 10 minutes <NA>       The energy …
    5 3288802 NCT036… secondary    Effect … 16 weeks   <NA>       Sleep archi…
    6 3288803 NCT036… secondary    Effect … 16 weeks   <NA>       Sleep archi…

    Warning in min(characters, na.rm = TRUE): no non-missing arguments to min;
    returning Inf

    Warning in max(characters, na.rm = TRUE): no non-missing arguments to max;
    returning -Inf

``` 
Skim summary statistics
 n obs: 1448570 
 n variables: 7 

── Variable type:character ─────────────────────────────────────────────────────────────
     variable missing complete       n min  max empty n_unique
  description  508613   939957 1448570   1  999     0   788807
      measure       0  1448570 1448570   1  255     0  1075871
       nct_id       0  1448570 1448570  11   11     0   273761
 outcome_type       0  1448570 1448570   5    9     0        3
   population 1448570        0 1448570 Inf -Inf     0        0
   time_frame   54051  1394519 1448570   1  255     0   334840

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete       n       mean        sd      p0        p25
       id       0  1448570 1448570 4052051.64 445749.73 3264688 3672836.25
       p50        p75    p100     hist
 4054890.5 4425591.75 4918707 ▇▇▇▇▇▇▇▃

ipd_information_types table exists

# A tibble: 6 x 3
     id nct_id      name                           
  <int> <chr>       <chr>                          
1 23432 NCT03742999 Study Protocol                 
2 23433 NCT03742999 Statistical Analysis Plan (SAP)
3 23434 NCT03742999 Informed Consent Form (ICF)    
4 23435 NCT03742999 Clinical Study Report (CSR)    
5 23436 NCT03742999 Analytic Code                  
6 23440 NCT03742869 Clinical Study Report (CSR)    
Skim summary statistics
 n obs: 6414 
 n variables: 3 

── Variable type:character ─────────────────────────────────────────────────────────────
 variable missing complete    n min max empty n_unique
     name       0     6414 6414  13  31     0        5
   nct_id       0     6414 6414  11  11     0     2130

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete    n     mean      sd    p0      p25     p50
       id       0     6414 6414 19800.83 2448.65 15909 17760.25 19569.5
      p75  p100     hist
 21491.75 24832 ▇▇▇▇▇▅▃▅

overall_officials table exists

# A tibble: 6 x 5
      id nct_id    role           name            affiliation             
   <int> <chr>     <chr>          <chr>           <chr>                   
1 659996 NCT03725… Principal Inv… Alice Nieuwboe… KU Leuven               
2 659997 NCT03725… Principal Inv… Christian Schl… CAU Kiel                
3 659998 NCT03725… Study Director AbbVie Inc.     AbbVie                  
4 659999 NCT03725… Principal Inv… Ka-Kit Hui, MD  University of Californi…
5 660000 NCT03725… Principal Inv… Michael P Twoh… Utah State University   
6 660001 NCT03725… Principal Inv… David Churchill The Royal Wolverhampton…
Skim summary statistics
 n obs: 302286 
 n variables: 5 

── Variable type:character ─────────────────────────────────────────────────────────────
    variable missing complete      n min max empty n_unique
 affiliation    2411   299875 302286   1 255     0    81680
        name       0   302286 302286   1 121     0   196720
      nct_id       0   302286 302286  11  11     0   236368
        role    1428   300858 302286  11  22     0        4

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n      mean       sd     p0       p25
       id       0   302286 302286 819457.96 90506.58 659996 742066.25
      p50   p75   p100     hist
 819915.5 9e+05 992641 ▇▇▇▇▇▇▇▅

designs table exists

# A tibble: 6 x 14
      id nct_id allocation intervention_mo… observational_m…
   <int> <chr>  <chr>      <chr>            <chr>           
1 640634 NCT03… <NA>       <NA>             Cohort          
2 644860 NCT03… <NA>       <NA>             Other           
3 637958 NCT03… Randomized Parallel Assign… <NA>            
4 637959 NCT03… Randomized Parallel Assign… <NA>            
5 637960 NCT03… Randomized Parallel Assign… <NA>            
6 637961 NCT03… <NA>       Single Group As… <NA>            
# ... with 9 more variables: primary_purpose <chr>,
#   time_perspective <chr>, masking <chr>, masking_description <chr>,
#   intervention_model_description <chr>, subject_masked <lgl>,
#   caregiver_masked <lgl>, investigator_masked <lgl>,
#   outcomes_assessor_masked <lgl>
Skim summary statistics
 n obs: 291016 
 n variables: 14 

── Variable type:character ─────────────────────────────────────────────────────────────
                       variable missing complete      n min  max empty
                     allocation  114427   176589 291016  10   14     0
             intervention_model   66960   224056 291016  19   23     0
 intervention_model_description  276998    14018 291016   1 1000     0
                        masking   65546   225470 291016   6   17     0
            masking_description  283584     7432 291016   1  999     0
                         nct_id       0   291016 291016  11   11     0
            observational_model  238690    52326 291016   5   35     0
                primary_purpose   68116   222900 291016   5   31     0
               time_perspective  235448    55568 291016   5   42     0
 n_unique
        3
        5
    13127
        5
     6342
   291016
       12
       10
       12

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n      mean       sd     p0       p25
       id       0   291016 291016 792016.25 87551.83 637958 717120.75
      p50       p75   p100     hist
 792471.5 866294.25 960392 ▇▇▇▇▇▇▇▃

── Variable type:logical ───────────────────────────────────────────────────────────────
                 variable missing complete      n mean
         caregiver_masked  257173    33843 291016    1
      investigator_masked  232439    58577 291016    1
 outcomes_assessor_masked  241250    49766 291016    1
           subject_masked  219913    71103 291016    1
                  count
 NA: 257173, TRU: 33843
 NA: 232439, TRU: 58577
 NA: 241250, TRU: 49766
 NA: 219913, TRU: 71103

keywords table exists

# A tibble: 6 x 4
       id nct_id      name   downcase_name
    <int> <chr>       <chr>  <chr>        
1 2118642 NCT02068599 OA     oa           
2 2187750 NCT01754948 cough  cough        
3 2397775 NCT00889538 Autism autism       
4 1840489 NCT03708926 PTH    pth          
5 2116934 NCT02076438 c diff c diff       
6 2490364 NCT00519506 PE     pe           
Skim summary statistics
 n obs: 828525 
 n variables: 4 

── Variable type:character ─────────────────────────────────────────────────────────────
      variable missing complete      n min max empty n_unique
 downcase_name       0   828525 828525   1 160     0   191213
          name       0   828525 828525   1 160     0   237738
        nct_id       0   828525 828525  11  11     0   195798

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n      mean        sd      p0     p25
       id       0   828525 828525 2277158.7 250036.22 1837971 2064038
     p50     p75    p100     hist
 2277706 2488320 2767588 ▇▇▇▇▇▇▇▃

participant_flows table exists

# A tibble: 6 x 4
     id nct_id   recruitment_details          pre_assignment_details      
  <int> <chr>    <chr>                        <chr>                       
1 68842 NCT0367… ""                           ""                          
2 68843 NCT0364… ""                           ""                          
3 68846 NCT0358… ""                           ""                          
4 68847 NCT0358… Participants recruited by w… ""                          
5 68848 NCT0357… Subject recruitment occurre… Rivaroxaban was administere…
6 68849 NCT0355… Subject recruitment occurre… 28 subjects were enrolled i…
Skim summary statistics
 n obs: 33740 
 n variables: 4 

── Variable type:character ─────────────────────────────────────────────────────────────
               variable missing complete     n min max empty n_unique
                 nct_id       0    33740 33740  11  11     0    33740
 pre_assignment_details       0    33740 33740   0 350 20492    12882
    recruitment_details       0    33740 33740   0 350 18630    14918

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete     n    mean      sd    p0      p25     p50
       id       0    33740 33740 86093.1 9904.99 68842 77561.75 86113.5
      p75  p100     hist
 94625.25 1e+05 ▇▇▇▇▇▇▇▆

browse_interventions table exists

# A tibble: 6 x 4
       id nct_id      mesh_term           downcase_mesh_term 
    <int> <chr>       <chr>               <chr>              
1 1004009 NCT02768727 Xenon               xenon              
2 1004509 NCT00924209 Gemcitabine         gemcitabine        
3 1004510 NCT00924209 Etoposide phosphate etoposide phosphate
4 1004511 NCT00924209 Cisplatin           cisplatin          
5 1004512 NCT00924209 Bevacizumab         bevacizumab        
6 1004513 NCT00924209 Etoposide           etoposide          
Skim summary statistics
 n obs: 300885 
 n variables: 4 

── Variable type:character ─────────────────────────────────────────────────────────────
           variable missing complete      n min max empty n_unique
 downcase_mesh_term       0   300885 300885   3 161     0     3164
          mesh_term       0   300885 300885   3 161     0     3164
             nct_id       0   300885 300885  11  11     0   129682

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete      n      mean       sd     p0    p25    p50
       id       0   300885 300885 828932.45 90815.85 668402 751548 829524
    p75  p100     hist
 905749 1e+06 ▇▇▇▇▇▇▇▃

facilities table exists

# A tibble: 6 x 8
       id nct_id      status name  city          state     zip   country
    <int> <chr>       <chr>  <chr> <chr>         <chr>     <chr> <chr>  
1 7450630 NCT00501059 ""     <NA>  Thedinghausen ""        27321 Germany
2 7450631 NCT00501059 ""     <NA>  Bishopstown   Cork      ""    Ireland
3 7450632 NCT00501059 ""     <NA>  Kilmallock    Limerick  ""    Ireland
4 7450633 NCT00501059 ""     <NA>  Rathkeale     Limerick  ""    Ireland
5 7450634 NCT00501059 ""     <NA>  Tallow        Waterford ""    Ireland
6 7450635 NCT00501059 ""     <NA>  Enniscorthy   Wexford   ""    Ireland
Skim summary statistics
 n obs: 2076506 
 n variables: 8 

── Variable type:character ─────────────────────────────────────────────────────────────
 variable missing complete       n min max   empty n_unique
     city       0  2076506 2076506   0  63     106    58951
  country       0  2076506 2076506   0  42     106      207
     name  223041  1853465 2076506   1 255       0   453071
   nct_id       0  2076506 2076506  11  11       0   256312
    state       0  2076506 2076506   0  62  835040    10597
   status       0  2076506 2076506   0  23 1685647        9
      zip       0  2076506 2076506   0  30  464028    72004

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete       n       mean        sd      p0        p25
       id       0  2076506 2076506 7128127.64 732584.89 5842260 6547175.25
       p50        p75    p100     hist
 7102151.5 7635743.75 8765638 ▆▇▇▇▇▆▂▃

milestones table exists

# A tibble: 6 x 8
      id nct_id result_group_id ctgov_group_code title period description
   <int> <chr>            <int> <chr>            <chr> <chr>  <chr>      
1 694472 NCT03…         1699205 P1               NOT … Overa… ""         
2 694473 NCT03…         1699205 P1               COMP… Overa… ""         
3 694474 NCT03…         1699205 P1               STAR… Overa… ""         
4 694475 NCT03…         1699209 P1               NOT … Overa… ""         
5 694476 NCT03…         1699209 P1               COMP… Overa… ""         
6 694477 NCT03…         1699209 P1               STAR… Overa… ""         
# ... with 1 more variable: count <int>
Skim summary statistics
 n obs: 338628 
 n variables: 8 

── Variable type:character ─────────────────────────────────────────────────────────────
         variable missing complete      n min max  empty n_unique
 ctgov_group_code       0   338628 338628   2   3      0       32
      description       0   338628 338628   0 182 322504    10112
           nct_id       0   338628 338628  11  11      0    33740
           period       0   338628 338628   1  40      0     7435
            title       0   338628 338628   2  40      0     4480

── Variable type:integer ───────────────────────────────────────────────────────────────
        variable missing complete      n       mean        sd      p0
           count       0   338628 338628     239.46  30260.17       0
              id       0   338628 338628  868551.95  1e+05     694472
 result_group_id       0   338628 338628 2121104.48 243872.21 1699205
        p25       p50        p75          p100     hist
       1         12        49          1.2e+07 ▇▁▁▁▁▁▁▁
  782223.75  869041.5  954659.25 1051207       ▇▇▇▇▇▇▇▆
 1909686    2121377   2325921    2573697       ▇▇▇▇▇▇▇▆

result_agreements table exists

# A tibble: 6 x 4
     id nct_id   pi_employee                   agreement                  
  <int> <chr>    <chr>                         <chr>                      
1 68842 NCT0367… All Principal Investigators … There is NOT an agreement …
2 68843 NCT0364… All Principal Investigators … There is NOT an agreement …
3 68846 NCT0358… Principal Investigators are … There is NOT an agreement …
4 68847 NCT0358… All Principal Investigators … There is NOT an agreement …
5 68848 NCT0357… Principal Investigators are … Conducted in healthy volun…
6 68849 NCT0355… Principal Investigators are … Conducted in healthy volun…
Skim summary statistics
 n obs: 33740 
 n variables: 4 

── Variable type:character ─────────────────────────────────────────────────────────────
    variable missing complete     n min max empty n_unique
   agreement     734    33006 33740  15 500     0     2827
      nct_id       0    33740 33740  11  11     0    33740
 pi_employee       0    33740 33740  82  82     0        2

── Variable type:integer ───────────────────────────────────────────────────────────────
 variable missing complete     n    mean      sd    p0      p25     p50
       id       0    33740 33740 86093.1 9904.99 68842 77561.75 86113.5
      p75  p100     hist
 94625.25 1e+05 ▇▇▇▇▇▇▇▆

calculated_values table exists

# A tibble: 6 x 16
      id nct_id number_of_facil… number_of_nsae_… number_of_sae_s…
   <int> <chr>             <int>            <int>            <int>
1 1.98e7 NCT00…                1               NA               NA
2 1.98e7 NCT00…                1               NA               NA
3 1.98e7 NCT00…                1               NA               NA
4 1.98e7 NCT00…                1               NA               NA
5 1.98e7 NCT00…                1               NA               NA
6 1.98e7 NCT00…                1               NA               NA
# ... with 11 more variables: registered_in_calendar_year <int>,
#   nlm_download_date <date>, actual_duration <int>,
#   were_results_reported <lgl>, months_to_report_results <int>,
#   has_us_facility <lgl>, has_single_facility <lgl>,
#   minimum_age_num <int>, maximum_age_num <int>, minimum_age_unit <chr>,
#   maximum_age_unit <chr>
Skim summary statistics
 n obs: 291016 
 n variables: 16 

── Variable type:character ─────────────────────────────────────────────────────────────
         variable missing complete      n min max empty n_unique
 maximum_age_unit  139410   151606 291016   4   8     0       12
 minimum_age_unit   24666   266350 291016   5   7     0        6
           nct_id       0   291016 291016  11  11     0   291016

── Variable type:Date ──────────────────────────────────────────────────────────────────
          variable missing complete      n        min        max
 nlm_download_date       0   291016 291016 2018-10-31 2018-11-29
     median n_unique
 2018-10-31       16

── Variable type:integer ───────────────────────────────────────────────────────────────
                    variable missing complete      n     mean       sd
             actual_duration  125437   165579 291016    27.52    27.16
                          id       0   291016 291016 2e+07    84009.23
             maximum_age_num  139410   151606 291016    59.4     31.98
             minimum_age_num   24666   266350 291016    20.15    11.13
    months_to_report_results  257362    33654 291016    27.36    25.18
        number_of_facilities   34704   256312 291016     8.1     38.07
     number_of_nsae_subjects  257493    33523 291016   496.77  2014.65
      number_of_sae_subjects  257493    33523 291016    99.68   869.1 
 registered_in_calendar_year       0   291016 291016  2012.1      4.47
    p0   p25   p50   p75  p100     hist
     0     9    20    37   732 ▇▁▁▁▁▁▁▁
 2e+07 2e+07 2e+07 2e+07 2e+07 ▇▇▇▇▇▇▇▇
     1    45    65    75  6569 ▇▁▁▁▁▁▁▁
     1    18    18    18   730 ▇▁▁▁▁▁▁▁
  -200    11    18    36   287 ▁▁▁▇▂▁▁▁
     1     1     1     2  3511 ▇▁▁▁▁▁▁▁
     0     0    53   301 79635 ▇▁▁▁▁▁▁▁
     0     0     4    34 73542 ▇▁▁▁▁▁▁▁
  1999  2009  2013  2016  2018 ▁▁▂▃▃▆▅▇

── Variable type:logical ───────────────────────────────────────────────────────────────
              variable missing complete      n mean
   has_single_facility       0   291016 291016 0.61
       has_us_facility   34718   256298 291016 0.46
 were_results_reported       0   291016 291016 0.12
                               count
     TRU: 177255, FAL: 113761, NA: 0
 FAL: 139483, TRU: 116815, NA: 34718
      FAL: 257276, TRU: 33740, NA: 0

facility_contacts table exists

# A tibble: 6 x 7
       id nct_id  facility_id contact_type name      email       phone    
    <int> <chr>         <int> <chr>        <chr>     <chr>       <chr>    
1 1575970 NCT037…     8278096 primary      Rose Gal… rose.galvi… 234149   
2 1575971 NCT037…     8278098 primary      Elisa Sa… mesanchezb… +34 923 …
3 1575972 NCT037…     8278098 backup       Carmen A… ensayoscli… +3492321…
4 1639779 NCT037…     8435821 primary      Sanjay R… sanjay.raj… 216-844-…
5 1639780 NCT037…     8435823 primary      Chuangzh… stccz@139.… 86-13923…
6 1639781 NCT037…     8435823 backup       Jianzhou… cjzeoeo@gm… 86-13417…
Skim summary statistics
 n obs: 255908 
 n variables: 7 

── Variable type:character ─────────────────────────────────────────────────────────────
     variable missing complete      n min max empty n_unique
 contact_type       0   255908 255908   6   7     0        2
        email   77945   177963 255908   8  85     0   103813
         name    6927   248981 255908   1 108     0   150131
       nct_id       0   255908 255908  11  11     0    64752
        phone   68611   187297 255908   1  37     0    99531

── Variable type:integer ───────────────────────────────────────────────────────────────
    variable missing complete      n       mean        sd      p0
 facility_id       0   255908 255908 6805365.23  1e+06    5842261
          id       0   255908 255908 1410424.42 163326.41 1199886
        p25       p50        p75    p100     hist
   6e+06    6310313.5 7484617.25 8765637 ▇▃▂▁▁▁▁▃
 1288081.75 1372322.5 1447390.25 1763507 ▇▇▇▆▁▁▂▅

baseline_counts table exists

# A tibble: 6 x 7
      id nct_id    result_group_id ctgov_group_code units     scope  count
   <int> <chr>               <int> <chr>            <chr>     <chr>  <int>
1 193306 NCT03670…         1699204 B1               Particip… Overa…   101
2 193307 NCT03648…         1699208 B1               Particip… Overa…     0
3 193316 NCT03585…         1699274 B3               Particip… Overa…    81
4 193317 NCT03585…         1699275 B2               Particip… Overa…    40
5 193318 NCT03585…         1699276 B1               Particip… Overa…    41
6 193319 NCT03582…         1699287 B3               Particip… Overa…    69
Skim summary statistics
 n obs: 94508 
 n variables: 7 

── Variable type:character ─────────────────────────────────────────────────────────────
         variable missing complete     n min max empty n_unique
 ctgov_group_code       0    94508 94508   2   3     0       33
           nct_id       0    94508 94508  11  11     0    33740
            scope       0    94508 94508   7   7     0        1
            units       0    94508 94508   4  28     0       43

── Variable type:integer ───────────────────────────────────────────────────────────────
        variable missing complete     n       mean        sd      p0
           count       0    94508 94508     472.94  16612.39       0
              id       0    94508 94508  241817.09  27842.27  193306
 result_group_id       0    94508 94508 2125591.68 244775.35 1699204
        p25       p50        p75    p100     hist
      17         48       140    2738161 ▇▁▁▁▁▁▁▁
  217873.75  241915.5  265783.25  292403 ▇▇▇▇▇▇▇▆
 1914725.25 2126580.5 2334475.75 2573695 ▇▇▇▇▇▇▇▆

mesh_terms table exists

# A tibble: 6 x 6
      id qualifier tree_number description mesh_term     downcase_mesh_te…
   <int> <chr>     <chr>       <chr>       <chr>         <chr>            
1 117489 A01       A01         <NA>        Body Regions  body regions     
2 117490 A01       A01.111     <NA>        Anatomic Lan… anatomic landmar…
3 117491 A01       A01.236     <NA>        Breast        breast           
4 117492 A01       A01.236.249 <NA>        Mammary Glan… mammary glands, …
5 117493 A01       A01.236.500 <NA>        Nipples       nipples          
6 117494 A01       A01.378     <NA>        Extremities   extremities      
```

    Warning in min(characters, na.rm = TRUE): no non-missing arguments to min;
    returning Inf
    
    Warning in min(characters, na.rm = TRUE): no non-missing arguments to max;
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
           id       0    58744 58744 146860.5 16958.08 117489 132174.75
          p50       p75   p100     hist
     146860.5 161546.25 176232 ▇▇▇▇▇▇▇▇
    
    design_group_interventions table exists
    
    # A tibble: 6 x 4
           id nct_id      design_group_id intervention_id
        <int> <chr>                 <int>           <int>
    1 1411130 NCT03725228         1112406         1116946
    2 1411131 NCT03725228         1112407         1116947
    3 1411132 NCT03725215         1112408         1116948
    4 1411133 NCT03725215         1112409         1116948
    5 1411134 NCT03725215         1112410         1116948
    6 1411135 NCT03725215         1112411         1116948
    Skim summary statistics
     n obs: 623840 
     n variables: 4 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
     variable missing complete      n min max empty n_unique
       nct_id       0   623840 623840  11  11     0   227671
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
            variable missing complete      n       mean        sd      p0
     design_group_id       0   623840 623840 1385648.17 155551.28 1112406
                  id       0   623840 623840 1748670.95 191335.01 1411130
     intervention_id       0   623840 623840 1369563.86 149555.3  1116946
            p25       p50        p75    p100     hist
     1253180.75 1382618.5 1520913    1673801 ▇▇▇▇▇▇▇▅
     1585660.75 1749736.5 1909252.25 2122428 ▇▇▇▇▇▇▇▃
     1244074    1361972.5 1487282    1680168 ▇▇▇▇▇▇▅▃
    
    intervention_other_names table exists
    
    # A tibble: 6 x 4
          id nct_id      intervention_id name                       
       <int> <chr>                 <int> <chr>                      
    1 648347 NCT03725085         1116959 Guaifenesin bi-layer tablet
    2 648348 NCT03725059         1116961 MK-3475                    
    3 648349 NCT03725059         1116961 KEYTRUDA®                  
    4 648350 NCT03725059         1116963 TAXOL®                     
    5 648351 NCT03725059         1116964 ADRIAMYCIN®                
    6 648352 NCT03725059         1116965 ELLENCE®                   
    Skim summary statistics
     n obs: 253561 
     n variables: 4 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
     variable missing complete      n min max empty n_unique
         name       0   253561 253561   1 200     0    94567
       nct_id       0   253561 253561  11  11     0    89225
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
            variable missing complete      n       mean        sd      p0
                  id       0   253561 253561  793144.7   84286.12  648347
     intervention_id       0   253561 253561 1406342.61 150196.18 1116959
         p25     p50     p75    p100     hist
      723277  791740  857794  979040 ▇▇▇▇▇▇▂▃
     1287229 1409722 1525205 1680168 ▅▆▆▇▇▇▆▅
    
    outcome_measurements table exists
    
    # A tibble: 6 x 19
          id nct_id outcome_id result_group_id ctgov_group_code classification
       <int> <chr>       <int>           <int> <chr>            <chr>         
    1 3.81e6 NCT02…     516671         1705321 O1               Preferred sma…
    2 3.81e6 NCT02…     516681         1705366 O1               ""            
    3 3.81e6 NCT02…     516673         1705325 O1               AOM Diagnosed 
    4 3.81e6 NCT02…     516674         1705326 O2               Unknown       
    5 3.81e6 NCT02…     516674         1705327 O1               Unknown       
    6 3.81e6 NCT02…     516674         1705326 O2               Antibiotic no…
    # ... with 13 more variables: category <chr>, title <chr>,
    #   description <chr>, units <chr>, param_type <chr>, param_value <chr>,
    #   param_value_num <dbl>, dispersion_type <chr>, dispersion_value <chr>,
    #   dispersion_value_num <dbl>, dispersion_lower_limit <dbl>,
    #   dispersion_upper_limit <dbl>, explanation_of_na <chr>
    Skim summary statistics
     n obs: 1831950 
     n variables: 19 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
              variable missing complete       n min max   empty n_unique
              category      12  1831938 1831950   0  50 1788131     2811
        classification       0  1831950 1831950   0  50  346795   354197
      ctgov_group_code      12  1831938 1831950   2   3       0       39
           description       0  1831950 1831950   0 999  109163   173425
       dispersion_type       0  1831950 1831950   0  34  877207       23
      dispersion_value 1160281   671669 1831950   1  14       0    93395
     explanation_of_na      12  1831938 1831950   0 250 1797596     5026
                nct_id       0  1831950 1831950  11  11       0    32562
            param_type       0  1831950 1831950   0  28     303       10
           param_value      12  1831938 1831950   1  14       0   105963
                 title       0  1831950 1831950   2 255       0   192040
                 units       0  1831950 1831950   0  40     384    20912
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
            variable missing complete       n       mean        sd      p0
                  id       0  1831950 1831950 4748609.67 543242.56 3800909
          outcome_id       0  1831950 1831950  645226.25  74351.69  514878
     result_group_id      12  1831938 1831950 2131429.9  245612.81 1699206
            p25       p50        p75    p100     hist
     4283204.25 4751204.5 5213653.75 5745516 ▇▇▇▇▇▇▇▆
      581901     646518    708810     779325 ▇▇▇▇▇▇▇▆
     1921674    2136561.5 2343741    2573727 ▇▇▇▇▇▇▇▆
    
    ── Variable type:numeric ───────────────────────────────────────────────────────────────
                   variable missing complete       n        mean          sd
     dispersion_lower_limit 1555627   276323 1831950 1e+05           2.4e+07
     dispersion_upper_limit 1559371   272579 1831950     1.2e+09     3.3e+11
       dispersion_value_num 1160794   671156 1831950 55710.15        1.7e+07
            param_value_num   22676  1809274 1831950 16473.55    1e+07      
                 p0  p25   p50   p75        p100     hist
     -3724434       0.33  4.9  46.7  6e+09       ▇▁▁▁▁▁▁▁
      -172230.54    3.3  22.84 91.6      1.3e+14 ▇▁▁▁▁▁▁▁
       -10966.01    0.75  3.66 17.25     1.3e+10 ▇▁▁▁▁▁▁▁
           -4.1e+08 0     4    31.6      6.4e+09 ▇▁▁▁▁▁▁▁
    
    sponsors table exists
    
    # A tibble: 6 x 5
           id nct_id    agency_class lead_or_collabora… name                  
        <int> <chr>     <chr>        <chr>              <chr>                 
    1 1081897 NCT03090… Other        lead               Ad scientiam          
    2 1002601 NCT03725… Other        lead               Brasilia University H…
    3 1002602 NCT03725… Other        lead               KU Leuven             
    4 1002603 NCT03725… Other        collaborator       University of Kiel    
    5 1002604 NCT03725… Industry     lead               AbbVie                
    6 1002605 NCT03725… Other        lead               University of Califor…
    Skim summary statistics
     n obs: 460784 
     n variables: 5 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
                 variable missing complete      n min max empty n_unique
             agency_class     803   459981 460784   3   8     0        4
     lead_or_collaborator       0   460784 460784   4  12     0        2
                     name       0   460784 460784   2 160     0    53010
                   nct_id       0   460784 460784  11  11     0   291016
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n       mean        sd    p0        p25
           id       0   460784 460784 1246106.21 138433.92 1e+06 1127453.75
           p50        p75    p100     hist
     1246964.5 1363871.25 1509356 ▇▇▇▇▇▇▇▅
    
    conditions table exists
    
    # A tibble: 6 x 4
           id nct_id     name                      downcase_name              
        <int> <chr>      <chr>                     <chr>                      
    1 1620863 NCT032268… Gout                      gout                       
    2 1621767 NCT019208… Glaucoma                  glaucoma                   
    3 1622102 NCT000012… Movement Disorder         movement disorder          
    4 1622103 NCT000013… Immunologic Deficiency S… immunologic deficiency syn…
    5 1622104 NCT000013… Infection                 infection                  
    6 1359941 NCT014461… Human Papilloma Virus In… human papilloma virus infe…
    Skim summary statistics
     n obs: 476700 
     n variables: 4 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
          variable missing complete      n min max empty n_unique
     downcase_name       0   476700 476700   2 160     0    73216
              name       0   476700 476700   2 160     0    74395
            nct_id       0   476700 476700  11  11     0   290202
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n       mean        sd      p0        p25
           id       0   476700 476700 1331816.95 145836.23 1076209 1207430.75
           p50        p75    p100     hist
     1332163.5 1453727.25 1622104 ▇▇▇▇▇▇▇▃
    
    detailed_descriptions table exists
    
    # A tibble: 6 x 3
          id nct_id     description                                           
       <int> <chr>      <chr>                                                 
    1 431173 NCT034294… "\n      Human papillomavirus (HPV) vaccines have pot…
    2 431174 NCT034293… "\n      Progress in psychiatry will require better m…
    3 431175 NCT034293… "\n      An initial four firefighters will be evaluat…
    4 431264 NCT034276… "\n      After enrolled in this study, the patient wa…
    5 431176 NCT034293… "\n      Many adolescents and young adults living wit…
    6 431178 NCT034293… "\n      A hundred patients with the American Society…
    Skim summary statistics
     n obs: 188328 
     n variables: 3 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
        variable missing complete      n min   max empty n_unique
     description       0   188328 188328  13 37641     0   186954
          nct_id       0   188328 188328  11    11     0   188328
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete      n      mean       sd     p0       p25
           id       0   188328 188328 514872.82 56904.79 415251 466127.75
          p50       p75   p100     hist
     515027.5 562980.25 625988 ▇▇▇▇▇▇▇▃
    
    links table exists
    
    # A tibble: 6 x 4
          id nct_id   url                        description                  
       <int> <chr>    <chr>                      <chr>                        
    1 117167 NCT0372… http://cumming.ucalgary.c… Study description            
    2 117169 NCT0372… https://www.crd.york.ac.u… Assessment methods and level…
    3 117170 NCT0372… https://www.crd.york.ac.u… Psycho-educational intervent…
    4 117171 NCT0372… https://www.crd.york.ac.u… Impact of psycho-educational…
    5 117178 NCT0372… http://www.strokesregistr… registry website             
    6 117179 NCT0372… http://www.egyptianstroke… Egyptian Stroke Network -Ale…
    Skim summary statistics
     n obs: 50805 
     n variables: 4 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
        variable missing complete     n min max empty n_unique
     description    5008    45797 50805   1 254     0    19319
          nct_id       0    50805 50805  11  11     0    37960
             url       0    50805 50805  12 853     0    25278
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete     n      mean       sd     p0    p25    p50
           id       0    50805 50805 144991.64 15653.14 117167 131814 145047
        p75   p100     hist
     157956 176227 ▇▇▇▇▇▇▇▃
    
    pending_results table exists
    
    # A tibble: 6 x 5
         id nct_id      event     event_date_description event_date
      <int> <chr>       <chr>     <chr>                  <date>    
    1 44871 NCT03700671 submitted October 10, 2018       2018-10-10
    2 44872 NCT03693950 submitted October 8, 2018        2018-10-08
    3 44873 NCT03685396 submitted September 26, 2018     2018-09-26
    4 44874 NCT03671655 submitted October 16, 2018       2018-10-16
    5 44875 NCT03662334 submitted October 10, 2018       2018-10-10
    6 44876 NCT03657407 submitted September 6, 2018      2018-09-06
    Skim summary statistics
     n obs: 21259 
     n variables: 5 
    
    ── Variable type:character ─────────────────────────────────────────────────────────────
                   variable missing complete     n min max empty n_unique
                      event       0    21259 21259   8  19     0        3
     event_date_description       0    21259 21259   7  18     0     2741
                     nct_id       0    21259 21259  11  11     0     6440
    
    ── Variable type:Date ──────────────────────────────────────────────────────────────────
       variable missing complete     n        min        max     median
     event_date     798    20461 21259 2008-11-20 2018-11-28 2017-06-23
     n_unique
         2740
    
    ── Variable type:integer ───────────────────────────────────────────────────────────────
     variable missing complete     n    mean   sd    p0     p25   p50     p75
           id       0    21259 21259 56446.4 6596 44871 50744.5 56555 62163.5
      p100     hist
     67749 ▇▇▇▇▇▇▇▇

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

<!-- This table contains 21259 outcome analyses from 21259 clinical trials. I'm not sure what each column means...Luckily, this [document](ClinicalTrials.gov Results Data Element...terventional and Observational Studies) contains that information! The different columns list the types of statistical tests used and their parameters. Alot of these parameters are missing. -->

<!-- ### facility investigators -->

<!-- ```{r} -->

<!-- tab <- tables[["facility_investigators"]] -->

<!-- nrow(tab) -->

<!-- head(tab) -->

<!-- apply(tab,2,skimr::n_missing) -->

<!-- ``` -->

<!-- This table contains 21259 facility roles for 21259 clinical trials.  -->

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

<!-- This table contains the counts of outcomes, about 21259, for 6440 clinical trials. This table is completely filled but only has information on a relatively few clinical trials. -->

<!-- ### drop withdrawals -->

<!-- ```{r} -->

<!-- tab <- tables[["drop_withdrawals"]] -->

<!-- nrow(tab) -->

<!-- head(tab) -->

<!-- apply(tab,2,skimr::n_missing) -->

<!-- ``` -->

<!-- This table contains study drop information for 6440 clinical trials. This table is completely filled but only has information on a relatively few clinical trials. -->

<!-- ###baseline measurements -->

<!-- ```{r} -->

<!-- tab <- tables[["baseline_measurements"]] -->

<!-- nrow(tab) -->

<!-- head(tab) -->

<!-- apply(tab,2,skimr::n_missing) -->

<!-- ``` -->

<!-- This table contains study measurement info for 6440 clinical trials. This table is missing some parameter values and only has information on a relatively few clinical trials. -->

<!-- ### outcome analysis groups -->

<!-- ```{r} -->

<!-- tab <- tables[["outcome_analysis_groups"]] -->

<!-- nrow(tab) -->

<!-- head(tab) -->

<!-- apply(tab,2,skimr::n_missing) -->

<!-- ``` -->

<!-- This table contains study outcome analysis information for 6440 clinical trials. This table is completely filled but only has information on a relatively few clinical trials. And I'm not sire what the ctgov_group_code means... -->

<!-- ### baseline counts -->

<!-- ```{r} -->

<!-- tab <- tables[["baseline_counts"]] -->

<!-- nrow(tab) -->

<!-- head(tab) -->

<!-- apply(tab,2,skimr::n_missing) -->

<!-- ``` -->

<!-- This table contains study baseline counts information for 6440 clinical trials. This table is completely filled but only has information on a relatively few clinical trials. I'm also not sure what these columnns mean... -->

<!-- ### browse interventions -->

<!-- ```{r} -->

<!-- tab <- tables[["browse_interventions"]] -->

<!-- nrow(tab) -->

<!-- head(tab) -->

<!-- apply(tab,2,skimr::n_missing) -->

<!-- ``` -->

<!-- This table contains study baseline counts information for 6440 clinical trials. This table is completely filled but only has information on a relatively few clinical trials. I'm also not sure what these columnns mean... -->

<!-- ### browse interventions -->

<!-- ```{r} -->

<!-- tab <- tables[["browse_interventions"]] -->

<!-- nrow(tab) -->

<!-- head(tab) -->

<!-- apply(tab,2,skimr::n_missing) -->

<!-- ``` -->

<!-- This table contains study baseline counts information for 6440 clinical trials. This table is completely filled but only has information on a relatively few clinical trials. I'm also not sure what these columnns mean... -->
