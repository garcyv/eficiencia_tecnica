rm(list=ls())
setwd("C:/Github_RStudioprojects/eficiencia_tecnica/scripts")

# Carga data

load("../data/mapa14.RData")
load("../data/data_comunas.RData")
load("../data/comunas_sp.RData")

#GRAFICO LEAFLET
palnumeric <-  colorNumeric("inferno",  domain = mapa14$ef)
palnumeric2 <- colorNumeric("viridis", domain = mapa14$ef)

palBin <-      colorBin("viridis",      domain = mapa14$idc_idc, bins = 5)
palBin2 <-     colorBin("inferno",      domain = mapa14$idc_idc, bins = 7)

popup <- paste0( "Comuna: ", "</b>", data_comunas$Comuna, "<br>",
                 "Provincia: ", "</b>", data_comunas$Provincia, "<br>",
                 "<br>", "<b>", "Poblacion: ", "</b>", data_comunas$pob2019, "<br>", 
                 "<b>", "Eficiencia: ", "</b>", round(data_comunas$ef,3), "<br>", "<b>", 
                 "IDC: ", "</b>",round(data_comunas$idc_idc, 3), "<br>", "<b>"
               )


leaflet(mapa14)  %>% addTiles() %>%
  # Funcion para agregar poligonos
  addPolygons(data=mapa14, 
              color = "#444444",
              weight = 1,
              smoothFactor = 0.5, 
              opacity = 1, fillOpacity = 0.5, 
              fillColor = ~palBin(mapa14$idc_idc), 
              group = "IDC", highlightOptions = highlightOptions(color = "white", weight = 1, 
                                                                 bringToFront = TRUE), label = ~mapa14$Comuna, 
                                                                 labelOptions = labelOptions(direction = "auto"), 
              popup = popup)  %>% 
  addPolygons(data =mapa14,
              color = "#444444",
              weight = 1, 
              smoothFactor = 0.5, 
              opacity = 1, fillOpacity = 0.5, 
              fillColor = ~palnumeric2(mapa14$ef), 
              group = "Eficiencia", highlightOptions = highlightOptions(color = "white", weight = 1, 
                                                                        bringToFront = TRUE), label =  ~mapa14$Comuna, 
                                                                       labelOptions = labelOptions(direction = "auto"), 
              popup = popup) %>% 
  addLegend(position = "bottomleft", pal = palBin, values = ~mapa14$idc_idc, 
            title = "IDC") %>% 
  addLayersControl(baseGroups = c("Eficiencia", "IDC")) %>% 
  addLegend(position = "topright", pal = palnumeric2, values = mapa14$ef,
            title = "EFICIENCIA") 
  
 
# GRAFICO GGPLOT

library(ggspatial)
mlabel= paste0(data_comunas_sp$Comuna,"\n",
               " ( IDC: ",data_comunas_sp$idc_idc, ")"
              )

  ggplot()+
  geom_sf(data=mapa14,aes(fill= idc_idc))+
    labs( title    = "Region de Los Rios",
          subtitle = "Indice de Desarrollo Comunal",
          caption  = "Realizado por: Garcy Valenzuela P.",
          fill     = "IDC",
          x = element_blank(),y=element_blank()) +
  annotation_scale() +
  scale_fill_viridis_c()+
 annotation_north_arrow(location='tr')+
  theme_bw()+
  theme(
    plot.title = element_text(size = 12, hjust = 0.5),
    plot.subtitle = element_text(size = 9, hjust = 0.5),
    axis.text.x = element_text("Longitud"),
    axis.text.y = element_text("Latitud"),
    axis.ticks =  element_blank(),
    axis.title = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )+
    geom_text(data=data_comunas_sp,aes(clon,clat,label=mlabel),color="orange",size=3.0)
