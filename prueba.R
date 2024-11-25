# cargar datos de peso y longitud de merluza
merluza <- readRDS("./datos/merluza_WL.rda")

#ver primeros renglones
head(merluza)

# gráfico tall-peso
plot(merluza$lonPatron, merluza$peso)
