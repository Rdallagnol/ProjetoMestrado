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
nalcance<-as.numeric(args[12])
ncontri<-as.numeric(args[13])
usuario<-args[14]
modelo<-args[15]
vlkappa<-as.numeric(args[16])
semicorlinha<-args[17]
metodoajust<-args[18]
pesos<-args[19]
expoini<-as.numeric(args[20])
expofinal<-as.numeric(args[21])
expoinv<-as.numeric(args[22])

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
nalcance
ncontri
usuario
modelo
vlkappa
semicorlinha
metodoajust
pesos
expoini
expofinal
expoinv

#MAPEAR O LUGAR NO SERVIDOR AONDE VÃO FICAR AS PASTAS COM AS ANALISES
mainDir <- "D:/ProjetoGstat/src/main/webapp/file"
subDir <- usuario
ifelse(!dir.exists(file.path(mainDir, subDir)), dir.create(file.path(mainDir, subDir)), FALSE)

#AQUI SERA CRIADO A PASTA DE CADA ANALISE DENTRO DA PASTA DE CADA USUÁRIO CUIDAR COM AS INFORMAÇÕES
mainDir <- paste(paste(mainDir,"/",sep = ""),usuario,sep = "")
subDir <- desc
ifelse(!dir.exists(file.path(mainDir, subDir)), dir.create(file.path(mainDir, subDir)), FALSE)

#AQUI DEFINE A PASTA QUE DEVE SER ARMAZENADO OS GRÁFICOS
setwd(paste(paste(mainDir,"/",sep = ""),subDir,sep = ""))

require(geoR)
require(splancs)
require(classInt)
require(sp)
library(stats)
require(MASS)
library(e1071)
require(gstat)
library(ade4)
library(spdep)
library(RPostgreSQL)

arquivo_dados = "D:/ProjetoGstat/src/main/webapp/scripts/dados/Tasca_RSP 0-10 2013_UTM.txt"
arquivo_contorno = "D:/ProjetoGstat/src/main/webapp/scripts/dados/Tasca_contorno_UTM.txt"
dados= read.geodata(arquivo_dados,head=T,coords.col=1:2,data.col=3) 

x=paste("boxplot",".png",sep = "")
png(x)
plot(dados)
boxplot(dados$data,main='Gráfico Boxplot')
dev.off()

