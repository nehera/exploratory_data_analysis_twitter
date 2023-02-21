# Twitter Exploratory Data Analysis: Aquatic Invasive Species as a Case Study

This repository includes code for performing an Exploratory Data Analysis (EDA) of Twitter data with Aquatic Invasive Species (AIS) as a case study. The motivation for this repository is to share my learnings from my summer as a Human in the Data fellow in 2022 during which I learned with researchers at the University of Minnesota (UMN) to evaluate Twitter as a potential data source for understanding AIS in the United States and personally better navigate the immense and growing amounts of digital data. 

## About the Fellowship

["MnDRIVE—Minnesota’s Discovery, Research, and InnoVation Economy—is a partnership between the University of Minnesota and the State of Minnesota that aligns areas of research strength with the state’s key and emerging industries to address grand challenges."](https://research.umn.edu/about-us/initiatives/mndrive).

["The MnDRIVE Human in the Data Fellowship Program is a graduate student summer fellowship of $7,000 to fund research on the humanistic implications of data and its use in one of five MnDRIVE areas of concentration: robotics, global food, environment, brain conditions, or cancer clinical trials."](https://ias.umn.edu/opportunities/human-data-mndrive-fellowship-program). The program is co-sponsored by the UMN's Institute for Advanced Study, Digital Arts, Sciences, & Humanities Program, and Research Computing. 

A biostatistics PhD student at the UMN at the time of writing this README, I am grateful for the opportunity I had to explore humanistic themes and aggregate/ develop this repository of R code that might prove useful to another graduate student/ researcher.

## Step 0. Getting Started

If you are a graduate student/ researcher afilliated with an academic institution, good news! You can get academic access to the Twitter API at no-cost. [Apply for academic access to the Twitter API here once you have a well-defined research objective](https://developer.twitter.com/en/products/twitter-api/academic-research). [To get you started, here's my application](https://docs.google.com/document/d/1akumrmMueqfQ5HurrFHizGhQx-VW9hj21zKLKv6fjPo/edit?usp=sharing) with all relevant information include. My project proposal was ambitious in hindsight... but putting my thoughts to paper shaped my eventual project products (this repository as one of them). 

Recommendation: Submit earlier rather than later. Twitter took about a month to get back to me and requested a few additional details. In the meantime, [read the documentation for the R package 'academictwitteR'](https://cran.r-project.org/web/packages/academictwitteR/academictwitteR.pdf) and work with the free access of the Twitter API which, at the time of writing, offers the last 7 days of tweets, to adopt this/ other code to your specific use case.

In a nutshell, here's my why for exploring AIS-related conversation on Twitter:

* Thriving aquatic ecosystems are critical to the MN economy: In MN in 2020, leisure and hospitality generated \$11.7 billion in gross sales, \$731 million in state sales tax, and 205 thousand jobs. Fishing licenses generated the most revenue of all sources for the MN Department of Natural Resources Game and Fish Fund at $33.9 million, supporting conservation officers, boat ramps/accesses, etc. These data make it clear that thriving aquatic ecosystems are essential to a large portion of the MN economy and its conservation services. 
* Internet services impact human behavior and social ecological systems (SESs): 
- Internet services such as web search engines (e.g. Google) and social networking sites (e.g. Twitter) facilitate information flow, the transfer of information from one actor to another, and thus impact human behavior and SESs (1,2)
- Adaptive governance is an emergent phenomenon by which state and non-state actors collaborate across multiple levels in an iterative process (4). 
- Interest in Aquatic Invasive Species (AIS) in MN exists online: ![Figure 1. AIS Google Trends. 100 is the most popular location as a fraction of total searches in that location, 50 indicates a location which is half as popular, 0 indicates a location without enough data. Queries included “aquatic invasive species” from 1/1/04 - 3/4/22. Data source: Google Trends (https://www.google.com/trends).](images/AIS_Search_Trends.png){width=100%}
* Twitter is a promising data source for solving public health problems: - [Twitter has been used to detect foodborne illness](https://piazza.com/class_profile/get_resource/i3x8bwl9nsy21i/i7yt0wnb4r829o)

### Steps to Data Analysis

1. Ask
2. Prepare
3. Process
4. Analyze
6. Share
7. Act

[Source: Google Data Analytics Certificate](https://grow.google/certificates/data-analytics/)

### Exploratory Data Analysis is a specific type of data analysis

Exploratory Data Analysis (EDA) is a structured approach for understanding your data that can be used for research question and hypothesis development. 

Why Exploratory Data Analysis? Get insights to make better decisions. 

Sub-objectives include:

- Identify trends across time.
- Identify trends across space. 
- Identify and deal with outliers.
- Uncover patterns related to the response (a.k.a. target or dependent) variable of interest.
- Create research questions to explore or hypotheses to test.
- Identify possible new data sources.

Remark: Time and space are addressed separately to reduce the complexity associated with programming/ interpretation of results.

#### Steps to EDA

0. Get your data
1. Understand your variables
2. Tidy your data - https://vita.had.co.nz/papers/tidy-data.pdf
3. Identify trends across time, identify and deal with outliers.
4. Identify trends across space, identify and deal with outliers.
5. Identify correlated variables
6. Uncover patterns related to the response e.g. lake infestation (hopefully)
7. Create research questions to explore or hypotheses to test, and possibly identify additional data sources.

Repeat as needed!
### Mental models for getting started

EDA might sound intimidating to a data analysis newcomer. It certainly did to me. Thus, below are mental models that have helped me immensely.

- Wabi Sabi: Japanese world-view centered on the acceptance of transience and imperfection.
- Black Box Thinking: Focus on the data and your purpose throughout your project to avoid chasing shiny solutions.

[Source: Naked Data Science Podcast](https://open.spotify.com/show/4Sacw5UzY7utm6coTEHS0h?si=6e5ec050f22a4b85)


## Step 1. Determine Keywords

For this project, plant and animal species names were web scraped from the Minnesota Department of Natural Resources (https://www.dnr.state.mn.us/invasives/ais/id.html) July 18, 2022 and put into the [Google Sheet AIS and Twitter Keywords](https://docs.google.com/spreadsheets/d/15axVoP4eLejqTTRj-a15YU3v6AkJv3Y-n5AEQRievEU/edit?usp=sharing). “Aquatic Invasive Species” and “Aquatic Nuisance Species” were added manually to reflect conversation of broader categories. 

In R, these keywords were pulled from Google Sheets and then converted into their corresponding hashtag e.g. #AquaticInvasiveSpecies. These hashtags were used as input for the queries described below.


1. Assessing prevalence of AIS-related hashtags on Twitter
2. Exploring secondary questions

- What proportion of #AIS or #Goldfish mentions are actually Aquatic Invasive Species related?
- What proportion of AIS tweets include geo-tags, and might these tweets' locations relate to lake infestation risk?
- Who is driving the AIS conversation? Are there specific types of accounts that are more influential than others? 

## Aim 1. Assess the prevalence of AIS conversation on Twitter

## What proportion of #AIS or #Goldfish mentions are actually Aquatic Invasive Species related, and what are the implications of this? * What I wish I focused on earlier

## What proportion of AIS tweets include geo-tags and where are these tweets posted? Might these be mapped to lake infestation risk?

## Who is driving the AIS conversation? Are there specific types of accounts that are more influential than others? 

## Conclusions

- There is limited AIS data readily available on Twitter
- The body of tweets may investigated as a method for extracting AIS-related tweets.
- Certain accounts contribute most substantially to the AIS conversation on Twitter.

## Next Steps

- Labeling tweets for development of a natural language model might be useful.
- Survey of stakeholders may aid in identification of different data sources for evaluation.
- Personally, I may incorporate social media data into my future research.