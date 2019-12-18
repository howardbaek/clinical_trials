Clinical trials, phases, and their types
================

## Introduction

This notebook outlines the exploration of the processed data from this
[notebook](cleaning_study_eligibility_and_phases.md)

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

## Load data

``` r
data <- read_csv("study_phase_age_eligibility.csv")
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
data <- data %>% 
  mutate(
    clean_phase = ifelse(is.na(clean_phase),"no_phase_given",clean_phase)
    )
data$clean_phase <- factor(data$clean_phase,levels=c("Early_1","1","1_2","2","2_3","3","4","no_phase_given"))
```

## Frequency of trials in different phases

I previously looked at this but I want to put the data here too

``` r
data %>% 
  ggplot() +
  geom_bar(aes(clean_phase,color=clean_phase),fill="gray") +
  coord_flip() +
  ylab("Number of clinical trials") +
  xlab("") +
  theme(
    legend.position = "none"
  )
```

![](study_phase_age_eligibility_ntbk_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

## Are trials given for many phases or just one?

``` r
tmp <- data %>% 
  distinct(nct_id,clean_phase) %>% 
  count(nct_id) %>% 
  arrange(desc(n))

tmp %>% group_by(n) %>% count()
```

    ## # A tibble: 1 x 2
    ## # Groups:   n [1]
    ##       n     nn
    ##   <int>  <int>
    ## 1     1 294117

Nope. Trials are only in one phase or phase combo or not given.

## What is the eligibility age distribution for trials?

``` r
data %>% 
  filter(is.na(clean_phase))
```

    ## # A tibble: 0 x 6
    ## # ... with 6 variables: nct_id <chr>, clean_phase <fct>,
    ## #   minimum_master_age <int>, maximum_master_age <int>,
    ## #   pediatric_trial <lgl>, pediatric_inclusive <lgl>

``` r
data_eligibility_age_gathered <- data %>% 
  gather(eligibility_age_type,eligibility_age,-nct_id,-clean_phase,-pediatric_trial,-pediatric_inclusive) 

data_eligibility_age_gathered %>% 
  group_by(clean_phase,eligibility_age_type) %>% 
  count(eligibility_age) %>% 
  ggplot() +
  geom_histogram(aes(eligibility_age,n,
               fill=eligibility_age_type,
               group=eligibility_age_type),
           stat="identity",position="dodge") +
  scale_y_log10() +
  facet_grid(clean_phase~.) +
  ylab("Number of trials\nlog10 scale") +
  xlab("Eligibility age") +
  theme_bw()
```

    ## Warning: Ignoring unknown parameters: binwidth, bins, pad

    ## Warning: Removed 16 rows containing missing values (geom_bar).

![](study_phase_age_eligibility_ntbk_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

This may not be the easiest graph to look at, but it gives some good
insight.

1)  The eligibility is roughly the same for trials without a phase and
    with a phase.

2)  The spike (dark gray line) for the minimum age is expected - it’s
    the legal age for consent to trials will allow them to enroll more
    easily.

3)  where trials begin eligibility and end eligibility makes sense -
    there’s more blue bars early on, red bars later on, and vice versa.

I think there’s subtle changes in bar height across the phases, so I
think I’ll want to look more closely at this.

## Is the minumum age significantly lower across phases?

I’m not interested in the maximum age, just whether younger patients are
eligible for trials for which they have historically not been.

``` r
df <- data_eligibility_age_gathered %>% 
  filter(eligibility_age_type=="minimum_master_age") %>% 
  select(-eligibility_age_type,nct_id) 

df %>% 
  ggplot() +
  geom_density(aes(
    eligibility_age,
    group=factor(clean_phase),
    fill=clean_phase),
    na.rm = F,alpha=.2) +
  geom_vline(xintercept=18,
             color="red",
             size=.2) +
  scale_fill_brewer(palette="Dark2") +
  facet_grid(clean_phase~.) +
  coord_flip()
```

    ## Warning: Removed 24901 rows containing non-finite values (stat_density).

![](study_phase_age_eligibility_ntbk_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

``` r
g <- glm(eligibility_age ~ clean_phase - 1,
      data=df,
      family="quasipoisson")

g$coefficients[order(g$coefficients)]
```

    ##            clean_phase1_2              clean_phase1 
    ##                  2.933721                  2.945740 
    ##              clean_phase3            clean_phase2_3 
    ##                  2.952901                  2.962898 
    ##              clean_phase2        clean_phaseEarly_1 
    ##                  2.970488                  2.999266 
    ##              clean_phase4 clean_phaseno_phase_given 
    ##                  3.006053                  3.014538

``` r
a <- aov(g)

summary(a)
```

    ##                 Df    Sum Sq  Mean Sq F value Pr(>F)    
    ## clean_phase      8 106630036 13328754  113162 <2e-16 ***
    ## Residuals   269208  31708622      118                   
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 24901 observations deleted due to missingness

``` r
thd <- TukeyHSD(a)

thd_df <- data.frame(thd$clean_phase)
thd_df$phase_combo <- rownames(thd_df)

thd_df %>% 
  filter(p.adj<0.05) %>% 
  ggplot(aes(phase_combo)) + 
  geom_point(aes(phase_combo,diff)) +
  geom_errorbar(aes(x=forcats::fct_reorder(phase_combo,diff),ymin=lwr,ymax=upr)) +
  geom_hline(yintercept=0,color="black") +
  coord_flip()
```

![](study_phase_age_eligibility_ntbk_files/figure-gfm/unnamed-chunk-6-2.png)<!-- -->

Seems like yes by the difference in peak heights on the graph. I logged
the ages so the differences could come out more and I flipped the graph
for easier comparison of peak heights. The red line indicates 18 years
of age and is just a indicator for me-it lines up perfectly with the
peak density.

The glm tells me about how the age distributions differ across the
phases. I use family=“quasipoisson” because the response is made of
integers and I think the dispersion is different across the phases. I
took out the intercept so I could see coefficients for all the phases
(leaving in the intercept doesn’t make much sense).

I also show the coefficient values for easier interpretation.

I also perform an anova on the model and do a tukey test to see which
distributions are different from particular phases.

The first density plot shows pretty much only that the density at 18
years of age is different, meaning the minimum eligible age distribution
does change but not exactly how. The GLM quantifies the association of
the phases to the minimum eligibility age giving the first indication
that lower phases are associated to lower minimum ages. But is that
significant and between which phases? The anova on the model says,
overall, yes. The tukey test says that particular phase distributions
are significantly different. On the plot, those to the right of zero are
saying the age distribution is significantly larger (p.adj\<0.05) in the
second phase compared to the first. Those to the left are the opposite -
the age distribution is significantly younger compared to the first.
These may not contain 0, but they still aren’t \>1 or \< -1
:/

## Disproportionate number of adult or pediatric or pediatric inclusive clinical trials at different phases?

``` r
tmp <- data[complete.cases(data),]
is = unique(tmp$clean_phase)
fishers <- list()
for(i in is){
  inphase <- factor(tmp$clean_phase==i,c(T,F))
  pedtrial <- factor(tmp$pediatric_trial,c(T,F))
  tab <- table(pedtrial,inphase,
             useNA = "no",dnn =list("Pediatric trial",paste0("Phase_",i)))
  print(tab)
  fishers[[i]] <- fisher.test(tab,alternative="less",simulate.p.value = T,B=1e5)
}
```

    ##                Phase_1_2
    ## Pediatric trial   TRUE  FALSE
    ##           TRUE     313  13088
    ##           FALSE   4331 127356
    ##                Phase_no_phase_given
    ## Pediatric trial  TRUE FALSE
    ##           TRUE   7319  6082
    ##           FALSE 65130 66557
    ##                Phase_3
    ## Pediatric trial   TRUE  FALSE
    ##           TRUE    2058  11343
    ##           FALSE  11360 120327
    ##                Phase_2
    ## Pediatric trial   TRUE  FALSE
    ##           TRUE    1323  12078
    ##           FALSE  17160 114527
    ##                Phase_1
    ## Pediatric trial   TRUE  FALSE
    ##           TRUE     600  12801
    ##           FALSE  17474 114213
    ##                Phase_4
    ## Pediatric trial   TRUE  FALSE
    ##           TRUE    1433  11968
    ##           FALSE  12242 119445
    ##                Phase_2_3
    ## Pediatric trial   TRUE  FALSE
    ##           TRUE     266  13135
    ##           FALSE   2584 129103
    ##                Phase_Early_1
    ## Pediatric trial   TRUE  FALSE
    ##           TRUE      89  13312
    ##           FALSE   1406 130281

``` r
fisher_df <- sapply(fishers,function(x){
  cis <- x$conf.int
  e <- x$estimate
  c(cis[1],e,cis[2],x$p.value)
}) %>% data.frame

colnames(fisher_df) <- is
rownames(fisher_df) <- c("lwr","estimate","upr","p.value")
to_viz <- fisher_df %>% 
  t %>% 
  as.data.frame %>% 
  mutate(phase = is) 

to_viz$phase <- factor(to_viz$phase,
                       levels=c("Early_1","1","1_2","2","2_3","3","4"))
to_viz
```

    ##   lwr  estimate       upr       p.value   phase
    ## 1   0 0.7032396 0.7758827  2.765181e-10     1_2
    ## 2   0 1.2297483 1.2673536  1.000000e+00    <NA>
    ## 3   0 1.9217938 2.0058417  1.000000e+00       3
    ## 4   0 0.7310684 0.7683591  2.486293e-27       2
    ## 5   0 0.3063573 0.3287306 1.171088e-237       1
    ## 6   0 1.1682363 1.2266876  9.999999e-01       4
    ## 7   0 1.0118025 1.1272625  5.875259e-01     2_3
    ## 8   0 0.6195040 0.7438606  1.918243e-06 Early_1

``` r
to_viz %>% 
  mutate(significant = p.value<0.05) %>% 
  ggplot() +
  geom_point(aes(phase,estimate,color=significant)) +
  geom_errorbar(stat="identity",aes(phase,ymin=lwr,ymax=upr,color=significant),width=.2) + 
  ylab("Chi squared statistic") +
  xlab("Phase") +
  theme_classic(base_size=16)
```

![](study_phase_age_eligibility_ntbk_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

Seems like I can’t interpret much from this…

## Interpretation and what to do moving forward

This mostly makes sense to me, but I’m sure there’s other factors at
play that give more intuition to these statistics.

This doesn’t give me much indication of clinical trials including
pediatric patients in earlier phases and aren’t later phases.

I think at this point I may want to either better define or scope my
question to bin pediatric patients or move on to other investigations.
Stay tuned.
