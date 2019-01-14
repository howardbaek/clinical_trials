Analysis V2
================
Jason Baik
1/6/2019

Data Import
-----------

### Try joining on lower case MeSH terms

``` r
tagged_mesh_terms_lowercase <- read_excel("2010_tagged_mesh_and_free_text_terms.xlsx",
                                          sheet = 3) %>%
  janitor::clean_names() %>% 
  select(-c(term_type, identifier)) %>% 
  distinct()
```

Data Prep before LDA
--------------------

1.  Take out comma and word after comma. (`str_replace`) for both `browse_conditions` and `tagged_mesh_terms_lowercase`
2.  `inner_join` both datasets
3.  Run `distinct` on merged dataset

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

LDA
---

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
  facet_wrap(~ topic, scales = "free", nrow = 3) +
  coord_flip() +
  scale_y_continuous(labels = scales::percent_format()) +
  theme(axis.text.x = element_text(angle = 50, hjust = 1)) +
  labs(x = "MeSH",
       y = "Beta (Probability of MeSH being generated from topic)",
       caption = "@jsonbaik") +
  ggtitle("Distribution of MeSH")
```

![](tidytext-analysis-post-v2_files/figure-markdown_github/unnamed-chunk-4-1.png)

Now comes the fun part: comparison between LDA's categorization of topics and Duke researchers' categorization (the ground truth)

Create a function and `map` over it.

``` r
mesh_top5 %>% 
  filter(topic == 1) 
```

    ## # A tibble: 5 x 3
    ##   topic term                    beta
    ##   <int> <chr>                  <dbl>
    ## 1     1 osteoarthritis        0.0634
    ## 2     1 infarction            0.0605
    ## 3     1 myocardial infarction 0.0537
    ## 4     1 depressive disorder   0.0524
    ## 5     1 depression            0.0522

``` r
tagged_mesh_terms_lowercase_replaced %>% 
  count(clinical_domain, term, sort = TRUE) %>% 
  group_by(clinical_domain) %>% 
  mutate(ground_truth_beta_percentage = 100 * (n / sum(n))) %>% 
  select(-n) %>% 
  # Group by clinical_domain and then arrange by descending order of ground_truth_beta_percentage
  arrange(clinical_domain, -ground_truth_beta_percentage)
```

    ## # A tibble: 4,263 x 3
    ## # Groups:   clinical_domain [10]
    ##    clinical_domain term             ground_truth_beta_percentage
    ##    <chr>           <chr>                                   <dbl>
    ##  1 cardiology      tachycardia                             2.02 
    ##  2 cardiology      echocardiography                        1.21 
    ##  3 cardiology      aneurysm                                1.01 
    ##  4 cardiology      cardiomyopathy                          1.01 
    ##  5 cardiology      heart failure                           0.806
    ##  6 cardiology      angioplasty                             0.605
    ##  7 cardiology      aortic aneurysm                         0.605
    ##  8 cardiology      aortic stenosis                         0.605
    ##  9 cardiology      atrial function                         0.605
    ## 10 cardiology      cardiac output                          0.605
    ## # … with 4,253 more rows
