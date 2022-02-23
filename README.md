# R-Shiny-App-visualize-text-mining-analysis

Author : Franck Doronzo, Davy Darankoum, Gwladys Kerhoas

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

You just have to run the .R file in Rstudio and a browser window shows up. If the code doesn't run, it's because you have a problem in the connection. If you use a windows environment, use this code on line 175 :

    con <- dbConnect(RMySQL::MySQL(), host = "localhost",dbname="Offres_Emploi",user = "root", password = "",port=3306)
    good_Encoding=dbGetQuery(con, "SET NAMES 'latin1'")

If you are using macOS :

    con <- dbConnect(RMySQL::MySQL(), host = "127.0.0.1",dbname="Offres_Emploi",user = "root", password = "",port=3306)
    good_Encoding=dbGetQuery(con, "SET NAMES 'utf8'")



<img width="1424" alt="Capture d’écran 2022-02-21 à 16 10 44" src="https://user-images.githubusercontent.com/73121667/154982851-1410ac42-6309-4b6e-911b-bf451866e2b2.png">

<img width="1399" alt="Capture d’écran 2022-02-21 à 16 18 47" src="https://user-images.githubusercontent.com/73121667/154983336-89f08311-b8e5-4c87-ae83-1a4bc478eee2.png">


<img width="1401" alt="Capture d’écran 2022-02-21 à 16 24 56" src="https://user-images.githubusercontent.com/73121667/154984750-547d406c-8738-42cb-9a92-4cc6bc272133.png">

<img width="1399" alt="Capture d’écran 2022-02-21 à 16 27 57" src="https://user-images.githubusercontent.com/73121667/154984924-af2c08fd-c7a6-4901-bd35-5255431485dc.png">

<img width="1400" alt="Capture d’écran 2022-02-21 à 16 28 05" src="https://user-images.githubusercontent.com/73121667/154984943-968e76fc-fcac-4044-a421-82c1c360843d.png">

<img width="1403" alt="Capture d’écran 2022-02-21 à 16 28 15" src="https://user-images.githubusercontent.com/73121667/154984958-34267f40-f76c-419d-9829-9432e1c33fa4.png">

<img width="1401" alt="Capture d’écran 2022-02-21 à 16 28 33" src="https://user-images.githubusercontent.com/73121667/154984972-55902087-06d6-466b-9129-9e74df76d875.png">




