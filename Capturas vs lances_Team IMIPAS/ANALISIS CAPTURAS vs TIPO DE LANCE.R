## ANÁLISIS PAÍSES VS ARTES DE PESCA ##

library(tidyverse)
library(dplyr)
library(visdat)
library(ggplot2)
library(tidyr)
library(cowplot)
library(sf)
library(rnaturalearth)
library(RColorBrewer)
library(DT)
library(satin)


##Datos
datosFlag <- read.csv("PublicPSTunaFlag.csv", header = T)
str(datosFlag)

datosSet <-  read.csv("PublicPSTunaSetType.csv", header = T)
str(datosSet)

df <- data.frame(codeSp = c("ALB", "BET", "BKJ", "BZX", "FRZ", "PBF",
                            "SKJ", "TUN", "YFT"),
                 especie = c("Albacora (atún blanco)", "Patudo (ojo grande)",
                             "Barrilete negro", "Bonito",
                             "Melva y melvera", "Aleta azul del Pacífico",
                             "Barrilete", "Atunes, nep*", "Aleta amarilla"))
summary(datosSet)
summary(datosFlag)

##Capturas anuales por país/tipo de lance

cap_lances <- datosSet %>%
  select(Year, Month, SetType, LatC1, LonC1, NumSets, ALB, BET, BKJ, BZX, FRZ, PBF, SKJ, TUN, YFT)

cap_anual <- cap_lances %>%
  group_by(SetType)%>%
  summarise(Captura_Total = sum(ALB, na.rm = TRUE) + sum(BET, na.rm = TRUE) +
      sum(BKJ, na.rm = TRUE) + sum(BZX, na.rm = TRUE) + sum(FRZ, na.rm = TRUE) +
      sum(PBF, na.rm = TRUE) + sum(SKJ, na.rm = TRUE) + sum(TUN, na.rm = TRUE) +
      sum(YFT, na.rm = TRUE),
      NumSets_Total = sum(NumSets, na.rm = TRUE),
      Captura_Por_Lance = Captura_Total / NumSets_Total) %>%
  ungroup()


cap_anualSET <- cap_lances %>%
  group_by(SetType, Year)%>%
  summarise(Captura_Total = sum(ALB, na.rm = TRUE) + sum(BET, na.rm = TRUE) +
              sum(BKJ, na.rm = TRUE) + sum(BZX, na.rm = TRUE) + sum(FRZ, na.rm = TRUE) +
              sum(PBF, na.rm = TRUE) + sum(SKJ, na.rm = TRUE) + sum(TUN, na.rm = TRUE) +
              sum(YFT, na.rm = TRUE),
            NumSets_Total = sum(NumSets, na.rm = TRUE),
            Captura_Por_Lance = Captura_Total / NumSets_Total) %>%
  ungroup()

cap_anualSP <- cap_lances %>%
  group_by(SetType, ALB, BET, BKJ, BZX, FRZ, PBF, SKJ, TUN, YFT)%>%
  summarise(Captura_Total = sum(ALB, na.rm = TRUE) + sum(BET, na.rm = TRUE) +
              sum(BKJ, na.rm = TRUE) + sum(BZX, na.rm = TRUE) + sum(FRZ, na.rm = TRUE) +
              sum(PBF, na.rm = TRUE) + sum(SKJ, na.rm = TRUE) + sum(TUN, na.rm = TRUE) +
              sum(YFT, na.rm = TRUE),
            NumSets_Total = sum(NumSets, na.rm = TRUE),
            Captura_Por_Lance = Captura_Total / NumSets_Total) %>%
  ungroup()


cap_anualSPdISCOORD <- cap_lances %>%
  group_by(SetType, Year, Month, LatC1, LonC1, BET, SKJ, YFT)%>%
  summarise(Captura_Total = sum(ALB, na.rm = TRUE) + sum(BET, na.rm = TRUE) +
              sum(BKJ, na.rm = TRUE) + sum(BZX, na.rm = TRUE) + sum(FRZ, na.rm = TRUE) +
              sum(PBF, na.rm = TRUE) + sum(SKJ, na.rm = TRUE) + sum(TUN, na.rm = TRUE) +
              sum(YFT, na.rm = TRUE),
            NumSets_Total = sum(NumSets, na.rm = TRUE),
            Captura_Por_Lance = Captura_Total / NumSets_Total) %>%
  ungroup()

#Gráfico capturas totales por lance
# Calcular los porcentajes
cap_anual$Porcentaje <- cap_anual$Captura_Total / sum(cap_anual$Captura_Total) * 100

# Crear el gráfico de pastel
ggplot(cap_anual, aes(x = "", y = Captura_Total, fill = SetType)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar(theta = "y") +
  geom_text(aes(label = paste0(round(Porcentaje, 1), "%")),
            position = position_stack(vjust = 0.5), size = 5) +
  scale_fill_manual(values = c("skyblue", "orange", "lightgreen")) +
  theme_void() +
  labs(title = "Capturas totales por tipo de lance",
       fill = "Tipo de lance")


#Gráfico capturas anuales por tipo de lance

Year <- range(cap_anualSET$Year)

g1 <- ggplot(cap_anualSET, aes(x = Year, y = Captura_Por_Lance, colour = SetType)) +
  geom_line(  ) +

g1

summary(cap_anualSP)
summary(cap_anualSPdISCOORD)

###################################################################################

# Agrupar y resumir los datos
CapTG <- cap_anualSPdISCOORD %>%
  group_by(LatC1, LonC1, Year) %>%
  summarise(
    Captura_Total = sum(BET, na.rm = TRUE) + sum(SKJ, na.rm = TRUE) + sum(YFT, na.rm = TRUE),
    .groups = "drop"
  )
# Convertir a objeto sf con un CRS adecuado (EPSG:4326)
CapTG_sf <- st_as_sf(CapTG, coords = c("LonC1", "LatC1"), crs = 4326)

# Cargar datos geográficos (mapa base)
sf_land <- ne_countries(scale = "medium", returnclass = "sf")

# Crear el gráfico
CaptGEO <- ggplot() +
  geom_sf(data = sf_land, fill = "gray90", color = "white") +  # Mapa base
  geom_tile(data = CapTG, aes(x = LonC1, y = LatC1, fill = Captura_Total)) +
  scale_fill_viridis_c(name = "Captura Total") +  # Escala de color
  facet_wrap(~Year) +
  coord_sf() +
  theme_minimal() +
  labs(title = "Distribución de la Captura Total por Año y Ubicación")

CaptGEO
