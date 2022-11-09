## Pre-Processing

First few rows of the raw data are as follows:

    ## # A tibble: 10 × 7
    ##    country     code       year   p90   p10 population continent
    ##    <chr>       <chr>     <dbl> <dbl> <dbl>      <dbl> <chr>    
    ##  1 Abkhazia    OWID_ABK   2015    NA    NA         NA Asia     
    ##  2 Afghanistan AFG      -10000    NA    NA      14737 <NA>     
    ##  3 Afghanistan AFG       -9000    NA    NA      20405 <NA>     
    ##  4 Afghanistan AFG       -8000    NA    NA      28253 <NA>     
    ##  5 Afghanistan AFG       -7000    NA    NA      39120 <NA>     
    ##  6 Afghanistan AFG       -6000    NA    NA      54166 <NA>     
    ##  7 Afghanistan AFG       -5000    NA    NA      74999 <NA>     
    ##  8 Afghanistan AFG       -4000    NA    NA     306250 <NA>     
    ##  9 Afghanistan AFG       -3000    NA    NA     537500 <NA>     
    ## 10 Afghanistan AFG       -2000    NA    NA     768751 <NA>

### Description on Data Measures

-   `country`: the name of the country
-   `code`: country code (3 capital letters)
-   `year`: the year in which the income was recorded
-   `p90`: 90th income percentile
-   `p10`: 10th income percentile
-   `population`: estimated population of the country
-   `continent`: the continent to which the country belongs

First few rows of the cleaned data are as follows:

    ## # A tibble: 10 × 7
    ## # Groups:   country [1]
    ##    country code   year   p90   p10 population continent
    ##    <chr>   <chr> <dbl> <dbl> <dbl>      <dbl> <chr>    
    ##  1 Albania ALB    1996  13.2  3.7     3271336 Europe   
    ##  2 Albania ALB    2002  14.0  3.51    3123554 Europe   
    ##  3 Albania ALB    2005  15.4  3.99    3032636 Europe   
    ##  4 Albania ALB    2008  16.4  4.6     2951690 Europe   
    ##  5 Albania ALB    2012  16    4.41    2892191 Europe   
    ##  6 Albania ALB    2014  19.1  3.68    2884100 Europe   
    ##  7 Albania ALB    2015  22.1  4.8     2882482 Europe   
    ##  8 Albania ALB    2016  23.2  4.7     2881064 Europe   
    ##  9 Albania ALB    2017  22.7  4.91    2879361 Europe   
    ## 10 Albania ALB    2018  23.3  5.47    2877019 Europe

One of our final visualizations will look something like this. Each
point is a data point of a country in a specific year. Since there are
so many countries, it is hard to distinguish each data point. We will
use Shiny to give users to get the information they want.

![](eda_files/figure-markdown_github/unnamed-chunk-4-1.png)

### Further Analysis

1.  Income inequality based on the continents.
2.  Any specific countries? (US, Canada, China, Europe, etc)
3.  Any other interesting data to consider?

-   [gdp per capita vs income
    inequality](https://ourworldindata.org/grapher/gdp-per-capita-vs-economic-inequality)
-   [income
    inequality](https://ourworldindata.org/grapher/economic-inequality-gini-index)
-   [share of population living in extreme
    poverty](https://ourworldindata.org/explorers/poverty-explorer)
