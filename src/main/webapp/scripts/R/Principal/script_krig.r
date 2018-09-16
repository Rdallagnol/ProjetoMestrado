args<-commandArgs(TRUE) 
mainDir<-args[1]
dataBaseName<-args[2]
dataBaseHost<-args[3]
dataBaseUser<-args[4]
dataBasePassword<-args[5]
dataBasePort<-args[6]
usuario<-as.numeric(args[7])
idLines<-as.numeric(args[8])
desc = paste0("mapa_",idLines)

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

options(encoding="UTF8")

###### INICIO ETAPA DE DEFINIÇÃO DE CONFIGURAÇÃO #############
#MAPEAR O LUGAR NO SERVIDOR AONDE VÃO FICAR AS PASTAS COM AS ANALISES
subDir <- usuario
ifelse(!dir.exists(file.path(mainDir, subDir)), dir.create(file.path(mainDir, subDir)), FALSE)

#AQUI SERA CRIADO A PASTA DE CADA ANALISE DENTRO DA PASTA DE CADA USUÁRIO CUIDAR COM AS INFORMAÇÕES
mainDir <- paste(paste(mainDir,"/",sep = ""),usuario,sep = "")
subDir <- desc
ifelse(!dir.exists(file.path(mainDir, subDir)), dir.create(file.path(mainDir, subDir)), FALSE)

#AQUI DEFINE A PASTA QUE DEVE SER ARMAZENADO OS GRÁFICOS
setwd(paste(paste(mainDir,"/",sep = ""),subDir,sep = ""))
############ FIM ETAPA DE DEFINIÇÃO DE CONFIGURAÇÃO #############################

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname=dataBaseName,host=dataBaseHost,port=dataBasePort,user=dataBaseUser,password=dataBasePassword)

sqlAnaliseGeral = paste("select ah.*,
                                al.*, 
				a.descricao desc_amostra 
			 from   geo_analise_lines al, 
				geo_analise_header ah, 
				amostra a 
			 where a.codigo = ah.amostra_id 
			    and ah.analise_header_id = al.analise_header_id 
			    and al.analise_lines_id = ", idLines)
						 
frame_dados <- dbGetQuery(con,sqlAnaliseGeral)
analise_id = frame_dados$analise_header_id
analise_area_id = frame_dados$area_id
analise_amostra_id = frame_dados$amostra_id

## PREENCHE OS PARÃ‚METROS DA ANÃLISE GEOESTATÃSTICA ##

atributo = 'principal' # FIXO

melhor_contrib_geral = frame_dados$melhor_contrib
melhor_alcance_geral = frame_dados$melhor_alcance
melhor_modelo_geral = frame_dados$modelo
melhor_metodo_geral = frame_dados$metodo
melhor_vlr_kappa_geral = frame_dados$melhor_val_kappa 
v_lambda = frame_dados$v_lambda 	  # 1 = dados NÃƒO transformados
auto_lags = frame_dados$auto_lags	  # parametro que define automaticamente o nro de lags
nro_lags = frame_dados$nro_lags 	  #parametro semivariograma KO que estipula o nro de lags arbitrariamente
estimador = frame_dados$estimador     #parametro semivariograma KO 
cutoff = frame_dados$cutoff		      #parametro semivariograma KO - porcentagem da distancia maxima entre os pontos
nro_pares = frame_dados$nro_pares 	  #parametro semivariograma KO
tam_pixel_x = frame_dados$tam_pixel_x #parametro dos mapas
tam_pixel_y = frame_dados$tam_pixel_y #parametros dos mapas
## -- -- ##

## DEFINE O NÃšMERO DE CLASSES DO MAPA ##
classes = 4  	
## -- -- ##


## INFORMAÃ‡Ã•ES PARA GRÃFICOS ##
legenda_x_semiv = iconv("DistÃ¢ncia", to="latin1", from="utf-8")
legenda_y_semiv = iconv("SemivariÃ¢ncia", to="latin1", from="utf-8")
titulo_semiv = iconv("Semivariograma experimental", to="latin1", from="utf-8")
leg_x_pamostrais ="O - L"
leg_y_pamostrais ="S - N"
## -- -- ##

## BUSCA/GERA BORDA DA AREA ##
local = 29182

frame_dados$area_id
sqlSelect = paste("SELECT   
		     	st_x(ST_Transform(ST_SetSRID((dp).geom, 4326),29182)) x ,
		     	st_y(ST_Transform(ST_SetSRID((dp).geom, 4326),29182)) y								          
	          FROM (SELECT ST_DumpPoints(ST_GeomFromText((SELECT ST_AsText(ST_Boundary(geometry)) geom FROM AREA WHERE CODIGO  = ", analise_area_id, "))) AS dp) As xy")

borda <- dbGetQuery(con,sqlSelect)  #em utm
frame_dados$amostra_id

atrib = paste("select 
                    st_x(st_transform(geometry, 29182)) x, 
                    st_y(st_transform(geometry, 29182 )) y, 
                    CAST(valor AS numeric) 
	     from   pixelamostra 
	       where amostra_codigo = ",analise_amostra_id)
				
frame_dados <- dbGetQuery(con,atrib)
dados <- as.geodata(frame_dados)
names(dados)
## -- -- ##

## GERA REPRESENTAÇÃO GRÁFICA DA BORDA ##
x=paste("borda_pontos",".png",sep = "")
png(x)
plot(borda,xlab=leg_x_pamostrais, ylab=leg_y_pamostrais)
polygon(borda)
points(dados, add=T)
dev.off()

## -- -- ##
## GERA INFORMAÇÕES PARA GERAR A GRADE DE INTERPOLAÇÃO ##
apply(borda,2,range)      #Mostra o mÃ­nimo e mÃ¡ximo das coordenadas
menor_X <- min(borda[,1]) #identifica o menor valor de X, primeira coluna 
menor_Y <- min(borda[,2]) #identifica o menor valor de Y, segunda coluna 
maior_X <- max(borda[,1]) #identifica o maior valor de X, primeira coluna 
maior_Y <- max(borda[,2]) #identifica o maior valor de Y, segunda coluna 

gr<-expand.grid(x=seq(menor_X,maior_X,by=tam_pixel_x), y=seq(menor_Y,maior_Y, by=tam_pixel_y))
plot(gr)
points(dados, pt.div="equal") #monta o grid de interpolaÃ§Ã£o
gi<- polygrid(gr,bor=borda)
length(gi$x)
points(gi, pch="+", col=2) #o novo grid considerando apenas a regiÃ£o limitada
length(gr$x)
## -- -- ##

## CONFIGURAÇÕES/PARAMETROS PARA KRIGAGEM ##
max_dist <- max(dist(dados$coords))
min_dist <- min(dist(dados$coords))
vlr_cutoff <- max_dist*cutoff/100 

if (auto_lags==TRUE){
	nro_lags = round(vlr_cutoff/min_dist)	## menor distancia das variancias
}

dados.var <- variog(dados,
		    coords=dados$coords, 
		    data=dados$data,
		    uvec=seq(min_dist,vlr_cutoff,l=nro_lags),
		    lambda=v_lambda,
		    estimator.type=estimador, 
		    max.dist=vlr_cutoff, 
		    pairs.min=nro_pares) 
 

## FAZ O AJUSTE NOVAMENTE COM O MELHOR MODELO ---- ##
if (melhor_modelo_geral == "matern"){
	if (melhor_metodo_geral=="ols"){ 
		variograma.ols<-variofit(dados.var,ini=c(melhor_contrib_geral,melhor_alcance_geral),
						   weights= "equal",
						   cov.model= "matern", 
						   kappa=melhor_vlr_kappa_geral, 
						   max.dist=vlr_cutoff) 
	} else {
		variograma.ols<-variofit(dados.var,ini=c(melhor_contrib_geral,melhor_alcance_geral),
						   cov.model= "matern", 
						   kappa=melhor_vlr_kappa_geral, 
						   max.dist=vlr_cutoff) 
	}
} else {
	if (melhor_metodo_geral=="ols"){
		variograma.ols<-variofit(dados.var,ini=c(melhor_contrib_geral,melhor_alcance_geral),
						   weights= "equal",
						   cov.model= melhor_modelo_geral,
						   max.dist=vlr_cutoff)
	} else {
		variograma.ols<-variofit(dados.var,ini=c(melhor_contrib_geral,melhor_alcance_geral),
						   cov.model= melhor_modelo_geral, 
						   max.dist=vlr_cutoff)
	}
}

## MELHOR MODELO SEMIVARIOGRAMA ##
x=paste("semi_ajust",".png",sep = "")
png(x)
plot(dados.var,
	xlab = legenda_x_semiv, 
	ylab = legenda_y_semiv, 
	main = paste ("Semivariograma ajustado pelo modelo", melhor_modelo_geral,
                                                             melhor_vlr_kappa_geral,
							     melhor_metodo_geral,
							     atributo))
cor_linha = "BLACK"														 
lines(variograma.ols,col=cor_linha,pch=3) 
dev.off()

## -- -- ##

## KRIGAGEM ##

kC = krige.control(obj=variograma.ols,	
         	   lambda=v_lambda,
		   micro.scale=0)
#krigagem 

dados.kC = krige.conv(dados, loc=gi, krige=kC) #Faz o mapa da variÃ¡vel dados por krigagem ordinÃ¡ria
length(dados.kC$pred)

max(dados.kC$pred)
min(dados.kC$pred)
valores<-dados.kC$predict
range(dados.kC$predict)

## MAPA ##
x=paste("mapa",".png",sep = "")
png(x,width = 700, height = 800, units = "px")

image(dados.kC, 
      loc=gr, 
      border=borda, 
      col=gray(seq(1,0,l=classes)),
      xlab=leg_x_pamostrais,
      ylab=leg_y_pamostrais,
	  cex.lab=1.3, cex.axis=1.3, cex.main=1.3, cex.sub=1.3,
      zlim=range(dados.kC$predict))


max_medida = round (max(valores),digits=2)
min_medida = round (min(valores),digits=2)
intervalo = round ((max_medida - min_medida) / 4, digits=2)
intervalo1 = min_medida + intervalo
intervalo2 = intervalo1 + intervalo
intervalo3 = intervalo2 + intervalo
c1 = paste0 (min_medida," --- ",intervalo1)
c2 = paste0 (intervalo1," --- ",intervalo2)
c3 = paste0 (intervalo2," --- ",intervalo3)
c4 = paste0 (intervalo3," --- ",max_medida)
legend("bottomright",  plot = TRUE, fill=gray(c(0.1, 0.4, 0.7, 1.0)),
		c(c4,c3,c2,c1),cex=1.3)	

zlim=range(dados.kC$predict)
dev.off()


########################################################
lng = gi$x
lat = gi$y
medida = valores
interpol <- data.table(cbind(lng, lat, medida))

linhas = 1
#while (linhas <= nrow(interpol)){
	
	#seq_interpol = dbGetQuery(con, " select nextval('geo_interpol_lines_seq') ")
	#insertInterpol = paste0("INSERT INTO geo_interpol_lines
	#							(
	#							interpol_line_id,
	#							analise_header_id,
     #                           analise_line_id,
	#							lng,
	#							lat,
	#							medida
	#							) ", 
	#					"VALUES
	#							(							
	#							",seq_interpol,","							 
	#							 ,analise_id,","
     #                            ,idLines,","
	#							 ,interpol[linhas,lng],","
	#							 ,interpol[linhas,lat],","
	#							 ,interpol[linhas,medida],
	##							")"
	#					)
	#registra <- dbGetQuery(con,insertInterpol)
   # linhas <- linhas + 1
#}

atualizaLine = paste0(" UPDATE GEO_ANALISE_LINES SET MAPA_GERADO = 1 WHERE ANALISE_LINES_ID = ", idLines)
registra <- dbGetQuery(con,atualizaLine)
dbDisconnect(con)
dev.off()

9999
