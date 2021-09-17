<p align="center">
  <img width="750" height="450" src="https://github.com/pbizil/alethea_stn/blob/main/alethea_stn.png">
</p>

Este projeto consiste em uma aplicação voltada para o [XXVI Prêmio Tesouro Nacional 2021](https://www.gov.br/tesouronacional/pt-br/tesouro-educacional/premio-tesouro), na categoria "Soluções", realizado pela Secretaria do Tesouro Nacional. 

Este projeto consiste em uma aplicação voltada para o Premio Tesouro Nacional. Alethea é um modelo de precificação de ativos imobiliários da União. Este modelo é capaz de mensurar valores de apartamentos, casas e terrenos em 14 maiores capitais do nosso país. Com isso, o objetivo é elucidar melhor o valor destes ativos, em consonância com normas contábeis e também dar mais transparência do valor do patrimônio estatal à sociedade.



## Stack de ferramentas e tecnologia

- Linguagem Python para coleta, organização dos dados, além da criação dos modelos do Atlethea;
- Linguagem R para visualização dos dados;
- [Selenium](https://github.com/SeleniumHQ/selenium) e [BeautifulSoup](https://beautiful-soup-4.readthedocs.io/en/latest/) para scrapping;
- [LightGBM](https://github.com/microsoft/LightGBM) como framework de gradient boosting para construção dos modelos;
- [Scikit-Optimize](https://github.com/scikit-optimize/scikit-optimize) para construção das rotinas de otimização de hiperparâmetros;
- [Leaflet](https://github.com/Leaflet/Leaflet) para construção dos mapas;
- [Shiny](https://github.com/rstudio/shiny) para web application.

## Modelagem 

- Produziu-se modelos de precifição para três tipos de imóveis da União: apartamentos, casa/residência e terrenos;
- Devido a disponibilidade de dados, restringiu-se a precificação dos imóveis apenas para as 14 maiores capitais do Brasil;
- Utilizou-se o LGBMRegressor como algoritmo de aprendizado de máquina;
- Para busca de melhores hiperparâmetros, utilizou-se a otimização bayesiana;
- A métrica de minimização foi o RMSLE. 

Para entender mais o processo de modelagem, consultar os notebooks desse repositório.

## Features do dashboard

O Alethea.dash é 


## Dados e scrapping 

- Dados referentes a imóveis da União foram coletados no [dataset](https://dados.gov.br/dataset/imoveis-da-uniao/resource/2a2cf651-3f93-4ce3-96a4-7df0a6d2d1e5) disponibilizado nos dados abertos do governo federal.

- Os dados referentes a preços de imóveis foram coletados via scrapping do site [Viva Real](https://www.vivareal.com.br/) - *Sorry, guys! I just got a small part of your content website :upside_down_face:*. Coletou-se dados de preços, endereço e área útil de apartamentos, casas e terrenos das 14 maiores capitais do país. Todo esse trabalho precisou ser feito via Selenium devido a restrições de requisição de javascript das páginas.  




