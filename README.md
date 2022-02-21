# R-Shiny-App-visualize-text-mining-analysis

This R Shiny application produces an analysis on the processing of a corpus from job boards available online. It is intended to guide the exploration and 
analysis of the corpus in a visual and interactive way. We chose to focus on the job offers available on the Pôle Emploi website. The objective is to analyse 
the body of text of the different offers present on the chosen site. We focused on one area in particular, namely job offers containing the word "data".

Connection to the dataset MySql
----------------------

First, start MySQL and Apache with XAMPP like the example below.

<img width="669" alt="Capture d’écran 2022-02-21 à 15 47 30" src="https://user-images.githubusercontent.com/73121667/154977892-db87842e-9b8b-4f0c-aedf-ebe31b198b5c.png">

Then, open PhpMyAdmin and load the .sql given in this github to import the data. You will have a dataset like this.

<img width="1433" alt="Capture d’écran 2022-02-21 à 15 53 39" src="https://user-images.githubusercontent.com/73121667/154979083-443eccf5-71e7-4013-9e03-c0af14f86ddc.png">



Run the R Shiny app
----------------------

You just have to run the .R file in Rstudio and a browser window shows up.
