library(jsonlite)
library(httr)
library(dplyr)
library(writexl)

#API fournit par pole-emploi.io
api_key = "PAR_m2sise_90cabef2e7abec8fea12996d8620667db484a823e2208b43a4fc8fa7613975be"
key = "6ac21a14b5d2f22638ad65846e331a5716925ece11a1385b3f53b1649cfc1469"


request_body = list(
  grant_type = "client_credentials",
  client_id = api_key,
  client_secret = key,
  scope = paste(
    "api_offresdemploiv2",
    "o2dsoffre",
    paste0("application_",api_key), sep = " "))

#Génération du Token d'accès
result_auth = POST(
  "https://entreprise.pole-emploi.fr/connexion/oauth2/access_token",
  query = list(realm = "/partenaire"),
  body = request_body,
  encode = "form")

token = rawToChar(result_auth$content)
token = fromJSON(token,flatten = TRUE)

result_auth$status_code
requetes <- GET("https://api.emploi-store.fr/partenaire/offresdemploi/v2/offres/search?motsCles=data&range=1050-1199",
         add_headers(Authorization = paste("Bearer",token$access_token)))

offres = httr::content(requetes, as='text',encoding = "UTF-8")
offres_json = fromJSON(offres)
data8= offres_json$resultats

write(offres, "pole_emploi_data3.json")
toto = fromJSON("dnvndsl.json")

#Affichage des ID des offres
print(offres_json$resultats$id)
print(offres_json$resultats$intitule
      )
#convertion en dataFrame
offres_json1 = fromJSON("poleemploidata2.json")
df1 = offres_json1 %>% as.data.frame(row.names = NULL)
