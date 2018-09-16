args<-commandArgs(TRUE) 
mainDir<-args[1]
dataBaseName<-args[2]
dataBaseHost<-args[3]
dataBaseUser<-args[4]
dataBasePassword<-args[5]
dataBasePort<-args[6]
usuario<-as.numeric(args[7])


# -- PARAMETROS ENVIADOS PELA TELA -- #
area<-as.numeric(args[8])
amostra<-as.numeric(args[9])
expoente <- as.numeric(args[10])  		#se for 0 (zero) será escontrado o melhor expoente, ou define-se o valor do expoente
vizinhos <- as.numeric(args[11]) 		
#exp_inicial <- as.numeric(args[12]) 		
#exp_final <- as.numeric(args[13])  		
#intervalo <- as.numeric(args[14])		
raio <- as.numeric(args[12])	
tam_pixel_x <- as.numeric(args[13]) 
tam_pixel_y <- as.numeric(args[14]) 	
desc <- args[15]

# -- INICIO BIBLIOTECAS UTILIZADAS  -- #
require(geoR)
require(splancs)
require(classInt)
require (sp)
library(stats)
require(MASS)
library(e1071)
require(gstat)
library(ade4)
library(spdep)
library(RPostgreSQL)
library(data.table)
require (gstat) 
# ---- #


# -- MAPEAR O LUGAR NO SERVIDOR AONDE VÃO FICAR AS PASTAS COM AS ANALISES  -- #
subDir <- usuario
ifelse(!dir.exists(file.path(mainDir, subDir)), dir.create(file.path(mainDir, subDir)), FALSE)
mainDir <- paste(paste(mainDir,"/",sep = ""),usuario,sep = "")
subDir <- desc
ifelse(!dir.exists(file.path(mainDir, subDir)), dir.create(file.path(mainDir, subDir)), FALSE)
setwd(paste(paste(mainDir,"/",sep = ""),subDir,sep = ""))
# ---- #


# -- INFORMAÇÕES PARA GRÁFICO  -- #
titulo_pamostrais = "Mapa de dispersão dos pontos amostrais"
fonte_pamostrais = 3
leg_x_pamostrais ="O - L"
leg_y_pamostrais ="S - N"
titulo_BoxPlot = "Gráfico Boxplot"
titulo_PostPlot = "Gráfico Postplot"
titulo_BoxPlot = iconv(titulo_BoxPlot, to="latin1", from="utf-8")
titulo_PostPlot = iconv(titulo_PostPlot, to="latin1", from="utf-8")
# ---- #

classes = 4  	

# -- INFORMAÇÕES E REALIZAÇÃO DA CONEXÃO COM A BASE DE DADOS  -- #
drv <- dbDriver("PostgreSQL")
drv

local = 29182

con <- dbConnect(drv, dbname=dataBaseName,host=dataBaseHost,port=dataBasePort,user=dataBaseUser,password=dataBasePassword)
con

borda =  dbGetQuery(con, paste("SELECT   
						st_x(ST_Transform(ST_SetSRID((dp).geom, 4326),29182)) x ,
						st_y(ST_Transform(ST_SetSRID((dp).geom, 4326),29182)) y								          
						FROM (SELECT ST_DumpPoints(ST_GeomFromText((SELECT ST_AsText(ST_Boundary(geometry)) geom FROM AREA WHERE CODIGO  = ", area, "))) AS dp) As xy"))

atrib = paste("select 
				st_x(st_transform(geometry, 29182)) x, 
				st_y(st_transform(geometry, 29182 )) y, 
				CAST(valor AS numeric) 
				from  pixelamostra 
				where amostra_codigo = ",amostra)

frame_dados <- dbGetQuery(con,atrib)
dados <- as.geodata(frame_dados)


# Gráficos Descritivos 

x=paste("plot_geral",".png",sep = "")
png(x)
plot(dados) 
dev.off()

x=paste("histograma",".png",sep = "")
png(x)
hist(dados$data, main='Histograma')
dev.off()

x=paste("box_plot",".png",sep = "")
png(x)
boxplot(dados$data,main=titulo_BoxPlot) #EXIBIR GRÁFICO (ARMAZENAR)
dev.off()

# ANÁLISE EXPLORATÓRIA ESPACIAL # Grafico Post-plot com legenda para o estudo de tendencia direcional.
x=paste("grafico_pontos",".png",sep = "")
png(x)
points(dados,pt.div="quartile",col=c("yellow","green","red","blue"),main=titulo_PostPlot, xlab=leg_x_pamostrais, ylab=leg_y_pamostrais)
dev.off()


# --   MAPA TEMATICO  GERAL    -- #

is.table(borda)
plot(borda, 
		main=titulo_pamostrais, 
		font.main = fonte_pamostrais,
		xlab=leg_x_pamostrais, 
		ylab=leg_y_pamostrais)
polygon(borda)
points(dados, pch=fonte_pamostrais, add=T)

apply(borda,2,range) #Mostra o mínimo e máximo das coordenadas
menor_X <- min(borda[,1]) #identifica o menor valor de X, primeira coluna 
menor_Y <- min(borda[,2]) #identifica o menor valor de Y, segunda coluna 
maior_X <- max(borda[,1]) #identifica o maior valor de X, primeira coluna 
maior_Y <- max(borda[,2]) #identifica o maior valor de Y, segunda coluna 

gr<-expand.grid(x=seq(menor_X,maior_X, by=tam_pixel_x), y=seq(menor_Y,maior_Y, by=tam_pixel_y))
plot(gr)
points(dados, pt.div="equal") #monta o grid de interpolação

gi<- polygrid(gr,bor=borda)

points(gi, pch="+", col=2) #o novo grid considerando apenas a região limitada


### Criar objeto 'sp'
frame_id <- data.frame(x=dados$coords[,1], y=dados$coords[,2], atrib=dados$data)
names(frame_id)
frame_id
coordinates(frame_id) <- ~x+y
coordinates(frame_id)
atrib~1
class(frame_id)
plot(frame_id, asp=1, axes=T, pch=20)
polygon(borda, border=2)

gridded(gi) = ~x+y

# --  GERA A INTERPOLAÇÃO   -- #
dados.id <- idw(frame_id$atrib~1, frame_id, gi, nmax=vizinhos, idp=expoente)  #Faz o mapa da variável dados por id

str (dados.id)
valores<-dados.id$var1.pred

lng = gi$x
lat = gi$y
medida = valores
interpol <- data.table(cbind(lng, lat, medida))

x=paste("mapa_idw",".png",sep = "")
png(x,width = 700, height = 800, units = "px")
image(interpol,
		col=gray(seq(1,0,l=classes)), 
		xlab=leg_x_pamostrais, 
		ylab=leg_y_pamostrais, 
		cex.lab=1.3, cex.axis=1.3, cex.main=1.3, cex.sub=1.3,
		zlim=range(valores)) 

max_medida = round (max(medida),digits=2)
min_medida = round (min(medida),digits=2)
intervalo = round ((max_medida - min_medida) / 4, digits=2)
intervalo1 = min_medida + intervalo
intervalo2 = intervalo1 + intervalo
intervalo3 = intervalo2 + intervalo
c1 = paste0 (min_medida," --- ",intervalo1)
c2 = paste0 (intervalo1," --- ",intervalo2)
c3 = paste0 (intervalo2," --- ",intervalo3)
c4 = paste0 (intervalo3," --- ",max_medida)
legend("bottomright", fill=gray(c(0.1, 0.4, 0.7, 1.0)),
		c(c4,c3,c2,c1),cex=1.3)	

polygon(borda)
dev.off()

# -- CONSTROI A SQL DO CABEÇALHO DA ANALISE  -- #
seq_header = dbGetQuery(con, " select nextval('geo_analise_header_seq') ")
insertHeader = paste0("INSERT INTO geo_analise_header(
				analise_header_id, 
				descricao_analise,
				area_id, 
				amostra_id, 
				created_by, 
				creation_date, 
				status, 
				tam_pixel_x,
				tam_pixel_y, 
				tipo_analise) ", 
		"VALUES(
				",seq_header,
				",'",desc,"',
				",area,",
				",amostra,",
				",usuario,
				", current_date, 
				'A', 
				",tam_pixel_x, 
				",",tam_pixel_y,
				",'IDW')")
registra <- dbGetQuery(con,insertHeader)
# ---- #

# -- INSERE LINHAS DA INTERPOLADAS  -- #
linhas = 1
nrow(interpol)
#while (linhas <= nrow(interpol)){
	
	seq_interpol = dbGetQuery(con, " select nextval('geo_interpol_lines_seq') ")
	insertInterpol = paste0("INSERT INTO geo_interpol_lines
					(
					interpol_line_id,
					analise_header_id,				
					lng,
					lat,
					medida
					) ", 
			"VALUES
					(							
					",seq_interpol,","							 
					 ,seq_header,","		
					 ,interpol[linhas,lng],","
					 ,interpol[linhas,lat],","
					 ,interpol[linhas,medida],
			")"
	)
	
	
	linhas <- linhas + 1
	registra <- dbGetQuery(con,insertInterpol)
	
#}
# ---- #

dbDisconnect(con)
dev.off()

9999
