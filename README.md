# Twitter Exploratory Data Analysis: Aquatic Invasive Species as a Case Study

This repository includes code for performing an Exploratory Data Analysis (EDA) of Twitter data with Aquatic Invasive Species (AIS) as a case study. The motivation for this repository is to share my learnings from my summer as a Human in the Data fellow in 2022 during which I learned with researchers at the University of Minnesota (UMN) to evaluate Twitter as a potential data source for understanding AIS management in the United States and personally better navigate the immense and growing amounts of digital data. 

## Step 0. Getting Started

If you are a graduate student/ researcher afilliated with an academic institution, good news! You can get academic access to the Twitter API at no-cost. [Apply for academic access to the Twitter API here once you have a well-defined research objective](https://developer.twitter.com/en/products/twitter-api/academic-research). [To get you started, here's my application](https://docs.google.com/document/d/1akumrmMueqfQ5HurrFHizGhQx-VW9hj21zKLKv6fjPo/edit?usp=sharing) with all relevant information included. My project proposal was ambitious in hindsight... but putting my thoughts to paper shaped my eventual project products (this repository as one of them). 

Recommendation: Submit earlier rather than later. Twitter took about a month to get back to me and requested additional details. In the meantime, [read the documentation for the R package 'academictwitteR'](https://cran.r-project.org/web/packages/academictwitteR/academictwitteR.pdf) and work with the free access of the Twitter API which offers the last 7 days of tweets to start adopting this/ other code to your specific use case.

To develop your research objective, start with why. Below's my why for exploring AIS-related conversation on Twitter:

* Thriving aquatic ecosystems are critical to the MN economy: According to the MN DNR, in 2020, leisure and hospitality generated \$11.7 billion in gross sales, \$731 million in state sales tax, and 205 thousand jobs. Furthermore, fishing licenses generated the most revenue of all sources for the MN Department of Natural Resources Game and Fish Fund at $33.9 million, supporting conservation officers, boat ramps/accesses, etc. These data make it clear that thriving aquatic ecosystems are essential to a large portion of the MN economy.
* Internet services impact human behavior and social ecological systems (SESs): Internet services such as web search engines (e.g. Google) and social networking sites (e.g. Twitter) facilitate information flow, the transfer of information from one actor to another, and thus impact human behavior and SESs. Phenonemenons such as adaptive governance, collaboration of state and non-state actors across multiple levels in an iterative process might be understood through the analysis of digital data.
* Aquatic Invasive Species (AIS) interest exists online: ![Figure 1. AIS Google Trends. 100 is the most popular location as a fraction of total searches in that location, 50 indicates a location which is half as popular, 0 indicates a location without enough data. Queries included “aquatic invasive species” from 1/1/04 - 3/4/22. Data source: Google Trends (https://www.google.com/trends).](images/AIS_Search_Trends.png)
* Twitter is a promising data source for solving public health problems: [For example, Twitter data has been used to detect foodborne illness.](https://doi.org/10.1609/aimag.v38i1.2711)

### About Exploratory Data Analysis, a data analysis type

Exploratory Data Analysis (EDA) is a structured approach for understanding your data that can be used for research question and hypothesis development. Why do an Exploratory Data Analysis? Generally, you might want to get insights that help you make better decisions. 

Sub-objectives include:

- Identify trends across time.
- Identify trends across space. 
- Identify and deal with outliers.
- Uncover patterns related to the response (a.k.a. target or dependent) variable of interest.
- Create research questions to explore or hypotheses to test.
- Identify possible new data sources.

Remark, Time and space are addressed separately to reduce the complexity associated with programming/ interpretation of results.

#### Steps to EDA

1. Get your data
2. Understand your variables - To do so, read the documentation!
3. Tidy your data - If you're not familiar with getting your data into a tidy format, I recommend reading [Hadley Wickham's paper on the topic](https://vita.had.co.nz/papers/tidy-data.pdf)
4. Identify trends across time, identify and deal with outliers.
5. Identify trends across space, identify and deal with outliers.
6. Identify correlated variables
7. Uncover patterns related to the response e.g. lake infestation (hopefully)
8. Create research questions to explore or hypotheses to test, and possibly identify additional data sources.

Repeat as needed!

### Mental models that can supercharge your data analysis skills

EDA might sound intimidating to a data analysis newcomer. It certainly did to me. Thus, below are mental models that have helped me immensely.

- Wabi Sabi: Japanese world-view centered on the acceptance of transience and imperfection. With an attitude of Wabi Sabi, I aim for good enough to avoid getting trapped searching for the "perfect" solution.
- Black Box Thinking: Draw a black box between the input and the output of your project to focus on what matters, the work's impact. In data analysis, there's virtually infinite "hows" or ways to go from point a to point b and thus, it's common to get distracted along the way by shiny solutions.

[Source: Naked Data Science Podcast](https://open.spotify.com/show/4Sacw5UzY7utm6coTEHS0h?si=6e5ec050f22a4b85)

## Step 1. Get your data

Available in the directory data/tidy is the tweet ids used for my AIS case study. You should be able to "hydrate" them with the rest of their content, author ids, etc. using https://github.com/DocNow/hydrator. Note, I personally haven't used linked resource, but there's quite extensive documentation.

### 1.a Determine keywords of interest

For your project, you'll need to decide which tweets to request from the API. My code queries for AIS-related hashtags in tweets from January 1, 2012 to December 31, 2021. You'll need to decide on keywords of interest. Note, these can evolve as your project progresses, so don't aim for perfection the first time around.

For the AIS project, plant and animal species names were web scraped from the Minnesota Department of Natural Resources (https://www.dnr.state.mn.us/invasives/ais/id.html) July 18, 2022 and put into the [Google Sheet AIS and Twitter Keywords](https://docs.google.com/spreadsheets/d/15axVoP4eLejqTTRj-a15YU3v6AkJv3Y-n5AEQRievEU/edit?usp=sharing). “Aquatic Invasive Species” and “Aquatic Nuisance Species” were added manually to reflect conversation of broader categories. 

### 1.b Determine tweet abundance

In R, these keywords are pulled from Google Sheets, converted into their corresponding hashtag e.g. #AquaticInvasiveSpecies, and then queried for to get counts of tweets in code/02_get_tweet_counts.R. For this to work, you'll need to have defined your Twitter API bearer_token, etc. This is sourced from 00_Twitter_AIS_keys.R. You can find more details on setting this up in the Twitter API's documentation.

It's important to assess abundance prior to moving forward with tweet retrieval because you want to ensure that you aren't querying in excess. 03_expore_tweet_counts.R includes some code for visualization returned count data.

### 1.c Pull Tweets from the API

04_get_all_tweets.R includes code for doing so. This step is time-consuming thanks to the API's rate limit and will require some trial and error.

## Step 2. Analyze your data

Asking questions is the source of all knowledge. Thus, organizing any analysis around specific questions is helpful e.g.

- What proportion of AIS tweets include geo-tags, and might these tweets' locations relate to lake infestation risk?

See 05_map_tweets.R for spatial visualization.

- Who is driving the AIS conversation? Are there specific types of accounts that are more influential than others? 

06_get_social_data.R gets AIS tweet authors' followers and followings. 07_SNA.R contains code for a social network analysis, and 08_content_analysis.R includes code for a sentiment analysis and getting information useful for then performing a basic qualitative analysis of influential authors and tweets.

- What proportion of #AIS or #Goldfish mentions are actually Aquatic Invasive Species related?

Unfortunately, I didn't get to address this question in my analysis, but at least I realized the issue. It's ok to come up with lots of questions to address, but at the end of the day, prioritization is key and ideally done with project stakeholders.

## Step 3. Discussion

Analysis is not worthwhile if results are not shared/ acted upon. [Here's my presentation for the Human in the Data Symposium.](https://docs.google.com/presentation/d/1g2Bks6e0QEqjvQQyJWnA4wXYGhORB5XFIRH-KWTc8Aw/edit?usp=sharing). A few of the highlights: 

- There is limited AIS data available on Twitter
- Certain user accounts are most influential.
- Distinct communities of authors also exist.
- Surveying stakeholders may aid in identification of additional data sources.
- Personally, mental models can be useful for wayfinding through large amounts of data.

## About the Fellowship

["MnDRIVE—Minnesota’s Discovery, Research, and InnoVation Economy—is a partnership between the University of Minnesota and the State of Minnesota that aligns areas of research strength with the state’s key and emerging industries to address grand challenges."](https://research.umn.edu/about-us/initiatives/mndrive).

["The MnDRIVE Human in the Data Fellowship Program is a graduate student summer fellowship of $7,000 to fund research on the humanistic implications of data and its use in one of five MnDRIVE areas of concentration: robotics, global food, environment, brain conditions, or cancer clinical trials."](https://ias.umn.edu/opportunities/human-data-mndrive-fellowship-program). The program is co-sponsored by the UMN's Institute for Advanced Study, Digital Arts, Sciences, & Humanities Program, and Research Computing. 

A biostatistics PhD student at the UMN at the time of writing, I am grateful for the opportunity as a 2022 Human in the Data Fellow to explore humanistic themes and aggregate/ develop this repository of R code that might prove useful to another graduate student/ researcher.


