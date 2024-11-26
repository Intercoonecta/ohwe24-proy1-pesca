# cargar datos de peso y longitud de merluza
merluza <- readRDS("./datos/merluza_WL.rds")

#ver primeros renglones
head(merluza)

# gráfico tall-peso
plot(merluza$lonPatron, merluza$peso, pch = 16, col = rgb(1, 0, 0, 0.2), 
     cex = 0.7, xlab = "Longitud Patrón (mm)", ylab = "Peso (g)")
