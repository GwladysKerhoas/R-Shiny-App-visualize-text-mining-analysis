
#Chargement des données : il correspond au dataframe obtenu après l'extraction dans l'API de pôle emploi
#et après avoir subit des pré-traitements
data <- read.csv("~/Desktop/Master_SISE/Projet_R_Shiny/Data/pole_emploi_data_Final_3.csv", sep=",")


#TAbles Déparrtement et Ville *******************************************************************************************

#Division de la colonne lieuTravail__libelle en Dept et Ville
library(reshape2)
df_Dept_ville = colsplit(data$lieuTravail.libelle, " - ", names = c("Dept", "Ville"))

#Création des new cols dans le df data
data$Departement = df_Dept_ville$Dept
data$Ville = df_Dept_ville$Ville


#Création de la table Département
unique_Dept = unique(data$Departement)
df_Dept = data.frame(1:length(unique_Dept),unique_Dept,rep(1,length(unique_Dept)))
names(df_Dept)=c("id_Dept","NomDept","id_region")

library(dplyr)               
data = left_join(data, df_Dept, 
                 by = c("Departement" = "NomDept"))


#Création de la table Ville
unique_Ville = unique(data$Ville)#data[,c("Ville","id_Dept")]
df_Ville = data.frame(1:length(unique_Ville),unique_Ville) #unique_Ville$Ville
names(df_Ville)=c("id_Ville","NomVille") #,"id_Dept"

#********************************************************************************************************



#Création de la table DATE
data$dateCreation <- substr(data$dateCreation,1, 10)
unique_Date = unique(data$dateCreation)
df_Date = data.frame(1:length(unique_Date),unique_Date)
names(df_Date)=c("id_Date","Date")
#********************************************************************************************************


#**Création de la table entreprise******************************************************************************
unique_NomEntrep = unique(data$entreprise.nom)
df_Entreprise = data.frame(1:length(unique_NomEntrep),unique_NomEntrep)
names(df_Entreprise)=c("id_Entreprise","NomEntreprise")
df_Entreprise[4,2]="Inconnu"
#df_Entreprise = df_Entreprise[1:56,] #On ne prend que les 56 premiers noms car le reste ne correspond
#pas à des noms mais plutot à des description d'entreprises (Problème venant de l'API)
#********************************************************************************************************

#**Création de la table Experience******************************************************************************
unique_Experience = unique(data$experienceLibelle)
df_Experience = data.frame(1:length(unique_Experience),unique_Experience)
names(df_Experience)=c("id_Experience","Experience")

#df_Experience[8,2] = "Inconnu"
#********************************************************************************************************



#**Création de la table Secteur******************************************************************************
unique_Secteur = unique(data$secteurActiviteLibelle)
df_Secteur = data.frame(1:length(unique_Secteur),unique_Secteur)
names(df_Secteur)=c("id_Secteur","NomSecteur")

df_Secteur[4,2] = "Inconnu"
#********************************************************************************************************



#**Création de la table Qualification******************************************************************************
#unique_Qualification = unique(data$qualitesProfessionnelles.libelle)
#df_Qualification = data.frame(1:length(unique_Qualification),unique_Qualification)
#names(df_Qualification)=c("id_Qualification","Qualification")

#df_Qualification[1,2] = "Inconnu"
#********************************************************************************************************


#**Création de la table TypeContrat******************************************************************************

unique_TypeContrat = unique(data$typeContrat)
df_TypeContrat = data.frame(1:length(unique_TypeContrat),unique_TypeContrat)
names(df_TypeContrat)=c("id_TypeContrat","TypeContrat")

#df_TypeContrat[4,2] = "Inconnu"
#********************************************************************************************************



#*********************TABLE Principale OFFRE_EMPLOI********************************************************


names(data)
#--Ajout des colonnes id des dimensions dans le df data---------
data = left_join(data, df_Date, by = c("dateCreation" = "Date"))

data = left_join(data, df_Ville[,c(1,2)], by = c("Ville" = "NomVille"))

data = left_join(data, df_Entreprise, by = c("entreprise.nom" = "NomEntreprise"))

data = left_join(data, df_Experience , by = c("experienceLibelle" = "Experience"))

data = left_join(data, df_Secteur , by = c("secteurActiviteLibelle" = "NomSecteur"))

#data = left_join(data, df_Qualification , by = c("qualitesProfessionnelles__libelle" = "Qualification"))

data = left_join(data, df_TypeContrat , by = c("typeContrat" = "TypeContrat"))
#---------------------------------------------------------------

names(data)

df_Offre_Emploi = data[,c("id","id_Date","id_Ville","id_Secteur","id_Entreprise","id_Experience",
                          "id_TypeContrat","intitule","description","salaire.libelle",
                          "lieuTravail.latitude","lieuTravail.longitude","lieuTravail.libelle")] #"id_Qualification"


df_Offre_Emploi = df_Offre_Emploi %>%
  filter(!(id==""))
#********************************************************************************************************


#Gestion de l'hierarchie Ville -> Département -> Région*****************************************
#Ajout des variables étrangères dans la table ville : ceci ne pouvais pas être fait avant car ça 
#compromettait la construction de la table Offre_Emploi
#Création de la table Ville
#unique_Ville = unique(data$Ville)#data[,c("Ville","id_Dept")]
#df_Ville = data.frame(1:length(unique_Ville),unique_Ville) #unique_Ville$Ville
#names(df_Ville)=c("id_Ville","NomVille") #,"id_Dept"

df_Ville = data[!duplicated(data[,c('id_Ville','Ville')]),c('id_Ville','Ville','id_Dept')]

df_Ville[10,2] = "Inconnu"

#Création table région
df_Region = data.frame(1,"RegionProvisoire")
names(df_Region) = c("id_Region", "NomRegion")
#********************************************************************************************************


#GEstion des NA ******************************************************************
df_Dept[length(df_Dept$id_Dept)+1,1] = 999
df_Dept[length(df_Dept$id_Dept),2] = "Not_Available"
df_Dept[length(df_Dept$id_Dept),3] = 1

df_Ville[length(df_Ville$id_Ville)+1,1] = 999
df_Ville[length(df_Ville$id_Ville),2] = "Not_Available"
df_Ville[length(df_Ville$id_Ville),3] = 999

df_Entreprise[length(df_Entreprise$id_Entreprise)+1,1] = 999
df_Entreprise[length(df_Entreprise$id_Entreprise),2] = "Not_Available"

df_Experience[length(df_Experience$id_Experience)+1,1] = 999
df_Experience[length(df_Experience$id_Experience),2] = "Not_Available"

#df_Qualification[length(df_Qualification$id_Qualification)+1,1] = 999
#df_Qualification[length(df_Qualification$id_Qualificdf_Depton),2] = "Not_Available"

df_Secteur[length(df_Secteur$id_Secteur)+1,1] = 999
df_Secteur[length(df_Secteur$id_Secteur),2] = "Not_Available"

df_TypeContrat[length(df_TypeContrat$id_TypeContrat)+1,1] = 999
df_TypeContrat[length(df_TypeContrat$id_TypeContrat),2] = "Not_Available"


df_Offre_Emploi_reduit = subset(df_Offre_Emploi,select=-salaire.libelle)
df_Offre_Emploi_reduit[is.na(df_Offre_Emploi_reduit)] = 999
df_Offre_Emploi$salaire.libelle[is.na(df_Offre_Emploi$salaire.libelle)] = 0

df_Offre_Emploi = cbind(df_Offre_Emploi_reduit,df_Offre_Emploi$salaire.libelle)
#*********************************************************************************



write.csv(as.matrix(df_Region), "CSV/df_Region.csv", row.names = FALSE)
write.csv(as.matrix(df_Dept), "CSV/df_Dept.csv", row.names = FALSE)
write.csv(as.matrix(df_Ville), "CSV/df_Ville.csv", row.names = FALSE)
write.csv(as.matrix(df_Date), "CSV/df_Date.csv", row.names = FALSE)

write.csv(as.matrix(df_Offre_Emploi), "CSV/df_Offre_Emploi.csv", row.names = FALSE)

write.csv(as.matrix(df_Experience), "CSV/df_Experience.csv", row.names = FALSE)
write.csv(as.matrix(df_Entreprise), "CSV/df_Entreprise.csv", row.names = FALSE)
#write.csv(as.matrix(df_Qualification), "CSV/df_Qualification.csv", row.names = FALSE)
write.csv(as.matrix(df_Secteur), "CSV/df_Secteur.csv", row.names = FALSE)
write.csv(as.matrix(df_TypeContrat), "CSV/df_TypeContrat.csv", row.names = FALSE)

