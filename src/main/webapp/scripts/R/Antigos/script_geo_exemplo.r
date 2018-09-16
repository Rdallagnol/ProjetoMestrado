args<-commandArgs(TRUE) 
#### INICIO BLOCO QUE RECEBERA OS ARGUMENTOS DA TELA E REALIZARA OS TRATAMENTOS#####
#ENDERECO DA PASTA DE ARQUIVOS
mainDir<-args[1]
usuario<-as.numeric(args[2])
area<-as.numeric(args[3])
amostra<-as.numeric(args[4])
desc<-args[5]

ISI<-args[6]
v_lambda<-as.numeric(args[7])
auto_lags<-args[8]
nro_lags<-as.numeric(args[9])
estimador<-args[10]
cutoff<-as.numeric(args[11])
tam_pixel_x<-as.numeric(args[12])
tam_pixel_y<-as.numeric(args[13])
nro_intervalos_alc<-as.numeric(args[14])
nro_intervalos_contr<-as.numeric(args[15])
nro_pares<-as.numeric(args[16])

if (ISI == "true") {
   ISI <- TRUE
} else {
   ISI <- FALSE
}
if (auto_lags == "true") {
   auto_lags <- TRUE
} else {
   auto_lags <- FALSE
}

#### FIM BLOCO QUE RECEBERA OS ARGUMENTOS DA TELA E REALIZARA OS TRATAMENTOS ####

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

mainDir
usuario
area
amostra
desc

ISI
v_lambda
auto_lags
nro_lags
estimador
cutoff
tam_pixel_x
tam_pixel_y
nro_intervalos_alc
nro_intervalos_contr


## BIBLIOTECAS UTILIZADAS ##
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
require (nortest)


options(encoding="ISO-8859-1")
#############################################################################################
######## INICIO 1° ETAPA - VARIAVEIS ############

## ESCOLHA DO INDICE DE (PEDIR DETALHES ????) PARA ESCOLHA DO MELHOR MODELO (ISI OU ICE)
# PARAMETRO DE TELA = ? (SIM,NÃO)
ISI = ISI	#ISI = FALSE	

## VARIAVEIS PARA SEMIVARIOGRAMA	 
v_lambda = v_lambda # 1 = dados NÃO transformados,
	     # 0 = dados transformados
v_lambda
auto_lags= auto_lags		# parametro que define automaticamente o nro de lags

nro_lags = nro_lags		# parametro semivariograma KO que estipula o nro de lags arbitrariamente

estimador = estimador #parametro semivariograma KO = Matheron
#estimador = "modulus"	#parametro semivariograma OK = Cressie

# PARAMETRO SEMIVARIOGRAMA KO
cutoff = cutoff		# porcentagem da distancia maxima entre os pontos

nro_pares = nro_pares

nro_intervalos_alc = nro_intervalos_alc 	#parametro Alcance parametros do semivariograma (KO)

nro_intervalos_contr = nro_intervalos_contr #parametro Contribuição parametros do semivariograma (KO)

#parâmetros adicionados em 13/07/2016 (bt) # par
#parâmetros do expand.grid para criar vals da matriz de contribuição/alcance
min_seq_contr = 0  	# por padrão = 0 e receberá o valor de min_var mais adiante, ou usuário informa valor
min_seq_alc = 0 	# por padrão=0 e e receberá o valor de cutoff/4 ou min_dist_var mais adiante, ou usuário informa valor

## VERIFICAR INFORMAÇÕES SOBRE OS CONJUNTOS ABAIXO #
t_cor_linha_ols = data.table(rbind("GOLD", "PURPLE", "VIOLET", "YELLOW", "BLACK", "GREEN", "ORANGE", "PINK", "GRAY", "BROWN", "BLUE", "RED", "MAGENTA"))
t_modelos = data.table(rbind("matern", "matern", "matern", "exp", "sph", "matern", "matern", "matern", "exp", "sph", "gaus", "gaus"))
t_kappa = data.table(rbind(1.0, 1.5, 2.0, 0.5, 0.5, 1.0, 1.5, 2.0, 0.5, 0.5, 0.5, 0.5))
t_metodo = data.table(rbind("ols", "ols", "ols", "ols", "ols", "wl", "wl", "wl", "wl", "wl", "wl", "ols"))
#t_modelos = data.table(rbind("exp", "sph", "gaus"))
#t_kappa = data.table(rbind(0.5, 0.5, 0.5))

nro_modelo=12

vlr_kappa=0			#parametro semivariograma KO

#CONSTANTE PARA GRÁFICO SEMIVARIOGRAMA 
legenda_x_semiv = "Distância"
legenda_y_semiv = "Semivariância"
titulo_semiv = "Semivariograma experimental"

#CONSTANTE DO GRÁFICO MAPA DE DISPERSÃO DOS PONTOS AMOSTRAIS
titulo_pamostrais = "Mapa de dispersão dos pontos amostrais"
fonte_pamostrais = 3
leg_x_pamostrais ="O - L"
leg_y_pamostrais ="S - N"

#CONSTANTE DO BOXSPLOT
titulo_BoxPlot = "Gráfico Boxplot"
titulo_PostPlot = "Gráfico Postplot"

#PARAMETROS QUE IDENTIFICAM O TAMANHO DO PIXEL DO MAPA FINAL
tam_pixel_x = tam_pixel_x #parametro dos mapas
tam_pixel_y = tam_pixel_y #parametros dos mapas

classes = 5  	#número de classe no mapa (intervalos) - só no R
## FIM 1° ETAPA ###


########################################################################################

## INICIO 2° ETAPA ###
# Estabelece conexão com o PoststgreSQL usando RPostgreSQL
drv <- dbDriver("PostgreSQL")

# IDENTIFICAÇÃO DA FONTE DE DADOS UTILIZADA
projeto = "db_projeto_schenatto_b"  	#área
atributo = "tb_prod_media_norm_amp"		#amostra
local = 29182

# Configuração completa da conexão com o banco de dados
con <- dbConnect(drv, dbname=projeto,host="localhost",port=5432,user="postgres",password="1")


# REALIZAÇÃO DA LEITURA DOS DADOS DA TABELA DE ATRIBUTOS NO BANCO DE DADOS
atrib = paste("select st_x(st_transform(the_geom,", local, ")), st_y(st_transform(the_geom, ", local, ")),amo_medida from ", atributo)
frame_dados <- dbGetQuery(con,atrib)


dados <- as.geodata(frame_dados)
names(dados)


###### ANÁLISE EXPLORATÓRIA DOS DADOS ###############
## VERIFICAR SE SERÁ ARMAZENADO EM ALGUM LUGAR ESSES VALORES ####
summary(dados$data)
mean (dados$data) 
var(dados$data)
sd(dados$data)
CV = sd(dados$data)*100/mean(dados$data)

skewness(dados$data)
kurtosis(dados$data)
length(dados$data)

# GRÁFICOS DESCRITIVOS  
x=paste("plot",".png",sep = "")
png(x)
plot(dados)
dev.off()

x=paste("histograma",".png",sep = "")
png(x)
hist(dados$data)
dev.off()

#EXIBIR GRÁFICO (ARMAZENAR)
x=paste("boxplot",".png",sep = "")
png(x)
boxplot(dados$data,main=titulo_BoxPlot)
dev.off()

# ANÁLISE EXPLORATÓRIA ESPACIAL # Grafico Post-plot com legenda para o estudo de tendencia direcional.
x=paste("postplot",".png",sep = "")
png(x)
points(dados,pt.div="quartile",col=c("yellow","green","red","blue"),main=titulo_PostPlot, xlab=leg_x_pamostrais, ylab=leg_y_pamostrais)
dev.off()

## FIM 2° ETAPA ###
#########################################################################################################################################

## INICIO 3° ETAPA ###

# ANÁLISE ESPACIAL
# Calcular a maior e menor distancia da área considerando as coordenadas dados$coords para obter o cutoff de 50% da distancia maxima
max_dist <- max(dist(dados$coords))
min_dist <- min(dist(dados$coords))
vlr_cutoff <- max_dist*cutoff/100 


if (auto_lags==TRUE){
    nro_lags = round(vlr_cutoff/min_dist)	## menor distancia das variancias
}


dados.var <- variog(dados,coords=dados$coords, data=dados$data,
		uvec=seq(min_dist,vlr_cutoff,l=nro_lags), lambda=v_lambda,
	 	estimator.type=estimador, max.dist=vlr_cutoff, pairs.min=nro_pares) 


x=paste("semi_experi",".png",sep = "")
png(x)
plot(dados.var, xlab = legenda_x_semiv, ylab = legenda_y_semiv, main = titulo_semiv)  
dev.off()

# Informações do semivariograma experimental
distancia <-  dados.var$u 
semivariancia <- dados.var$v
pares <- dados.var$n
tabela <- cbind(distancia,semivariancia,pares)

min_dist_var = min(distancia)  ## - menor distancia das variancias
## para ajustar os valores para o semivariograma
min_var = min(semivariancia) # menor variância 
max_var = max(semivariancia) # maior variância

if (min_seq_alc==0){
    min_seq_alc = vlr_cutoff/4	
}
if (min_seq_contr==0){
    min_seq_contr = min_var		
}

vals <- expand.grid(seq(min_seq_contr,max_var, l=nro_intervalos_contr), 
seq(min_seq_alc, vlr_cutoff, l=nro_intervalos_alc))

x=paste("semi_ajustado",".png",sep = "")
png(x)
plot(dados.var,xlab='Distância',ylab='Semivariância',main= paste ("Semivariograma ajustado -",atributo) )
dev.off()

cont = nro_intervalos_contr * nro_intervalos_alc

#cria matriz para armazenar informações do ice
matriz_ice<-matrix(nrow=0,ncol=9,
dimnames = list(c(),c("modelo","metodo","min_ice", "melhor_contrib", "melhor_alcance", "melhor_vlr_kappa", "gid", "melhor_em", "melhor_dp_em" )))

vetor_ice = c()  ### vetor para armazenar o menor ice de cada molelo

j=0
metodo="wl"

while (j<nro_modelo)
    {
	#cria matriz para armazenar informações da validação cruzada
	matriz_vc<-matrix(nrow=0,ncol=9,
	dimnames = list(c(),c("Modelo", "EM", "EMR", "DP_EM", "DP_EMR", "DP_EMR_1", "EA","Metodo", "SDAE")))
	
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
	vetor_sdae=c()

	j=j+1
	
	modelo = t_modelos$V1[j]
	vlr_kappa = as.numeric(t_kappa$V1[j])
	cor_linha_ols = t_cor_linha_ols$V1[j]
	metodo = t_metodo$V1[j]
	
	i=0	
	t_cont = 0  # zera a variável que armazena o tamanho da tabela table_ice de cada modelo# bt 23/05/2016

	while (i<cont)
	{
            i= i+1         
            contrib = as.numeric(vals$Var1[i])
            alcance = as.numeric(vals$Var2[i])
          
            if (modelo=="matern"){
                if (metodo=="ols"){
                    variograma.ols<-variofit(dados.var,ini=c(contrib,alcance),weights= "equal",cov.model= modelo, kappa= vlr_kappa, max.dist=vlr_cutoff)
		} else {
                    variograma.ols<-variofit(dados.var,ini=c(contrib,alcance),cov.model= modelo, kappa= vlr_kappa, max.dist=vlr_cutoff)
		}
            } else {
		if (metodo=="ols"){
                    variograma.ols<-variofit(dados.var,ini=c(contrib,alcance),weights= "equal",cov.model= modelo, max.dist=vlr_cutoff)
		} else {
                    variograma.ols<-variofit(dados.var,ini=c(contrib,alcance),cov.model= modelo, max.dist=vlr_cutoff)
                }
            }
            lines(variograma.ols,col=cor_linha_ols)
            variograma.ols
	    
            #armazena informções da validação cruzada em variáveis
	    vc=xvalid(dados,model=variograma.ols,micro.scale=0)
            emr=1
            dp_emr =1
            dp_emr_1 = 0
        
            if ((mean (vc$std.error) != "NaN"))
            {
		emr = mean (vc$std.error) #erro médio reduzido
		dp_emr = round(sd (vc$std.error),digits=20) #desvio padrão do erro médio reduzido
		dp_emr_1 = ((sd (vc$std.error))-1) #desvio padrão do erro médio reduzido - 1
            }
	    vc$error
            em = round(mean (vc$error),digits=20) #erro médio
                 
            ##### DPem  calculado - bt - 08/07/2016  ###########
            nro_amostras = length(vc$error)   #conta o número de elementos
            n = 0
            somatorio = 0
            while (n < nro_amostras)
            {
		n = n+1
		somatorio = somatorio + (vc$error[n]*vc$error[n])
            }
            media_em2 = somatorio / nro_amostras   	#média dos erros médios ao quadrado
            dp_em = sqrt(media_em2)				#raiz quadrada da média dos erros médios ao quadrado
            ###########################################

            ea=round(sum(abs(vc$predicted-vc$data)),digits=20)  	#armazenar informções do erro absoluto

            ############# BT 09/06/2016 # ISI	   
	    vc$data
	    vc$predicted	   
            dif = (vc$data - vc$predicted)^2	  
	    media_dif = mean(dif)          
            sdae = sqrt(media_dif)
         
            ###################################

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
	    vetor_sdae = rbind(vetor_sdae,c(sdae))

	    #popula matriz com informações da validação cruzada
	    matriz_vc<-rbind(matriz_vc,c(modelo,em,emr,dp_em,dp_emr,dp_emr_1,ea,metodo,sdae))	 

            t_cont = t_cont +1    ###variável para armazenar o tamanho da tabela table_ice # bt 23/05/2016

	}
        
        ###### bt 06/07/2016 - retirei os indices, só deixei EM ##########
	if (ISI==TRUE)
	{
            #####################
            # BT 8/6/2016 - calculo do ISI (Vanderlei)
            #####################
            max_abs_em = max (abs(vetor_em))
            min_abs_sdae = min (abs(vetor_sdae))
            max_abs_sdae = max (abs(vetor_sdae))       

            A = (abs(vetor_em))/max_abs_em
            B = ((abs(vetor_sdae)) - min_abs_sdae)/ max_abs_sdae
	    ##############################################
	}else{
            #####################
            # calculo do ICE (Bazzi)
            #####################
            max_abs_emr = max (abs(vetor_emr))
            max_abs_dp_emr_1 = max (abs(vetor_dp_emr_1))
      
            A = (abs(vetor_emr))/max_abs_emr
            B = (abs(vetor_dp_emr_1))/max_abs_dp_emr_1
	}


	ice = round(A + B, digits=20)
    
        ##################################################################
        ###### bt 06/07/2016 - retirei os indices, só deixei EM ##########
        ##################################################################
	
	min_ice=min(ice)

        table_ice <- data.table(cbind(ice, vetor_contr, vetor_alcance, vetor_modelo, vetor_metodo, vetor_vlr_kappa, vetor_em, vetor_dp_em))

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
		melhor_em = as.numeric(table_ice$V7[i])
		melhor_dp_em = as.numeric(table_ice$V8[i])
		i=t_cont				
            } 
	}

	

	#popula matriz com informações do melhor ICE de cada modelo
	matriz_ice<-rbind(matriz_ice,c(modelo, metodo, min_ice, melhor_contrib, melhor_alcance, melhor_vlr_kappa, j, melhor_em, melhor_dp_em))
	
	vetor_ice = rbind(vetor_ice,c(min_ice))  ### vetor para armazenar o menor ice de cada molelo

    }

## FIM 3° ETAPA ###

# Encerra a conexão com o banco de dados
dbDisconnect(con)


