
library(leaflet)
library(shiny)
library(wordcloud)
library(shinythemes)
library(DT)
library(RMySQL)
library(ldatuning)
library(formattable)
library(plotly)
library(parallel)
library(topicmodels)
library(data.table)

# Construction de l'application R shiny : front end interface
ui <- fluidPage(

  #Barre de navigation dans l'application
  navbarPage("Pôle Emploi",theme = shinytheme("flatly"),

             tabPanel('Recherche des offres',

                      #Chargement filtré des données
                      titlePanel(h3("Filtrage des offres d'emploi",style='color:blue')),

                      # Application des filtres
                      fluidRow(
                        column(width = 2, textInput('id_lieu', "Lieu")),
                        column(width = 2, textInput('id_intitule', "Poste")),
                        #column(width = 2, textInput('id_secteur', "Secteur")),
                        column(width = 2, textInput('id_typecontrat', "Type de contrat"))
                      ),
                      actionButton('id_Chargement', 'Filtrer'),
                      br(),
                      fluidRow(
                        column(width = 5, h4("Nombre d'offres proposées : ",style='color:purple',textOutput("nombre_d_offres")))
                      ),

                      br(),
                      br(),

                      DT::DTOutput('offres_table')#tableOutput
             ),

             # Premier onglet : Carte intéractive de la France
             tabPanel('Statistiques générales',

                      # Thème de la page
                      theme = shinythemes::shinytheme('flatly'),
                      tags$head(
                        # Include our custom CSS
                        includeCSS("style.css")
                      ),


                      # Affichage de la carte avec leaflet
                      titlePanel(h3("Analyse régionale des offres d'emploi",style='color:blue')),
                      leaflet::leafletOutput('map', height=700),

                      #Enrichissement des StopWorrds
                      #textInput("idStopWord", "Entrez un mot que vous souhaitez extraire de votre analyse : "),
                      #actionButton('id_Add_StopWord', 'Retirer'),


                      # Wordcloud and Histogram
                      fluidRow(
                        column(width = 2, h3("Ajouter des stopWords (séparés par des point-virgules) ",style='color:brown', align = 'center'),textInput("idStopWord", "", placeholder ='data;données;science')),
                        column( width = 5,h3("Nuage de mots",style='color:purple', align = 'center'), plotOutput('offres', height=500)),
                        column( width = 5,h3("Analyse des mots les plus fréquents",style='color:red', align = 'center'), plotlyOutput('distPlot', height=500) )
                      ),

                      # Ajout d'un panel de réglage
                      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                    draggable = TRUE, top = 100, left = "auto", right = 20, bottom = "auto",
                                    width = 330, height = "auto",
                                    titlePanel(h5("Analyse régionale des offres d'emploi",style='color:blue;padding-left: 35px')),
                                    h4("Nombre d'offres proposées : ",textOutput("nombre_d_offres2")),
                                    titlePanel(h5("Analyse des mots les plus fréquents",style='color:purple;padding-left: 35px')),
                                    tags$style(HTML(".js-irs-0 .irs-single, .js-irs-0 .irs-bar-edge, .js-irs-0 .irs-bar {background: purple}")),
                                    sliderInput('max_words', 'Nombre de mots', 1, 300, 250),
                                    titlePanel(h5("Analyse des mots les plus fréquents",style='color:red;padding-left: 35px')),
                                    tags$style(HTML(".js-irs-1 .irs-single, .js-irs-1 .irs-bar-edge, .js-irs-1 .irs-bar {background: red}")),
                                    sliderInput('nb_words', 'Nombre de mots', 1, 20, 10),
                      ), tags$style(type = "text/css", "
      html, body {width:100%;height:100%}
      #controls{background-color:white;padding:20px;}
    ")

             ),

             # Deuxième onglet : LDA
             tabPanel('Détection des topics',
                      titlePanel(h3("Tunage du nombre de topics pour l'apprentissage du modèle LDA",style='color:blue')),

                      fluidRow(
                        column(width = 3, numericInput('id_nbTopicMin','Nombre de Topics Min', value=2)),
                        column(width = 3, numericInput('id_nbTopicMax','Nombre de Topics Max', value=3)),
                        column(width = 3, numericInput('id_STEP','STEP', value=1)),
                        column(width = 3, actionButton('id_runTuning', 'Tuning'), align = "left", style = "margin-top: 25px;")
                      ),
                      br(),
                      br(),

                      tabsetPanel(
                        tabPanel("Analyse métriques",
                          plotOutput('ldaTuningResults')
                        ),
                        tabPanel("Analyse Perplexité",
                          plotlyOutput('perplexity_curve')

                        )

                      ),



                      br(),

                      titlePanel(h3("Apprentissage du modèle LDA",style='color:blue')),
                      h4("En fonction des réusltats renvoyés par les graphiques ci-dessus, entrez la valeur du nombre \n de topics pour l'apprentissage du modèle."),
                      fluidRow(
                        column(width = 3, numericInput('id_nbTopic','Nombre de Topics', value=2)),
                        column(width = 3, textInput('id_metric','Métrique', placeholder ='CaoJuan200, Arun2010 ou Deveaud2014')),
                        column(width = 3, actionButton('id_runLDA', 'Lancer LDA'), align = "left", style = "margin-top: 25px;")
                      ),
                      br(),
                      br(),
                      plotOutput('ldaResults')

             ),

             # Troisième onglet :
             tabPanel('Clustering',
                      titlePanel(h3("Application de l'algorithme LSA",style='color:blue')),
                      h4("Les mots qui seront utilisés dans le clustering par le biais du LSA proviendront des \n 10 mots les plus représentatifs des topics obtenus avec un modèle LDA."),
                      br(),
                      h4("Exemple : un nombre de topics égale à 5 est équivalent à l'instanciation d'une LSA \n sur un nombre de mots inférieur ou égale à 50."),
                      fluidRow(
                        column(width = 3, numericInput('id_nbTopics_2','Nombre de topics', value= 2)),
                        column(width = 3, textInput('id_metric_2','Métrique', placeholder = 'CaoJuan200, Arun2010 ou Deveaud2014' )),
                        column(width = 3, actionButton('id_runLSA', 'Lancer LSA'), align = "left", style = "margin-top: 25px;")
                      ),
                      br(),
                      br(),
                      plotlyOutput('lsaResults_1'),
                      plotlyOutput('plot_offres_id')

             )
  )
)









# backend logic
server <- function(input, output, session){
  
  #Fonction permettant de charger les données à travers des requêtes sur la Base de données MySQL
  data_function = reactive({
    if(input$id_Chargement == 0){
      return()
    }else{
      isolate({
        showModal(modalDialog("Chargement en cours ...... ", footer=NULL))

        con <- dbConnect(RMySQL::MySQL(), host = "localhost",dbname="offres_emploi",user = "root", password = "",port=3306)
        good_Encoding=dbGetQuery(con, "SET NAMES 'latin1'")

        req0 = "id_offre IS NOT NULL"
        req1 = ""
        req2 = ""
        req3 = ""

        req_Principale = "SELECT id_offre, intitule, description, DateText,
                         latitude, longitude, lieu_travail_libelle, entreprise,
                         typecontrat, experience, salaire_moyen, secteur,
                         departement, ville
                         FROM offreemploi LEFT JOIN date_table
                         ON offreemploi.id_Date = date_table.id_Date
                         LEFT JOIN entreprise ON offreemploi.id_entreprise = entreprise.id_entreprise
                         LEFT JOIN experience ON offreemploi.id_experience = experience.id_experience
                         LEFT JOIN type_contrat ON offreemploi.id_typecontrat = type_contrat.id_typecontrat
                         LEFT JOIN secteur ON offreemploi.id_secteur = secteur.id_secteur
                         LEFT JOIN ville ON offreemploi.id_ville = ville.id_ville
                         LEFT JOIN departement ON ville.id_dpt = departement.id_dpt WHERE "
        if(! input$id_typecontrat == ""){
          req1 = paste0(" AND typecontrat = '", input$id_typecontrat, "'")
        }
        if(! input$id_intitule == ""){
          req2 = paste0(" AND intitule LIKE '%", input$id_intitule, "%'")
        }
        if(! input$id_lieu == ""){
          req3 = paste0(" AND ville LIKE '%", input$id_lieu, "%'")
        }
        # if(! input$id_secteur == ""){
        #   req4 = paste0(" AND secteur LIKE '% ", input$id_secteur, " %'")
        # }

        data=dbGetQuery(con, paste0(req_Principale, req0, req1, req2, req3 ))#, req3  , req1, req2
        names(data) = c("id","intitule","description","dateCreation","lieuTravail.latitude",
                                          "lieuTravail.longitude", "lieuTravail.libelle", "entreprise.nom",
                                          "typeContrat", "experienceLibelle","salaire.libelle",
                                          "secteurActiviteLibelle", "departement", "ville")

        dbDisconnect(con)


        removeModal()

        res = data

      })
    }

  })


  #Fonction qui retourne sosus forme de table le jeu de données chargé
  output$offres_table <- DT::renderDT({#renderTable
    data = data_function()
    data = data.frame(
      Identifiant = data$id,
      Poste = data$intitule,
      Entreprise = data$entreprise.nom,
      Lieu = data$lieuTravail.libelle,
      Description = data$description,
      Type_Contrat = data$typeContrat,
      Secteur = data$secteurActiviteLibelle,
      Experience = data$experienceLibelle,
      Date_de_parution = data$dateCreation
    )
    formattable(
      data,
      list(
        'Poste' = color_bar("lightgray"),
        'Entreprise' = color_bar("lightblue"),
        'Experience' = formatter("span", style = x ~ formattable::style(color = ifelse(x < 2, "green", ifelse(grepl('Débutant',x), "green", "red"))))
      )
    ) %>%

      as.datatable(
        colnames = c('Identifiant du poste', 'Poste', 'Entreprise', 'Lieu', 'Description du poste', 'Type de contrat', 'Secteur', 'Experience', 'Date de parution'),
        rownames = FALSE,
        options = list(columnDefs = list(list(
          targets = 4,
          render = JS(
            "function(data, type, row, meta) {",
            "return type === 'display' && data.length > 6 ?",
            "'<span title=\"' + data + '\">' + data.substr(0, 6) + '...</span>' : data;",
            "}")
        ))), callback = JS('table.page(3).draw(false);')
      )

  })

  #Fonction qui tokénise la colonne des descriptons des offres et crée des matrice dtm et tdm
  importantObjects <- function(data){
    #Génération de TOKENS
    corpus_description = strsplit(data$description, " ")

    #mettre en un seul vecteur les mots
    vec.mots <- unlist(corpus_description)


    #Suppression des stopwords--------------------------------------------------------------------
    library(stopwords)
    library(tidyverse)
    french_stopWords = stopwords("fr", source = "nltk")

    if(! input$idStopWord == ""){
      vec_new_StopWords = unlist(strsplit(input$idStopWord, ";"))
      french_stopWords = c(french_stopWords, vec_new_StopWords)
    }

    vec.mots=vec.mots[!(vec.mots %in% french_stopWords)]

    #Comptage des occurences de chaque mot
    table.mots <- table(vec.mots)
    table.mots <- sort(table.mots,decreasing=TRUE) #Tri par ordre décroissant
    #------------------------------------------------------------------------------------------------------


    library(dplyr)
    library(tidytext)
    text_df <- tibble(Offre = data$id, Description = data$description)

    #Construction d'une matrice document-term en faisant un comptage des mots pour chaque document
    #french_stopWords= c(french_stopWords,"données","équipe","équipes","expérience","plus","afin")
    Offre_Description <- text_df %>%
      unnest_tokens(output=Word, input=Description)%>%
      count(Offre,Word, sort = TRUE)%>%
      filter(!(Word %in% french_stopWords))

    #Document - Term Matrix
    dtm = Offre_Description%>%cast_dtm(Offre, Word, n)

    #Term -Document Matrix
    TDM = Offre_Description %>% cast_tdm(document = Offre, term = Word, value = n)
    TDM_array = as.matrix(TDM)
    tdm= as.data.frame(TDM_array)

    return(list(vec.mots, table.mots, dtm, tdm))

  }


  #Comptage du nombre d'offres d'emploi
  output$nombre_d_offres <- renderText({
    data = data_function()
    nrow(data)
  })

  output$nombre_d_offres2 <- renderText({
    data = data_function()
    nrow(data)
  })


  output$map <- leaflet::renderLeaflet({
    data = data_function()
      data %>%
      leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>%
      setView(lng = 4, lat = 47, 90.82, zoom = 6) %>%
      addMarkers(
        clusterOptions = markerClusterOptions(iconCreateFunction=JS("function (cluster) {
            var childCount = cluster.getChildCount();
            if (childCount < 10) {
              c = 'rgba(51, 131, 203, 1.0);'
            } else if (childCount < 50) {
              c = 'rgba(68, 107, 231, 1);'
            } else {
              c = 'rgba(20, 77, 255, 1);'
            }
            return new L.DivIcon({ html: '<div style=\"background-color:'+c+'\"><span>' + childCount + '</span></div>', className: 'marker-cluster', iconSize: new L.Point(40, 40) });

          }")),
        #clusterOptions = markerClusterOptions(spiderLegPolylineOptions = list(weight = 1.5, color = "#100", opacity = 0.5)),
        lng = ~ data$lieuTravail.longitude,
        lat = ~ data$lieuTravail.latitude,
        popup = paste(
          "Intitulé : ", data$intitule, "<br/>",
          " Entreprise : ", data$entreprise.nom, "<br/>",
          " Lieu : ", data$lieuTravail.libelle,"<br/>",
          " Type de contrat : ", data$typeContrat,"<br/>",
          " Salaire : ", data$salaire.libelle
        ),
      )
  })

  # Construction du nuage de mots
  output$offres <- renderPlot({
    data = data_function()
    list_objects = importantObjects(data)
    table.mots = list_objects[[2]]
    wordcloud(words=names(table.mots),freq=table.mots,colors="#7A1575", max.words=input$max_words)
  })

  # Histogramme des mots les plus fréquents
  output$distPlot <- renderPlotly({
    data = data_function()
    list_objects = importantObjects(data)
    table.mots = list_objects[[2]]
    vec.mots= list_objects[[1]]
    ggplot(as.data.frame(table.mots[1:input$nb_words]), aes(x=vec.mots, y = Freq)) +
      geom_bar(stat="identity", size = 0.5, color="red", fill="white") +
      xlab("Mots les plus fréquents") + ylab("Fréquence")
  })


  #Tunage du nombre de Topics
  output$ldaTuningResults <- renderPlot({
    if(input$id_runTuning == 0){
      return()
    }else{
      data = data_function()
      list_objects = importantObjects(data)
      dtm = list_objects[[3]]

      isolate({
        showModal(modalDialog("Tunage en cours ...... ", footer=NULL))
        res = FindTopicsNumber(dtm,
                               topics = seq(from = input$id_nbTopicMin, to = input$id_nbTopicMax, by = input$id_STEP),
                               metrics = c("CaoJuan2009", "Arun2010", "Deveaud2014"),
                               method = "VEM",
                               control = list(seed = 77),
                               mc.cores = detectCores() - 1,
                               verbose = TRUE,
                               return_models = TRUE)


        #Courbe de la perplexité en fonction du nombre de topics
        output$perplexity_curve <- renderPlotly({
          Vec_nb_topic = c()
          Vec_perplexity = c()
          isolate({
            for(i in 1:length(res$LDA_model)){
              Vec_nb_topic = c(Vec_nb_topic,i)
              Vec_perplexity = c(Vec_perplexity, perplexity(res$LDA_model[i]))
            }

            data_perplexity_curve =  data.frame(Vec_nb_topic,Vec_perplexity)
            
            ggplot(data_perplexity_curve, aes(Vec_nb_topic,Vec_perplexity))+
              geom_line()+geom_point()+
              xlab("Nombre de Topics") + ylab("Perplexity")
          })

        })

        removeModal()

        FindTopicsNumber_plot(res)
      })

    }

  })

  output$ldaResults = renderPlot({
    if(input$id_runLDA == 0){
      return()
    } else{
      data = data_function()
      list_objects = importantObjects(data)
      dtm = list_objects[[3]]

      isolate({
        showModal(modalDialog("Apprentissage du modèle en cours ...... ", footer=NULL))
        #Apprentissage par le modèle LDA
        library(topicmodels)
        fit_LDA <- LDA(dtm, k = input$id_nbTopic, metrics=input$id_metric, control = list(seed = 1234))#, metrics="Arun2010"

        #Probabilités d'appartion des mots dans les topics
        ap_topics <- tidy(fit_LDA, matrix = "beta")

        #Affichage des mots les plus fréquents dans chaque Topic
        library(ggplot2)
        ap_top_terms <- ap_topics %>%
          group_by(topic) %>%
          slice_max(beta, n = 10)

        removeModal()

        ap_top_terms %>%
          mutate(term = reorder_within(term, beta, topic)) %>%
          ggplot(aes(beta, term, fill = factor(topic))) +
          geom_col(show.legend = FALSE) +
          facet_wrap(~ topic, scales = "free") +
          ggtitle(paste("Histogramme des 10 mots les plus représentatifs des ", input$id_nbTopic, " topics appris par LDA"))+
          theme(plot.title = element_text(color="brown", size=22, face="bold.italic",hjust = 0.5))+
          scale_y_reordered()

      })
    }

  })

  #id_nbMots id_runLSA lsaResults_1
  output$lsaResults_1 = renderPlotly({
    if(input$id_runLSA == 0){
      return()
    } else{
      data = data_function()
      list_objects = importantObjects(data)
      dtm = list_objects[[3]]
      tdm = list_objects[[4]]


      isolate({
        showModal(modalDialog("Apprentissage d'un modèle LDA avec ", (input$id_nbMots)/10 ," Topics en cours ...... ", footer=NULL))
        #Apprentissage par le modèle LDA
        library(topicmodels)
        fit_LDA <- LDA(dtm, k = input$id_nbTopics_2, metrics=input$id_metric_2, control = list(seed = 1234))

        #Probabilités d'appartion des mots dans les topics
        ap_topics <- tidy(fit_LDA, matrix = "beta")

        removeModal()

        showModal(modalDialog("Clustering sur ", (input$id_nbMots) ," mots avec modèle LSA en cours ...... ", footer=NULL))
        ap_top_terms <- ap_topics %>%
          group_by(topic) %>%
          slice_max(beta, n = 10)

        mots = ap_top_terms$term
        mots = mots[!duplicated(mots)]
        tdm =tdm[mots,]

        mean_offres = data.frame(apply(tdm,2,mean),rep(1,length(tdm)))
        mean_global = apply(mean_offres,2,mean)[1]
        mean_global = as.numeric(mean_global)

        num_offres = c()
        for(i in 1:length(rownames(mean_offres))){
          if (mean_offres[i,1] > mean_global){
            num_offres = c(num_offres,rownames(mean_offres[i,]))
          }
        }

        tdm = tdm[,num_offres]


        library(lsa)
        my_lsa = lsa(tdm)
        my_lsa1 = as.data.frame(my_lsa$tk)
        my_lsa2 = as.data.frame(my_lsa$dk)


        setDT(my_lsa1, keep.rownames = "Mot")
        setDT(my_lsa2, keep.rownames = "Offre_ID")


        removeModal()

        output$plot_offres_id = renderPlotly({
          ggplot(my_lsa2, aes(V1, V2, label = Offre_ID))+
            geom_point()+ geom_text() +
            ggtitle("Projection des documents sur les deux premiers axes")+
            xlab("Axe 1") + ylab("Axe 2")
        })

        ggplot(my_lsa1, aes(V1, V2, label = Mot))+
          geom_point()+ geom_text() +
          ggtitle("Projection des mots sur les deux premiers axes")+
          xlab("Axe 1") + ylab("Axe 2")


      })
    }

  })



}

# Démarrage de l'application
shinyApp(ui=ui, server=server)

