Analysis V2
================
Howard Baek
1/6/2019

## Data Import

### Try joining on lower case MeSH terms

``` r
tagged_mesh_terms_lowercase <- read_excel("2010_tagged_mesh_and_free_text_terms.xlsx",
                                          sheet = 3) %>%
  janitor::clean_names() %>% 
  select(-c(term_type, identifier)) %>% 
  distinct()
```

## Data Prep before LDA

1)  Take out comma and word after comma. (`str_replace`) for both
    `browse_conditions` and `tagged_mesh_terms_lowercase`
2)  `inner_join` both datasets
3)  Run `distinct` on merged dataset. Name it `mesh`

<!-- end list -->

``` r
tagged_mesh_terms_lowercase_replaced <- tagged_mesh_terms_lowercase %>% 
  mutate(term = str_replace_all(term,
                                "(.*),.*",
                                "\\1"))

mesh <- browse_conditions %>% 
  mutate(downcase_mesh_term = str_replace_all(downcase_mesh_term,
                                              "(.*),.*", "\\1")) %>%
  inner_join(tagged_mesh_terms_lowercase_replaced, by = c("downcase_mesh_term" = "term")) %>%
  select(nct_id, downcase_mesh_term) %>% 
  distinct() 
```

## LDA

``` r
mesh_count <- mesh %>% 
  count(nct_id, downcase_mesh_term, sort = TRUE) %>% 
  ungroup()


# Create DocumentTermMatrix in order to put dataset into the LDA algorithm from the topicmodels package
mesh_dtm <- mesh_count %>%
  cast_dtm(nct_id, downcase_mesh_term, n)

# This take a few minutes
mesh_lda <- topicmodels::LDA(mesh_dtm, k = 10, control = list(seed = 1234))

# Use the broom package to mutate beta, the probability of that term being generated from that topic.
mesh_tidy <- tidy(mesh_lda)

# Use top_n() to find top 5 terms within each topic
mesh_top5 <- mesh_tidy %>% 
    group_by(topic) %>% 
    top_n(5, beta) %>% 
    ungroup() %>% 
    arrange(topic, -beta)

# Visualize mesh_top5
mesh_top5 %>%
  mutate(term = reorder(term, beta)) %>% 
  ggplot(aes(term, beta, fill = term)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip() +
  scale_y_continuous(labels = scales::percent_format()) +
  theme(axis.text.x = element_text(angle = 50, hjust = 1)) +
  labs(x = "MeSH",
       y = "Beta (Probability of MeSH being generated from topic)",
       caption = "@jsonbaik") +
  ggtitle("Distribution of MeSH")
```

![](tidytext-analysis-post-v2_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

``` r
mesh_tidy %>% 
  filter(term != "disease") %>% 
  spread(term, beta)
```

    ## # A tibble: 10 x 1,477
    ##    topic `abdominal absc… `abdominal neop… abortion abscess `acalculous cho…
    ##    <int>            <dbl>            <dbl>    <dbl>   <dbl>            <dbl>
    ##  1     1       0.00000230        0.0000207  9.25e-5 7.70e-7    0.00176      
    ##  2     2       0.0000112         0.000155   4.63e-5 2.78e-5    0.000000252  
    ##  3     3       0.0000212         0.000173   6.36e-4 1.25e-5    0.000000284  
    ##  4     4       0.000626          0.0000798  7.15e-4 3.16e-3    0.0000000443 
    ##  5     5       0.0000105         0.000183   9.35e-4 2.73e-5    0.0000000561 
    ##  6     6       0.00000206        0.000101   1.39e-5 3.15e-6    0.00000000209
    ##  7     7       0.00000612        0.0000868  9.25e-4 2.04e-5    0.0000000903 
    ##  8     8       0.0000141         0.0000310  1.29e-4 5.26e-6    0.0000000940 
    ##  9     9       0.0000184         0.000124   3.36e-3 2.92e-7    0.000000272  
    ## 10    10       0.00000120        0.0000680  8.51e-5 1.08e-6    0.0000000103 
    ## # … with 1,471 more variables: `acanthamoeba keratitis` <dbl>, `accessory nerve
    ## #   diseases` <dbl>, achondroplasia <dbl>, `acid-base imbalance` <dbl>,
    ## #   acidosis <dbl>, `acinetobacter infections` <dbl>, `acquired
    ## #   immunodeficiency syndrome` <dbl>, acromegaly <dbl>, `acth syndrome` <dbl>,
    ## #   `acth-secreting pituitary adenoma` <dbl>, `acute chest syndrome` <dbl>,
    ## #   `acute coronary syndrome` <dbl>, `acute kidney injury` <dbl>, `acute lung
    ## #   injury` <dbl>, `acute pain` <dbl>, adamantinoma <dbl>, `adams-stokes
    ## #   syndrome` <dbl>, adenocarcinoma <dbl>, adenoma <dbl>, `adenomatous
    ## #   polyposis coli` <dbl>, `adenomatous polyps` <dbl>, adenosarcoma <dbl>,
    ## #   `adenoviridae infections` <dbl>, `adenovirus infections` <dbl>, `adjustment
    ## #   disorders` <dbl>, `adrenal cortex neoplasms` <dbl>, `adrenal gland
    ## #   neoplasms` <dbl>, `adrenocortical carcinoma` <dbl>, `affective
    ## #   disorders` <dbl>, agammaglobulinemia <dbl>, aggression <dbl>,
    ## #   agoraphobia <dbl>, `aids dementia complex` <dbl>, `aids-associated
    ## #   nephropathy` <dbl>, `aids-related complex` <dbl>, `aids-related
    ## #   opportunistic infections` <dbl>, `airway obstruction` <dbl>, `airway
    ## #   remodeling` <dbl>, `alagille syndrome` <dbl>, albuminuria <dbl>, `alcohol
    ## #   amnestic disorder` <dbl>, `alcohol drinking` <dbl>, `alcohol withdrawal
    ## #   delirium` <dbl>, `alcohol-related disorders` <dbl>, `alcoholic
    ## #   intoxication` <dbl>, alcoholism <dbl>, alkalosis <dbl>, alopecia <dbl>,
    ## #   `alphavirus infections` <dbl>, `altitude sickness` <dbl>, `alveolar bone
    ## #   loss` <dbl>, alveolitis <dbl>, `alzheimer disease` <dbl>, amebiasis <dbl>,
    ## #   ameloblastoma <dbl>, amnesia <dbl>, `amphetamine-related disorders` <dbl>,
    ## #   `amyotrophic lateral sclerosis` <dbl>, anaphylaxis <dbl>, anaplasia <dbl>,
    ## #   anaplasmosis <dbl>, ancylostomiasis <dbl>, `andersen syndrome` <dbl>,
    ## #   anemia <dbl>, `anemia, refractory` <dbl>, aneurysm <dbl>, angina <dbl>,
    ## #   `angina pectoris` <dbl>, angioedema <dbl>, angioedemas <dbl>,
    ## #   angiomatosis <dbl>, anisakiasis <dbl>, ankylosis <dbl>, `anorexia
    ## #   nervosa` <dbl>, `anterior wall myocardial infarction` <dbl>,
    ## #   anthracosis <dbl>, anthrax <dbl>, `anti-glomerular basement membrane
    ## #   disease` <dbl>, `anti-neutrophil cytoplasmic antibody-associated
    ## #   vasculitis` <dbl>, `antiphospholipid syndrome` <dbl>, `antisocial
    ## #   personality disorder` <dbl>, anuria <dbl>, `anus neoplasms` <dbl>,
    ## #   anxiety <dbl>, `anxiety disorders` <dbl>, `aortic aneurysm` <dbl>, `aortic
    ## #   arch syndromes` <dbl>, `aortic coarctation` <dbl>, `aortic diseases` <dbl>,
    ## #   `aortic rupture` <dbl>, `aortic stenosis` <dbl>, `aortic valve
    ## #   insufficiency` <dbl>, `aortic valve stenosis` <dbl>, aortitis <dbl>,
    ## #   aphonia <dbl>, apnea <dbl>, `appendiceal neoplasms` <dbl>,
    ## #   appendicitis <dbl>, apudoma <dbl>, `arbovirus infections` <dbl>, …

Compare to Ground Truth

``` r
browse_conditions %>% 
  mutate(downcase_mesh_term = str_replace_all(downcase_mesh_term,
                                              "(.*),.*", "\\1")) %>%
  inner_join(tagged_mesh_terms_lowercase_replaced, by = c("downcase_mesh_term" = "term")) %>% 
  distinct()
```

    ## # A tibble: 525,050 x 5
    ##        id nct_id      mesh_term downcase_mesh_term clinical_domain    
    ##     <int> <chr>       <chr>     <chr>              <chr>              
    ##  1 584423 NCT04193020 Uveitis   uveitis            infectious_diseases
    ##  2 591109 NCT04140110 Stroke    stroke             cardiology         
    ##  3 591884 NCT04133506 Eczema    eczema             immuno_rheumatology
    ##  4 592227 NCT04130828 Anemia    anemia             oncology           
    ##  5 598668 NCT04079998 Burns     burns              pulmonary_medicine 
    ##  6 599780 NCT04071587 Stroke    stroke             cardiology         
    ##  7 600040 NCT04069546 Stroke    stroke             cardiology         
    ##  8 601157 NCT04060823 Asthma    asthma             immuno_rheumatology
    ##  9 601157 NCT04060823 Asthma    asthma             pulmonary_medicine 
    ## 10 601157 NCT04060823 Asthma    asthma             otolaryngology     
    ## # … with 525,040 more rows

# TODO: Compare ground truth to LDA algorithm.

  - I need to find a way to calculate Betas in of each mesh term in each
    clinical domain
