library(readxl)
library(deaR)
library(dbplyr)
library(tidyverse)
library(sqldf)

setwd("C:/Github_RStudioprojects/eficiencia_tecnica/scripts")
# DATOS EDUCACION MUNICIPALES http://datos.sinim.gov.cl/datos_municipales.php
dataedu <- read_excel("../data/datos_municipales_con_Corrección_Monetaria_E2019.xlsx")
data_e14 <- sqldf("SELECT id_comuna, `IPEEC (N°)`as Ingreso FROM dataedu WHERE region = '14' ")

# DATOS FINANCIERO MUNICIPALES http://datos.sinim.gov.cl/datos_municipales.php

datafin <- read_excel("../data/datos_municipales_con_Corrección_Monetaria_F2019.xlsx")
data_f14 <-  sqldf("SELECT id_comuna,provincia,codigo,municipio, BPIIM, BPVGM FROM datafin WHERE region = '14' ")

# DATOS areas verdes  MUNICIPALES http://datos.sinim.gov.cl/datos_municipales.php
dataave <- read_excel("../data/datos_municipales_AV.xlsx")
dataave <- dataave %>% 
  mutate(m2_hab = ifelse(m2_hab == "No Recepcionado", "0", m2_hab))
dataave$m2_hab <- as.numeric(dataave$m2_hab)
data_a14 <- sqldf("SELECT CODIGO as 'codigo' , m2_hab FROM dataave")

# Indice de desarrollo comunal
dataidc <- read_excel("../data/IDC.xlsx")

# Genera tabla unica por medio de join entre tablas data_x14 "
data_comunas <- sqldf("SELECT data_f14.*, data_e14.Ingreso 
                         FROM data_f14 , data_e14 
                         WHERE data_f14.id_comuna = data_e14.id_comuna")

data_comunas <- sqldf("SELECT data_comunas.*, 
                              dataidc.BIENESTAR as idc_bienestar, 
                              dataidc.ECONOMIA  as idc_economia, 
                              dataidc.EDUCACION as idc_educacion, 
                              dataidc.IDC       as idc_idc 
                      FROM data_comunas , dataidc 
                      WHERE data_comunas.id_comuna = dataidc.id_comuna")

data_comunas <- sqldf("SELECT data_comunas.*, data_a14.m2_hab 
                         FROM data_comunas , data_a14 
                         where data_comunas.codigo = data_a14.codigo")


data <- read_data(data_comunas,dmus=4, inputs=5:7, outputs=8:11) 
result <- model_basic(data,  
                      dmu_ref=1:12, 
                      dmu_eval=1:12, 
                      orientation='io', 
                      rts='crs')

data_comunas$ef<-efficiencies(result) 
plot(result)


