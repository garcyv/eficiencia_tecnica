library(readxl)
library(deaR)
library(dbplyr)

library(sqldf)
# DATOS EDUCACION MUNICIPALES http://datos.sinim.gov.cl/datos_municipales.php
dataedu <- read_excel("../data/datos_municipales_con_Corrección_Monetaria_E2019.xlsx")
data_e14 <- sqldf("SELECT id_comuna, `IPEEC (N°)`as Ingreso FROM dataedu WHERE region = '14' ")

# DATOS FINANCIERO MUNICIPALES http://datos.sinim.gov.cl/datos_municipales.php
setwd("c:/Github_RStudioprojects/eficiencia_tecnica/scripts")
datafin <- read_excel("../data/datos_municipales_con_Corrección_Monetaria_F2019.xlsx")
data_f14 <-  sqldf("SELECT id_comuna,provincia,codigo,municipio, BPIIM, BPVGM FROM datafin WHERE region = '14' ")

# DATOS areas verdes  MUNICIPALES http://datos.sinim.gov.cl/datos_municipales.php
dataave <- read_excel("../data/datos_municipales_AV.xlsx")
data_a14 <- sqldf("SELECT CODIGO as 'codigo' , m2_hab FROM dataave")

data_a14 <- data_a14 %>% 
  mutate(m2_hab = ifelse(m2_hab == "No Recepcionado", "0", m2_hab))
data_a14$m2_hab <- as.numeric(data_a14$m2_hab)

# Genera tabla unica por medio de join entre tablas data_x14 "
data_comunas <- sqldf("SELECT data_f14.*, data_a14.m2_hab FROM data_f14 , data_a14 where data_f14.codigo = data_a14.codigo")

data_comunas <- sqldf("SELECT data_comunas.*, data_e14.Ingreso FROM data_comunas , data_e14 where data_comunas.id_comuna = data_e14.id_comuna")


data <- read_data(data_comunas,dmus=4, inputs=5:6, outputs=7:8) 
result <- model_basic(data,  
                      dmu_ref=1:12, 
                      dmu_eval=1:12, 
                      orientation='io', 
                      rts='crs')
efficiencies(result) 
plot(result)


