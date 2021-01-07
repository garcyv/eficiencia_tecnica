library(readxl)
library(deaR)
library(dbplyr)
library(tidyverse)
library(sqldf)

setwd("C:/Github_Rstudio_projects/eficiencia_tecnica/scripts")


datapob <- read.csv2("../data/ine_estimaciones-y-proyecciones.csv",sep=",",dec=".",header=TRUE)
# renombra campos para sqldf
datapob <- datapob %>% 
  rename( id_region    = Region, Region = Nombre.Region,
          id_provincia = Provincia, Provincia = Nombre.Provincia,
          id_comuna    = Comuna, Comuna = Nombre.Comuna,
          pob2019      = Poblacion.2019)

# selecciona campos, filtra para Region 14, y agrega datos a nivel de comuna
data_p14 <-sqldf("SELECT id_region, Region, id_provincia, Provincia,id_comuna, Comuna,
                        sum(pob2019) as pob2019
                FROM    datapob 
                WHERE id_region = 14 
                group by id_region, Region, id_provincia, Provincia,id_comuna, Comuna ")

# DATOS EDUCACION MUNICIPALES http://datos.sinim.gov.cl/datos_municipales.php
dataedu <- read_excel("../data/datos_municipales_con_Corrección_Monetaria_E2019.xlsx")
data_e14 <- sqldf("SELECT id_comuna, `IPEEC (N°)`as Ingreso FROM dataedu WHERE region = '14' ")

# DATOS FINANCIEROS MUNICIPALES http://datos.sinim.gov.cl/datos_municipales.php

datafin <- read_excel("../data/datos_municipales_con_Corrección_Monetaria_F2019.xlsx")
data_f14 <-  sqldf("SELECT id_comuna,provincia,codigo,municipio, BPIIM, BPVGM FROM datafin WHERE region = '14' ")

# DATOS areas verdes  MUNICIPALES http://datos.sinim.gov.cl/datos_municipales.php
dataave <- read_excel("../data/datos_municipales_AV.xlsx")
dataave <- dataave %>% 
  mutate(m2_hab = ifelse(m2_hab == "No Recepcionado", "0", m2_hab))
dataave$m2_hab <- as.numeric(dataave$m2_hab)
data_a14 <- sqldf("SELECT CODIGO as 'id_comuna' , m2_hab FROM dataave")

# Indice de desarrollo comunal
data_idc <- read_excel("../data/IDC.xlsx")

# Genera tabla unica por medio de join entre tablas datos población y datos financieros
data_comunas <- sqldf("SELECT data_p14.*, 
                              data_f14.BPIIM/data_p14.pob2019 as BPIIM, 
                              data_f14.BPVGM/data_p14.pob2019 as BPVGM
                         FROM data_p14 , data_f14 
                         WHERE data_p14.id_comuna = data_f14.codigo")
# Añade datos educación
data_comunas <- sqldf("SELECT data_comunas.*, data_e14.Ingreso /data_comunas.pob2019 Ingreso
                         FROM data_comunas , data_e14 
                         WHERE data_comunas.id_comuna = data_e14.id_comuna")

# añade datos indicadores de desarrollo comunal
data_comunas <- sqldf("SELECT data_comunas.*, 
                              data_idc.BIENESTAR as idc_bienestar, 
                              data_idc.ECONOMIA  as idc_economia, 
                              data_idc.EDUCACION as idc_educacion, 
                              data_idc.IDC       as idc_idc 
                      FROM data_comunas , data_idc 
                      WHERE data_comunas.id_comuna = data_idc.id_comuna")

# añade datos areas verdes
data_comunas <- sqldf("SELECT data_comunas.*, data_a14.m2_hab 
                         FROM data_comunas , data_a14 
                         where data_comunas.id_comuna = data_a14.codigo")

# Prepara data y genera modelo
data <- read_data(data_comunas,dmus=4, inputs=5:7, outputs=8:11) 
result <- model_basic(data,  
                      dmu_ref=1:12, 
                      dmu_eval=1:12, 
                      orientation='io', 
                      rts='crs')

# añade datos indicador de eficiencia
data_comunas$ef<-efficiencies(result) 
plot(result)


