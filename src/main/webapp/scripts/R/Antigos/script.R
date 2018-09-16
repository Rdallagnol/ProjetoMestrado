myq = seq(0.005,0.995,by=0.005) 
q = qf(myq,  11, 21, ) 
dp = df(q,  11, 21, ) 
setwd("D:/ProjetoGstat/src/main/webapp/file")
x=paste("Rodrigo",".png")
png(x)
plot(dp ~ q,type="l",main="Exemplo de Grafico", ylab="y", xlab="x")
dev.off()
    