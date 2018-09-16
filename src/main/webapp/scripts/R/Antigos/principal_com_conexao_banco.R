args<-commandArgs(TRUE) 
area<-as.numeric(args[1])
amostra<-as.numeric(args[2])
desc<-args[3]
interpolador<-args[4]
tamx<-as.numeric(args[5])
tamy<-as.numeric(args[6])
expoente<-as.numeric(args[7])
vizinhos<-as.numeric(args[8])
estimador<-args[9]
nlags<-as.numeric(args[10])
npares<-as.numeric(args[11])  
nro_intervalos_alc<-as.numeric(args[12])
nro_intervalos_contr<-as.numeric(args[13])
usuario<-args[14]

area
amostra
desc
interpolador
tamx
tamy
expoente
vizinhos
estimador
nlags
npares
nro_intervalos_alc
nro_intervalos_contr
usuario


library('RPostgreSQL', lib.loc = 'C:/Users/Dallagnol/Documents/R/win-library/3.2')
pw <- {
  "1"
}
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "db_gstat",
                 host = "localhost", port = 5432,
                 user = "postgres", password = pw)

#MAPEAR O LUGAR NO SERVIDOR AONDE VÃO FICAR AS PASTAS COM AS ANALISES
mainDir <- "D:/ProjetoGstat/src/main/webapp/file"
subDir <- usuario
ifelse(!dir.exists(file.path(mainDir, subDir)), dir.create(file.path(mainDir, subDir)), FALSE)

#AQUI SERA CRIADO A PASTA DE CADA ANALISE DENTRO DA PASTA DE CADA USUÁRIO CUIDAR COM AS INFORMAÇÕES
mainDir <- paste(paste(mainDir,"/",sep = ""),usuario,sep = "")
subDir <- desc
ifelse(!dir.exists(file.path(mainDir, subDir)), dir.create(file.path(mainDir, subDir)), FALSE)

require(geoR)
require(splancs)
require(classInt)
library(stats)
require(MASS)
library(e1071)
require(gstat)
sapply(c("gstat", "sp", "geoR", "RColorBrewer"), require, character.only=T)

arquivo_dados = "D:/ProjetoGstat/src/main/webapp/scripts/dados/Tasca_RSP 0-10 2013_UTM.txt"
arquivo_contorno = "D:/ProjetoGstat/src/main/webapp/scripts/dados/Tasca_contorno_UTM.txt"

dados= read.geodata(arquivo_dados,head=T,coords.col=1:2,data.col=3) 

setwd(paste(paste(mainDir,"/",sep = ""),subDir,sep = ""))
x=paste("boxplot",".png",sep = "")
png(x)
plot(dados)
boxplot(dados$data,main='Gráfico Boxplot')
dev.off()