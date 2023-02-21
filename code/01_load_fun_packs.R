#### ---- Load Project Packages
if (("pacman" %in% installed.packages()[,"Package"]) == FALSE) { install.packages("pacman") }
pacman::p_load(tidyverse, # make tidy data faster
               lubridate,
               academictwitteR, # for accessing twitter api
               tokenizers, # https://cran.r-project.org/web/packages/tokenizers/vignettes/introduction-to-tokenizers.html
               tidytext, 
               stopwords, # for stop word lists
               scales, # for label_percent
               gridExtra # print plots side-by-side
               ) 

