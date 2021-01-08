library(readxl)
library(deaR)
library(dbplyr)
library(tidyverse)
library(sqldf)

setwd("C:/Github_Rstudio_projects/eficiencia_tecnica/scripts")

# Carga datos poblacion
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


# DATOS FINANCIEROS MUNICIPALES http://datos.sinim.gov.cl/datos_municipales.php

datafin <- read_excel("../data/datos_municipales_con_Corrección_Monetaria_F2019.xlsx")
data_f14 <-  sqldf("SELECT id_comuna,
                           IADM85  as G_Bienes_Serv,
                           IADM79  as G_Personal_Contrata,
                           IADM78  as G_Personal_Planta,
                           IADM111 as G_Comunitarios ,
                           IADM76  as G_Transf_Educ,
                           IADM77  as G_Transf_Salud 
                    FROM datafin 
                   WHERE region = '14' ")


# Indice de desarrollo comunal
data_idc <- read_excel("../data/IDC.xlsx")

# Genera tabla unica por medio de join entre tablas datos población y datos financieros
data_comunas <- sqldf("SELECT data_p14.*, 
                           data_f14.G_Bienes_Serv/data_p14.pob2019       G_Bienes_Serv,
                           data_f14.G_Personal_Contrata/data_p14.pob2019 G_Personal_Contrata,
                           data_f14.G_Personal_Planta/data_p14.pob2019   G_Personal_Planta,
                           data_f14.G_Comunitarios/data_p14.pob2019      G_Comunitarios,
                           data_f14.G_Transf_Educ/data_p14.pob2019       G_Transf_Educ,
                           data_f14.G_Transf_Salud/data_p14.pob2019      G_Transf_Salud
                         FROM data_p14 , data_f14 
                         WHERE data_p14.id_comuna = data_f14.id_comuna")

# añade datos indicadores de desarrollo comunal
data_comunas <- sqldf("SELECT data_comunas.*, 
                              data_idc.BIENESTAR as idc_bienestar, 
                              data_idc.ECONOMIA  as idc_economia, 
                              data_idc.EDUCACION as idc_educacion, 
                              data_idc.IDC       as idc_idc 
                      FROM data_comunas , data_idc 
                      WHERE data_comunas.id_comuna = data_idc.id_comuna")

# Genera data con resumen de columnas gasto personal y renombra inputs, y outputs
data <- sqldf("SELECT data_comunas.id_comuna, 
                      data_comunas.Comuna            as  DMU,
                      data_comunas.G_Bienes_Serv     as   I_GBienesServicios,
                      data_comunas.G_Personal_Contrata + 
                      data_comunas.G_Personal_Planta as   I_GPersonal,
                      data_comunas. G_Comunitarios   as   I_GComunitarios, 
                      data_comunas.G_Transf_Educ     as   I_GEducacion ,
                      data_comunas.G_Transf_Salud    as   I_GSalud,
                      data_comunas.idc_bienestar     as   O_idc_bienestar, 
                      data_comunas.idc_bienestar     as   O_idc_economia, 
                      data_comunas.idc_educacion     as   O_idc_educacion, 
                      data_comunas.idc_idc           as   O_idc_idc 
                      FROM data_comunas ")

# Prepara data y genera modelo orientado al ouput
data.model <- read_data(data,dmus=2, inputs=3:7, outputs=8:11) 
result <- model_basic(data.model,  
                      dmu_ref=1:12, 
                      dmu_eval=1:12, 
                      orientation='oo', 
                      rts='crs')

# añade datos indicador de eficiencia
data_comunas$ef<-efficiencies(result) 
efficiencies(result) 
# Valdivia     Corral  Lanco    Los Lagos     
# 1.00000     3.49210  1.00000  1.00000    

# Máfil   Mariquina   Paillaco  Panguipulli 
# 1.25650     1.11310     1.00000     1.54851 

# La Unión     Futrono  Lago Ranco   Río Bueno 
#  1.05513     1.34416     1.00000     1.00000 


plot(result)



