args<-commandArgs(TRUE) 
area<-as.numeric(args[1])
amostra<-as.numeric(args[2])
desc<-args[3]
interpolador<-args[4]
tam_pixel_x<-as.numeric(args[5])
tam_pixel_y<-as.numeric(args[6])
expoente<-as.numeric(args[7])
vizinhos<-as.numeric(args[8])
estimador<-args[9]
nro_lags<-as.numeric(args[10])
nro_pares<-as.numeric(args[11])  
nro_intervalos_alc<-as.numeric(args[12])
nro_intervalos_contr<-as.numeric(args[13])
usuario<-args[14]
modelo<-args[15]
vlr_kappa<-as.numeric(args[16])
cor_linha<-args[17]
metodoajust<-args[18]
pesos<-args[19]
expoini<-as.numeric(args[20])
expofinal<-as.numeric(args[21])
expoinv<-as.numeric(args[22])


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

###########################################################################
# DOWNLAODS NECESSÁRIOS
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
###########################################################################

interpolador
expoente
vizinhos
nro_lags 
estimador
nro_pares
nro_intervalos_alc
nro_intervalos_contr
vlr_kappa
cor_linha
metodoajust

#variável que identifica o tamanho do pixel do mapa final
tam_pixel_x
tam_pixel_y

#variáveis para gráfico Semivariograma
legenda_x_semiv = "Distância"
legenda_y_semiv = "Semivariância"
titulo_semiv = "Semivariograma experimental"

#Variáveis do gráfico Mapa de dispersão dos pontos amostrais
titulo_pamostrais = "Mapa de dispersão dos pontos amostrais"
fonte_pamostrais = 3
leg_x_pamostrais ="O - L"
leg_y_pamostrais ="S - N"

titulo_BoxPlot = "Gráfico Boxplot"
titulo_PostPlot = "Gráfico Postplot"

#número de classe no mapa (intervalos)
classes = 5;

#########################################################
# Estabelece conexão com o PoststgreSQL usando RPostgreSQL
drv <- dbDriver("PostgreSQL")

projeto = "db_projeto_id2_tasca"
atributo = "tb_produtividade"
local = 29192

con <- dbConnect(drv, dbname=projeto,host="localhost",port=5432,user="postgres",password="1")

#preciso usar esta conversão porque as coordenadas não são do tipo the_geom e sim Long Lat
#Contorno
contorno_LL <- dbGetQuery(con,"select x, y from tb_borda")

coordinates(contorno_LL) <- ~ x + y #longitude first
coordinates(contorno_LL)
proj4string(contorno_LL) <- CRS("+proj=longlat +datum=WGS84")
contorno_UTM <- spTransform(contorno_LL, CRS("+proj=utm +south +zone=22 ellps=WGS84"))
x=contorno_UTM$x
y=contorno_UTM$y
borda = cbind(x,y)

#leitura dos dados da tabela de atributos do banco de dados
atrib = paste("select st_x(st_transform(the_geom,", local, ")), st_y(st_transform(the_geom, ", local, ")),amo_medida from ", atributo)
frame_dados <- dbGetQuery(con,atrib)

dados <- as.geodata(frame_dados)
names(dados)

############################################################

#Análise exploratória dos dados
summary(dados$data)
mean (dados$data) 
var(dados$data)
sd(dados$data)
CV = sd(dados$data)*100/mean(dados$data)

skewness(dados$data)
kurtosis(dados$data)

# Gráficos Descritivos 

x=paste("plot",".png",sep = "")
png(x)
plot(dados) # GERAR HISTOGRAMA
dev.off()

x=paste("boxsplot",".png",sep = "")
png(x)
boxplot(dados$data,main=titulo_BoxPlot) #EXIBIR GRÁFICO (ARMAZENAR)
dev.off()

# ANÁLISE EXPLORATÓRIA ESPACIAL # Grafico Post-plot com legenda para o estudo de tendencia direcional.
x=paste("postplot",".png",sep = "")
png(x)
points(dados,pt.div="quartile",col=c("yellow","green","red","blue"),main=titulo_PostPlot, xlab=leg_x_pamostrais, ylab=leg_y_pamostrais)
dev.off()

##########################################################################################
#######################   MAPA TEMATICO  GERAL    #########################################
## borda

is.table(borda)
x=paste("dispersao",".png",sep = "")
png(x)
plot(borda, main=titulo_pamostrais, font.main = fonte_pamostrais,xlab=leg_x_pamostrais, ylab=leg_y_pamostrais)
polygon(borda)
points(dados, pch=fonte_pamostrais, add=T)
dev.off()

apply(borda,2,range) #Mostra o mínimo e máximo das coordenadas
menor_X <- min(borda[,1]) #identifica o menor valor de X, primeira coluna 
menor_Y <- min(borda[,2]) #identifica o menor valor de Y, segunda coluna 
maior_X <- max(borda[,1]) #identifica o maior valor de X, primeira coluna 
maior_Y <- max(borda[,2]) #identifica o maior valor de Y, segunda coluna 


x=paste("gridinterpolacao",".png",sep = "")
png(x)
gr<-expand.grid(x=seq(menor_X,maior_X,by=tam_pixel_x), y=seq(menor_Y,maior_Y, by=tam_pixel_y))
plot(gr)
points(dados, pt.div="equal") #monta o grid de interpolação
gi<- polygrid(gr,bor=borda)
length(gi$x)
points(gi, pch="+", col=2) #o novo grid considerando apenas a região limitada
length(gr$x)
dev.off()

interpolador
if (interpolador == "KO"){
	# ANÁLISE ESPACIAL
	# Calcular a maior e menor distancia da área considerando as coordenadas dados$coords para obter o cutoff de 50% da distancia maxima
	max_dist <- max(dist(dados$coords))
	min_dist <- min(dist(dados$coords))
	cutoff <- max(dist(dados$coords)/2) 
	max_dist
	min_dist
	cutoff

	dados.var <- variog(dados,coords=dados$coords, data=dados$data,uvec=seq(0,cutoff,l=nro_lags),estimator.type=estimador, max.dist=cutoff,pairs.min=nro_pares) 

	dados.var
	plot(dados.var, xlab = legenda_x_semiv, ylab = legenda_y_semiv, main = titulo_semiv)  

	# Informações do semivariograma experimental
	distancia <-  dados.var$u 
	semivariancia <- dados.var$v
	pares <- dados.var$n
	tabela <- cbind(distancia,semivariancia,pares)
	tabela

## para ajustar os valores para o semivariograma
	min_var = min(semivariancia) # menor variância 
	max_var = max(semivariancia) # maior variância
	min_var
	max_var

############# 19/05/2016 - bt
############# criar matriz para tentar encontrar melhor valores 
	vals <- expand.grid(seq(0.1, max_var, l=nro_intervalos_contr),seq(min_dist, cutoff, l=nro_intervalos_alc)) 
	plot(dados.var,xlab='Distância',ylab='Semivariância',main= paste ("Semivariograma ajustado por OLS -",atributo) )

	cont = nro_intervalos_contr * nro_intervalos_alc
	cont
	
	#cria matriz para armazenar informações do ice
	matriz_ice<-matrix(nrow=0,ncol=6,dimnames = list(c(),c("modelo","metodo","min_ice", "melhor_contrib", "melhor_alcance", "melhor_vlr_kappa" )))

	vetor_ice = c()  ### vetor para armazenar o menor ice de cada molelo

			t_cor_linha_ols = data.table(rbind("BLUE", "GREEN", "RED", "YELLOW", "BLACK"))
			t_modelos = data.table(rbind("matern", "matern", "matern", "gaus", "exp","matern", "matern", "matern", "gaus", "exp"))
			t_modelos
			t_kappa = data.table(rbind(1.0, 1.5, 2.0, 0.5, 0.5,1.0, 1.5, 2.0, 0.5, 0.5))
			t_kappa 
			nro_modelo=10
	j=0
	j
	nro_modelo
	metodo="ols"


while (j<nro_modelo)
{


			#cria matriz para armazenar informações da validação cruzada
			matriz_vc<-matrix(nrow=0,ncol=8,
			dimnames = list(c(),c("Modelo", "EM", "EMR", "DP_EM", "DP_EMR", "DP_EMR_1", "EA","Metodo")))

			#cria vetores para armazenar informações da validação cruzada
			vetor_em = c()
			vetor_emr = c()
			vetor_dp_em = c()
			vetor_dp_emr = c()
			vetor_dp_emr_1 = c()
			vetor_ea = c()
			vetor_modelo = c()
			vetor_metodo =c()
			ice = c()
			A = c()
			B = c()
			vetor_contr = c()
			vetor_alcance = c()
			vetor_vlr_kappa = c()

	j=j+1
	j
	modelo = t_modelos$V1[j]
	vlr_kappa = as.numeric(t_kappa$V1[j])
	cor_linha_ols = t_cor_linha_ols$V1[j]
	
	if (j==((nro_modelo/2)+1)){
		metodo="wl"
	}

	modelo
	vlr_kappa
	i=0
	i
	cont
	t_cont = 0  # zera a variável que armazena o tamanho da tabela table_ice de cada modelo# bt 23/05/2016

	while (i<cont)
	{
		i= i+1
		i
		contrib = as.numeric(vals$Var1[i])
		alcance = as.numeric(vals$Var2[i])
		contrib
		alcance

		if (modelo=="matern"){
			if (metodo=="ols"){
				variograma.ols<-variofit(dados.var,ini=c(contrib,alcance),weights= "equal",cov.model= modelo, kappa= vlr_kappa)
			} else {
				variograma.ols<-variofit(dados.var,ini=c(contrib,alcance),cov.model= modelo, kappa= vlr_kappa)
			}
		} else {
			if (metodo=="ols"){
				variograma.ols<-variofit(dados.var,ini=c(contrib,alcance),weights= "equal",cov.model= modelo)
			} else {
				variograma.ols<-variofit(dados.var,ini=c(contrib,alcance),cov.model= modelo)
			}
		}
		lines(variograma.ols,col=cor_linha_ols)

		#armazena informções da validação cruzada em variáveis
		vc=xvalid(dados,model=variograma.ols)
		mean (vc$std.error)

		if ((mean (vc$std.error) != "NaN"))
		{

			em = mean (vc$error) #erro médio
			emr = round(mean (vc$std.error),digits=5) #erro médio reduzido
			dp_em = sd (vc$error) #desvio padrão do erro médio
			dp_emr = sd (vc$std.error) #desvio padrão do erro médio reduzido
			dp_emr_1 = (sd (vc$std.error))-1 #desvio padrão do erro médio reduzido - 1
			ea=sum(abs(vc$predicted-vc$data))  	#armazenar informções do erro absoluto

			#popula vetores com informações da validação cruzada
			vetor_em <- rbind(vetor_em,c(em))
			vetor_emr = rbind(vetor_emr,c(emr))
			vetor_dp_em = rbind(vetor_dp_em,c(dp_em))
			vetor_dp_emr = rbind(vetor_dp_emr,c(dp_emr))
			vetor_dp_emr_1 = rbind(vetor_dp_emr_1,c(dp_emr_1))
			vetor_ea = rbind(vetor_ea,c(ea))
			vetor_modelo = rbind(vetor_modelo,c(modelo))
			vetor_metodo = rbind(vetor_metodo,c(metodo))
			vetor_contr = rbind(vetor_contr,c(contrib)) 
			vetor_alcance = rbind(vetor_alcance,c(alcance))
	
			vetor_vlr_kappa = rbind(vetor_vlr_kappa,c(vlr_kappa))

			#popula matriz com informações da validação cruzada
			matriz_vc<-rbind(matriz_vc,c(modelo,em,emr,dp_em,dp_emr,dp_emr_1,ea,metodo))
			matriz_vc

			t_cont = t_cont +1    ###variável para armazenar o tamanho da tabela table_ice # bt 23/05/2016

		}

	}
					##########cálculo do ICE - 25/02/2016 - bt	
		if(is.numeric(vetor_emr)==TRUE)
		{
			max_abs_emr = max (abs(vetor_emr))
			max_abs_dp_emr_1 = max (abs(vetor_dp_emr_1))
			max_abs_dp_emr_1
			max_abs_emr		
			A = (abs(vetor_emr))/max_abs_emr
			B = (abs(vetor_dp_emr_1))/max_abs_dp_emr_1
			A
			B
			ice = round(A + B, digits=5)
	
			i
			matriz_vc
			vetor_em
			vetor_emr
			vetor_dp_em
			vetor_dp_emr
			vetor_dp_emr_1
			vetor_ea
			vetor_modelo
			vetor_metodo
			A
			B
			ice

			min_ice=min(ice)
			min_ice

			vetor_contr
			vetor_alcance

			table_ice <- data.table(cbind(ice, vetor_contr, vetor_alcance, vetor_modelo, vetor_metodo, vetor_vlr_kappa))
			table_ice

			i=0

			while (i<t_cont)
			{
				i= i+1
				if (table_ice$V1[i] == min_ice) {
					melhor_contrib = as.numeric(table_ice$V2[i])
					melhor_alcance = as.numeric(table_ice$V3[i])
					melhor_modelo = table_ice$V4[i]
					melhor_metodo = table_ice$V5[i]
					melhor_vlr_kappa = as.numeric(table_ice$V6[i])

					i=t_cont				

				} 

			}

			table_ice
			melhor_contrib
			melhor_alcance
			melhor_modelo
			melhor_metodo
			melhor_vlr_kappa
########################################
	
			#popula matriz com informações do melhor ICE de cada modelo
			matriz_ice<-rbind(matriz_ice,c(modelo, metodo, min_ice, melhor_contrib, melhor_alcance, melhor_vlr_kappa))
			matriz_ice

			vetor_ice = rbind(vetor_ice,c(min_ice))  ### vetor para armazenar o menor ice de cada molelo
			vetor_ice
		}


	}
	
	matriz_ice

##### encontrar o melhor modelo e seus parâmetros ########
	vetor_ice
	min_ice_geral=min(vetor_ice)
	min_ice_geral

	matriz_ice

			i=0
			i
			cont

			while (i<cont)
			{
				i= i+1
				i
				if (as.numeric(matriz_ice[i,3]) == min_ice_geral) {
					melhor_contrib_geral = as.numeric(matriz_ice[i,4])
					melhor_alcance_geral = as.numeric(matriz_ice[i,5])
					melhor_modelo_geral = matriz_ice[i,1]
					melhor_metodo_geral = matriz_ice[i,2]
					melhor_vlr_kappa_geral = as.numeric(matriz_ice[i,6])

					i=cont				
				} 

			}
					melhor_contrib_geral
					melhor_alcance_geral
					melhor_modelo_geral
					melhor_metodo_geral
					melhor_vlr_kappa_geral

	#faz o ajuste novamente com o melhor modelo
	if (melhor_modelo_geral == "matern"){
		if (melhor_metodo_geral=="ols"){ 
			variograma.ols<-variofit(dados.var,ini=c(melhor_contrib_geral,melhor_alcance_geral),
				weights= "equal",cov.model= "matern", kappa=melhor_vlr_kappa_geral) 
		} else {
			variograma.ols<-variofit(dados.var,ini=c(melhor_contrib_geral,melhor_alcance_geral),
				cov.model= "matern", kappa=melhor_vlr_kappa_geral) 
			}
	} else {
		if (melhor_metodo_geral=="ols"){
			variograma.ols<-variofit(dados.var,ini=c(melhor_contrib_geral,melhor_alcance_geral),
				weights= "equal",cov.model= melhor_modelo_geral)
		} else {
			variograma.ols<-variofit(dados.var,ini=c(melhor_contrib_geral,melhor_alcance_geral),
				cov.model= melhor_modelo_geral)
			}
	}

	variograma.ols
	plot(dados.var,xlab = legenda_x_semiv, ylab = legenda_y_semiv, main = paste ("Semivariograma ajustado pelo modelo",melhor_modelo,vlr_kappa,metodo,atributo))
	lines(variograma.ols,col=cor_linha) 

	kC=krige.control(obj=variograma.ols) #krigagem 
	kC
	dados.kC=krige.conv(dados, loc=gi, krige=kC) #Faz o mapa da variável dados por krigagem ordinária
	dados.kC
	length(dados.kC$pred)

	max(dados.kC$pred)
	min(dados.kC$pred)
	valores<-dados.kC$predict
	valores

	dados.kC
	gr
	borda
	leg_x_pamostrais
	leg_y_pamostrais
	range(dados.kC$predict)

	#mapa
	image(dados.kC, loc=gr, border=borda, col=gray(seq(1,0,l=classes)),
	main= paste ("Mapa interpolado pelo modelo",melhor_modelo_geral,melhor_vlr_kappa_geral,melhor_metodo_geral,atributo),font.main = 3,
	xlab=leg_x_pamostrais, ylab=leg_y_pamostrais, zlim=range(dados.kC$predict))

	#popula matriz com informações de coordenadas e valores interpolados
	matriz_export<-cbind(gi,valores)
	matriz_export

}
if (interpolador =="ID")
{
	#######################################################
	#################### bt -idw - 28/04/2016 ##############
	### Criar objeto 'sp'
	frame_id <- data.frame(x=dados$coords[,1], y=dados$coords[,2], atrib=dados$data)
	names(frame_id)
	frame_id
	coordinates(frame_id) <- ~x+y
	coordinates(frame_id)
	class(frame_id)
	plot(frame_id, asp=1, axes=T, pch=20)
	polygon(borda, border=2)

	frame_id$x
	frame_id$y
	frame_id$atrib
	coordinates(frame_id)
	frame_id

	### IDW Default
	frame_id$atrib~1
	frame_id
	gi
	gridded(gi) = ~x+y
	gridded(gi)

	frame_id$atrib~1
	dados
	dados.id<-idw(frame_id$atrib~1, frame_id, gi, nmax=vizinhos, idp=expoente)  #Faz o mapa da variável dados por id
	dados.id
	length(dados.id$var1.pred)
	max(dados.id$var1.pred)
	min(dados.id$var1.pred)
	dados.id$var1.pred
	valores<-dados.id$var1.pred
	valores
	gi$x
	matriz_export <- data.frame(x=gi$x, y=gi$y, atrib=dados.id$var1.pred)
	matriz_export
	image(dados.id, loc=gr, border=borda, 
	col=gray(seq(1,0,l=classes)), 
	main= paste("Mapa interpolado por ID",expoente,atributo),font.main = 3,
	xlab=leg_x_pamostrais, ylab=leg_y_pamostrais, zlim=range(dados.id$var1.pred))

}


# Concatena colunas: coordenadas em UTM dos pontos e valores interpolados
long = gi$x
lat = gi$y
medida = valores
interpol <- data.table(cbind(long, lat, medida))
interpol

# Grava as coordenadas dos pontos e os respectivos valores interpolados no banco de dados na tabela "tb_utm"
dbWriteTable(con, "tb_utm", interpol, overwrite = T)

# Encerra a conexão com o banco de dados
dbDisconnect(con)