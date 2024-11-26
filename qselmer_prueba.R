t <- seq(0, 6, 0.01)
par(mfrow = c(1,3))
# ---------------------------------------------------------------------------------------------
f_logistic <- function(t, pars = list(linf, k, ti)) {
  linf  <- pars$linf
  k     <- pars$k
  ti    <- pars$ti
  lt    <- linf / (1 + exp((ti-t) / k))

  return(lt)
}

lt2 <- f_logistic(t = t , pars = list(linf = 18, k =  0.99, ti = 3))
plot(t, lt2, type = "l", xlab = "Time", ylab = "Length", lwd = 3,
     col = "darkgreen", main = "Logistic Growth Function",
     ylim = c(0, 18.5))
