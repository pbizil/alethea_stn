library(shiny)
library(shinydashboard)
library(geobr)
library(sf)
library(leafgl)
library(leaflet)
library(readr)
library(rstatix)
library(leaflet.extras)
library(dplyr)
library(magrittr)
library(stringr)
library(tidyr)

### CARGA DOS DADOS 

#setwd("~/Desktop/alethea_stn/app")

data_imoveis_precos <- read_csv("data/data_imoveis_precos.csv")
data_imoveis_precos <- data_imoveis_precos[is_extreme(data_imoveis_precos$lat) == FALSE,]
data_imoveis_precos <- data_imoveis_precos[is_extreme(data_imoveis_precos$lng) == FALSE,]
data_imoveis_precos = data_imoveis_precos %>% drop_na()

# formatacao preco em reais
format_real <- function(values, nsmall = 0) {
  values %>%
    as.numeric() %>%
    format(nsmall = nsmall, decimal.mark = ",", big.mark = ".") %>%
    str_trim() %>%
    str_c("R$ ", .)
}

data_imoveis_precos$preco_format <- format_real(data_imoveis_precos$preco_predict)


### divisao dos datasets para cada tipo de imovel

apartamentos_uniao = data_imoveis_precos[data_imoveis_precos$tipo_imovel=="Apartamento", ]
residen_uniao = data_imoveis_precos[data_imoveis_precos$tipo_imovel=="Residência/Casa", ]
terrenos_uniao = data_imoveis_precos[data_imoveis_precos$tipo_imovel=="Terreno", ]



### APP

ui <- dashboardPage(skin = "black",
                    dashboardHeader(title = "alethea.dash"),
                    dashboardSidebar(
                      sidebarMenu(
                        menuItem(
                          "Sobre o projeto", 
                          tabName = "sobre", 
                          icon = icon("project-diagram")
                        ),
                        menuItem(
                          "Consulta", 
                          tabName = "consulta", 
                          icon = icon("search"),
                          menuSubItem("Apartamentos", tabName = "consulta_apart"),
                          menuSubItem("Casa/Residência", tabName = "consulta_residen"),
                          menuSubItem("Terrenos", tabName = "consulta_terr")
                        ),
                        menuItem(
                          "Mapas", 
                          tabName = "maps", 
                          icon = icon("map"),
                          menuSubItem("Apartamentos", tabName = "maps_apart"),
                          menuSubItem("Casa/Residência", tabName = "maps_residen"),
                          menuSubItem("Terrenos", tabName = "maps_terr")
                        ))),
                    
                    dashboardBody(
                      tags$head(tags$style(HTML('.content-wrapper {background-color: #fff;}
    .wrapper {height: auto !important; position:relative; overflow-x:hidden; overflow-y:hidden}'))),
                      
                      
                      tabItems(
                        
                        tabItem(tabName = "sobre", box(title = "Sobre o projeto", status = "success", solidHeader = F, width = 12,
                                                       fluidPage(fluidRow(column(12, align="center", imageOutput("logo"))),
                                                                 fluidRow(textOutput("text_about"))))),
                        ### consulta
                        tabItem(tabName = "consulta_apart", fluidPage(box(title = "Consulta - Predição de preço de apartamentos da União", 
                                                                          status = "warning", solidHeader = F, width = 12,
                                                                      fluidPage(fluidRow(selectizeInput("select_apart", label = "Selecione Cidade", choices =  unique(apartamentos_uniao[apartamentos_uniao$preco_predict!="-",]$municipio))),
                                                                                fluidRow(valueBoxOutput("apart_count_num"), valueBoxOutput("apart_area_num"), valueBoxOutput("apart_preco_num")), 
                                                                                fluidRow(column(12, dataTableOutput('tableAPART'))))))),
                        tabItem(tabName = "consulta_residen", fluidPage(box(title = "Consulta - Predição de preço de casas/residências da União", 
                                                                          status = "warning", solidHeader = F, width = 12,
                                                                          fluidPage(fluidRow(selectizeInput("select_residen", label = "Selecione Cidade", choices =  unique(residen_uniao[residen_uniao$preco_predict!="-",]$municipio))),
                                                                                    fluidRow(valueBoxOutput("residen_count_num"), valueBoxOutput("residen_area_num"), valueBoxOutput("residen_preco_num")),
                                                                                    fluidRow(column(12, dataTableOutput('tableRESIDEN'))))))),
                        tabItem(tabName = "consulta_terr", fluidPage(box(title = "Consulta - Predição de preços de terrenos da União", 
                                                                          status = "warning", solidHeader = F, width = 12,
                                                                         fluidPage(fluidRow(selectizeInput("select_terr", label = "Selecione Cidade", choices =  unique(terrenos_uniao[terrenos_uniao$preco_predict!="-",]$municipio))),
                                                                                   fluidRow(valueBoxOutput("terr_count_num"), valueBoxOutput("terr_area_num"), valueBoxOutput("terr_preco_num")),
                                                                                   fluidRow(column(12, dataTableOutput('tableTERR'))))))),
                        ### mapas
                        tabItem(tabName = "maps_apart", fluidPage(box(title = "Distribuição espacial dos apartamentos da União", 
                                                                      status = "warning", solidHeader = F, width = 12,
                                                                      fluidPage(fluidRow(textOutput("text_map_apart")),
                                                                                br(), br(),
                                                                                fluidRow(leafletOutput("map_apartamentos", height=1000)))))),
                        tabItem(tabName = "maps_residen", fluidPage(box(title = "Distribuição espacial dos casas/residências da União", 
                                                                      status = "warning", solidHeader = F, width = 12,
                                                                      fluidPage(fluidRow(textOutput("text_map_residen")),
                                                                                br(), br(),
                                                                                fluidRow(leafletOutput("map_residen", height=1000)))))),
                        tabItem(tabName = "maps_terr", fluidPage(box(title = "Distribuição espacial dos terrenos da União", 
                                                                      status = "warning", solidHeader = F, width = 12,
                                                                     fluidPage(fluidRow(textOutput("text_map_terr")),
                                                                               br(), br(),
                                                                               fluidRow(leafletOutput("map_terrenos", height=1000))))))
                      )))

server <- function(input, output, session) {
  #### SOBRE
  output$text_about <- renderText({"Este projeto consiste em uma aplicação voltada para o Premio Tesouro Nacional.
  Alethea é um modelo de precificação de ativos imobiliários da União. Este modelo é capaz de mensurar valores de apartamentos, casas e terrenos em
    14 maiores capitais do nosso país. Com isso, o objetivo é elucidar melhor o valor destes ativos, em consonância com normas contábeis e também dar
    mais transparência do valor do patrimônio estatal à sociedade."})
  
  output$logo <- renderImage({return(list(src = "alethea_stn.png", contentType = "image/png", height = 400, width = 700))}, deleteFile = FALSE)
  
  
  #### CONSULTA
  
  #### por apartamento
  
  tab_apart <- reactive({apartamentos_uniao[apartamentos_uniao$preco_predict!="-",] %>% 
      filter(municipio == input$select_apart) %>% select(tipo_imovel, regime_utilizacao, bairro, endereco, area_terreno_total, area_uniao, preco_format)})
  
  apart_count <- reactive({dim(apartamentos_uniao[apartamentos_uniao$preco_predict!="-",] %>% filter(municipio == input$select_apart))[1]})
  
  apart_media_area <- reactive({apartamentos_uniao[apartamentos_uniao$preco_predict!="-",] %>% filter(municipio == input$select_apart) %>% summarize(m = mean(area_uniao))})
  
  apart_media_preco <- reactive({format_real(apartamentos_uniao[apartamentos_uniao$preco_predict!="-",] %>% filter(municipio == input$select_apart) %>% summarize(m = mean(as.numeric(preco_predict))))})
  
  output$apart_count_num <- renderValueBox({
    valueBox(apart_count(), subtitle = "Apartamentos da União na cidade", color = "orange")})
  
  output$apart_area_num <- renderValueBox({
    valueBox(apart_media_area(), subtitle = "Média da área útil da cidade em m2", color = "orange")})
  
  output$apart_preco_num <- renderValueBox({
    valueBox(apart_media_preco(), subtitle = "Média da predição de preços da cidade", color = "orange")})
  
  output$tableAPART <- renderDataTable({tab_apart()}, options = list(pageLength = 15))
  
  ### por casa/residencia
  
  tab_residen <- reactive({residen_uniao[residen_uniao$preco_predict!="-",] %>% 
      filter(municipio == input$select_residen) %>% select(tipo_imovel, regime_utilizacao, bairro, endereco, area_terreno_total, area_uniao, preco_format)})
  
  residen_count <- reactive({dim(residen_uniao[residen_uniao$preco_predict!="-",] %>% filter(municipio == input$select_residen))[1]})
  
  residen_media_area <- reactive({residen_uniao[residen_uniao$preco_predict!="-",] %>% filter(municipio == input$select_residen) %>% summarize(m = mean(area_uniao))})
  
  residen_media_preco <- reactive({format_real(residen_uniao[residen_uniao$preco_predict!="-",] %>% filter(municipio == input$select_residen) %>% summarize(m = mean(as.numeric(preco_predict))))})
  
  output$residen_count_num <- renderValueBox({
    valueBox(residen_count(), subtitle = "Casa/Residen da União na cidade", color = "orange")})
  
  output$residen_area_num <- renderValueBox({
    valueBox(residen_media_area(), subtitle = "Média da área útil da cidade em m2", color = "orange")})
  
  output$residen_preco_num <- renderValueBox({
    valueBox(residen_media_preco(), subtitle = "Média da predição de preços da cidade", color = "orange")})
  
  output$tableRESIDEN <- renderDataTable({tab_residen()}, options = list(pageLength = 15))
  
  ### por terrenos
  
  tab_terr <- reactive({terrenos_uniao[terrenos_uniao$preco_predict!="-",] %>% 
      filter(municipio == input$select_terr) %>% select(tipo_imovel, regime_utilizacao, bairro, endereco, area_terreno_total, area_uniao, preco_format)})
  
  terr_count <- reactive({dim(terrenos_uniao[terrenos_uniao$preco_predict!="-",] %>% filter(municipio == input$select_terr))[1]})
  
  terr_media_area <- reactive({terrenos_uniao[terrenos_uniao$preco_predict!="-",] %>% filter(municipio == input$select_terr) %>% summarize(m = mean(area_uniao))})
  
  terr_media_preco <- reactive({format_real(terrenos_uniao[terrenos_uniao$preco_predict!="-",] %>% filter(municipio == input$select_terr) %>% summarize(m = mean(as.numeric(preco_predict))))})
  
  output$terr_count_num <- renderValueBox({
    valueBox(terr_count(), subtitle = "Terrenos da União na cidade", color = "orange")})
  
  output$terr_area_num <- renderValueBox({
    valueBox(terr_media_area(), subtitle = "Média da área útil da cidade em m2", color = "orange")})
  
  output$terr_preco_num <- renderValueBox({
    valueBox(terr_media_preco(), subtitle = "Média da predição de preços da cidade", color = "orange")})
  
  output$tableTERR <- renderDataTable({tab_terr()}, options = list(pageLength = 15))
  
  
  
  ### MAPAS
  
  ### por apartamentos
  
  output$text_map_apart <- renderText({"Neste mapa consta a localização dos apartamentos da União. Caso queira saber detalhes do imóvel, basta clicar no ícone azul."})
  
  output$map_apartamentos <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addMarkers(data = apartamentos_uniao, clusterOption=markerClusterOptions(), popup = paste0("<b>Municipio: </b>", apartamentos_uniao$municipio,"<br>",
                                                                                                 "<b>UF: </b>", apartamentos_uniao$uf,"<br>",
                                                                                                 "<b>Bairro: </b>", apartamentos_uniao$bairro, "<br>",
                                                                                                 "<b>Endereço:  </b>", apartamentos_uniao$endereco, "<br>",
                                                                                                 "<b> Área:  </b>", apartamentos_uniao$area_uniao, "<br>",
                                                                                                 "<b>Preço predict:  </b>", apartamentos_uniao$preco_format))})
  ### por casa/residencia
  
  output$text_map_residen <- renderText({"Neste mapa consta a localização dos casas/residências da União. Caso queira saber detalhes do imóvel, basta clicar no ícone azul."})
  
  
  output$map_residen <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addMarkers(data = residen_uniao, clusterOption=markerClusterOptions(), popup = paste0("<b>Municipio: </b>", residen_uniao$municipio,"<br>",
                                                                                            "<b>UF: </b>", residen_uniao$uf,"<br>",
                                                                                            "<b>Bairro: </b>", residen_uniao$bairro, "<br>",
                                                                                            "<b>Endereço:  </b>", residen_uniao$endereco, "<br>",
                                                                                            "<b> Área:  </b>", residen_uniao$area_uniao, "<br>",
                                                                                            "<b>Preço predict:  </b>", residen_uniao$preco_format))})
  
  
  ### por terrenos
  
  output$text_map_terr <- renderText({"Neste mapa consta a localização dos terrenos da União. Caso queira saber detalhes do imóvel, basta clicar no ícone azul.."})
  
  
  output$map_terrenos <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addMarkers(data = terrenos_uniao, clusterOption=markerClusterOptions(), popup = paste0("<b>Municipio: </b>", terrenos_uniao$municipio,"<br>",
                                                                                             "<b>UF: </b>", terrenos_uniao$uf,"<br>",
                                                                                             "<b>Bairro: </b>", terrenos_uniao$bairro, "<br>",
                                                                                             "<b>Endereço:  </b>", terrenos_uniao$endereco, "<br>",
                                                                                             "<b> Área:  </b>", terrenos_uniao$area_uniao, "<br>",
                                                                                             "<b>Preço predict:  </b>", terrenos_uniao$preco_format))})
  
  
}  
  
#rsconnect::deployApp("~/Desktop/alethea_stn/app", appName = "alethea_stn")
#runApp(shinyApp(ui, server), launch.browser = TRUE)
shinyApp(ui, server)