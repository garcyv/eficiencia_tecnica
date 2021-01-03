library(readxl)
library(FNN)
library(scales)
library(caret)
library(dummies)

# DATOS FINANCIERO MUNICIPALES http://datos.sinim.gov.cl/datos_municipales.php
setwd("c:/Github_RStudioprojects/eficiencia_tecnica/scripts")
datafin <- read_excel("../data/datos_municipales_con_Corrección_Monetaria_F2019.xlsx")

# DATOS EDUCACION MUNICIPALES http://datos.sinim.gov.cl/datos_municipales.php
dataedu <- read_excel("../data/datos_municipales_con_Corrección_Monetaria_E2019.xlsx")

# DATOS areas verdes  MUNICIPALES http://datos.sinim.gov.cl/datos_municipales.php
dataave <- read_excel("../data/datos_municipales_AV.xlsx")

