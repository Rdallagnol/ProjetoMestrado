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
min_seq_contr<-as.numeric(args[17]) 
min_seq_alc<-as.numeric(args[18])  

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

#### INICIO BIBLIOTECAS UTILIZADAS #####
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

#### FIM BIBLIOTECAS UTILIZADAS #####

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

###### INICIO CONFIGURAÇÕES DO SEMIVARIOGRAMA E INICIO DO PROCESSO GEOESTATÍSTICO #############
t_cor_linha_ols = data.table(rbind("GOLD", "PURPLE", "VIOLET", "YELLOW", "BLACK", "GREEN", "ORANGE", "PINK", "GRAY", "BROWN", "BLUE", "RED", "MAGENTA"))
t_modelos = data.table(rbind("matern", "matern", "matern", "exp", "sph", "matern", "matern", "matern", "exp", "sph", "gaus", "gaus"))
t_kappa = data.table(rbind(1.0, 1.5, 2.0, 0.5, 0.5, 1.0, 1.5, 2.0, 0.5, 0.5, 0.5, 0.5))
t_metodo = data.table(rbind("ols", "ols", "ols", "ols", "ols", "wl", "wl", "wl", "wl", "wl", "wl", "ols"))
nro_modelo=12
vlr_kappa=0

#Constante para gráfico Semivariograma
legenda_x_semiv = "Distância"
legenda_y_semiv = "Semivariância"
titulo_semiv = "Semivariograma experimental"

#Constante do gráfico Mapa de dispersão dos pontos amostrais
titulo_pamostrais = "Mapa de dispersão dos pontos amostrais"
fonte_pamostrais = 3
leg_x_pamostrais ="O - L"
leg_y_pamostrais ="S - N"

titulo_BoxPlot = "Gráfico Boxplot"
titulo_PostPlot = "Gráfico Postplot"

classes = 4  #número de classe no mapa (intervalos) - só no R

###### FIM CONFIGURAÇÕES DO SEMIVARIOGRAMA E INICIO DO PROCESSO GEOESTATÍSTICO #############

###### INICIO CONFIGURAÇÕES DE CONEXÃO E BUSCA DE DADOS  #############	
drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, dbname="sdumOnline",host="localhost",port=5432,user="postgres",password="")
con
local = 29182
id_amostra = 25
atributo = paste("select st_x(st_transform(geometry,29182)), st_y(st_transform(geometry, 29182)),to_number(valor,'9999.999') from pixelamostra where amostra_codigo = ", id_amostra  )
frame_dados <- dbGetQuery(con,atributo)

insert = " INSERT INTO geo_analise_header(area_id, amostra_id, created_by, creation_date) VALUES (1, 1, 1, current_date) "
teste <- dbGetQuery(con,insert)



dados <- as.geodata(frame_dados)
names(dados)
### link para trabalhar com postgre https://www.r-bloggers.com/r-and-postgresql-using-rpostgresql-and-sqldf/
### http://stackoverflow.com/questions/39253497/updating-local-postgresql-database-with-r-using-update-or-insert
### http://stackoverflow.com/questions/25391324/how-to-insert-all-the-records-in-a-data-frame-into-the-database-in-r
### http://www.win-vector.com/blog/2016/02/using-postgresql-in-r/
### https://ww2.coastal.edu/kingw/statistics/R-tutorials/dataframes.html
### https://cran.r-project.org/web/packages/sqldf/sqldf.pdf
###### FIM CONFIGURAÇÕES DE CONEXÃO E BUSCA DE DADOS  #############

###### INICIO DAS ANALISES  #############
dados$coords
dados$data

min (dados$data)
#Análise exploratória dos dados
summary(dados$data)
mean (dados$data) 
min (dados$data) 
var(dados$data)
sd(dados$data)
CV = sd(dados$data)*100/mean(dados$data)
skewness(dados$data)
kurtosis(dados$data)
length(dados$data)

# Gráfico de probabilidade (QQ)
qqnorm(dados$data)  #, main = "", xlab = "Quantis teóricos N(0,1)", pch = 20,
# ylab = "Velocidade (km/m)")
qqline(dados$data, lty = 2, col = "red")

# Testes
t1 <- ks.test(dados$data, "pnorm", mean(dados$data), sd(dados$data)) # KS
t2 <- shapiro.test(dados$data) # Shapiro-Wilk
#t3 <- ad.test(dados$data) # Anderson-Darling

# Tabela de resultados
testes <- c(t1$method, t2$method)
estt <- as.numeric(c(t1$statistic, t2$statistic))
valorp <- c(t1$p.value, t2$p.value)
resultados <- cbind(estt, valorp)
rownames(resultados) <- testes
colnames(resultados) <- c("Estatística", "p")
print(resultados, digits = 4)

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

# ANÁLISE ESPACIAL
# Calcular a maior e menor distancia da área considerando as coordenadas dados$coords para obter o cutoff de 50% da distancia maxima
max_dist <- max(dist(dados$coords))
min_dist <- min(dist(dados$coords))
vlr_cutoff <- max_dist*cutoff/100

if (auto_lags==TRUE){
    nro_lags = round(vlr_cutoff/min_dist)	## bt 8/6/2016 - menor distancia das variancias
}

dados.var <- variog(dados,coords=dados$coords, data=dados$data, uvec=seq(min_dist,vlr_cutoff,l=nro_lags), lambda=v_lambda,
	 	estimator.type=estimador, max.dist=vlr_cutoff, pairs.min=nro_pares) 

x=paste("semi_exp",".png",sep = "")
png(x)
plot(dados.var, xlab = legenda_x_semiv, ylab = legenda_y_semiv, main = titulo_semiv)  
dev.off()

# Informações do semivariograma experimental
distancia <-  dados.var$u 
semivariancia <- dados.var$v
pares <- dados.var$n
tabela <- cbind(distancia,semivariancia,pares)


###################################
# envelopes --  bt 07/12/2016 ######
#dados.env<-variog.mc.env(dados, obj.v=dados.var) #,nsim = 99)
#plot(dados.var,env=dados.env,xlab="Distância", ylab="Semivariância")

####################################
min_dist_var = min(distancia)  ## bt 8/6/2016 - menor distancia das variancias

## para ajustar os valores para o semivariograma
min_var = min(semivariancia) # menor variância 
max_var = max(semivariancia) # maior variância

if (min_seq_alc==0){
#  min_seq_alc = min_dist_var	## bt 13/07/2016
   min_seq_alc = vlr_cutoff/4	## bt 13/07/2016
}
if (min_seq_contr==0){
    min_seq_contr = min_var		## bt 13/07/2016
}

vals <- expand.grid(seq(min_seq_contr,max_var, l=nro_intervalos_contr), 
# vals <- expand.grid(seq(min_var,max_var, l=nro_intervalos_contr), 
seq(min_seq_alc, vlr_cutoff, l=nro_intervalos_alc))
# seq(vlr_cutoff/4, vlr_cutoff, l=nro_intervalos_alc))

x=paste("semi_geral",".png",sep = "")
png(x)
plot(dados.var,xlab='Distância',ylab='Semivariância',main= paste ("Semivariograma ajustado -",atributo) )
dev.off()

cont = nro_intervalos_contr * nro_intervalos_alc

#cria matriz para armazenar informações do ice
matriz_ice<-matrix(nrow=0,ncol=7,
dimnames = list(c(),c("modelo","metodo","min_ice", "melhor_contrib", "melhor_alcance", "melhor_vlr_kappa", "gid" )))

vetor_ice = c()  ### vetor para armazenar o menor ice de cada molelo

j=0
metodo="wl"

while (j < nro_modelo){  
   
    #cria matriz para armazenar informações da validação cruzada
    matriz_vc<-matrix(nrow=0,ncol=9, dimnames = list(c(),c("Modelo", "EM", "EMR", "DP_EM", "DP_EMR", "DP_EMR_1", "EA","Metodo", "SDAE")))
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
   
    j <- j+1 

    modelo = t_modelos$V1[j]
    vlr_kappa = as.numeric(t_kappa$V1[j])
    cor_linha_ols = t_cor_linha_ols$V1[j]
    metodo = t_metodo$V1[j]

    i=0   
    
    t_cont = 0  # zera a variável que armazena o tamanho da tabela table_ice de cada modelo# bt 23/05/2016

    while (i<cont)
    {
        i <- i+1
        
        contrib = as.numeric(vals$Var1[i])
	alcance = as.numeric(vals$Var2[i])

        if (modelo == "matern"){

            if (metodo == "ols"){
                variograma.ols <- variofit(dados.var,ini=c(contrib,alcance),weights= "equal",cov.model= modelo, kappa= vlr_kappa, max.dist=vlr_cutoff)
            }else {
                variograma.ols<-variofit(dados.var,ini=c(contrib,alcance),cov.model= modelo, kappa= vlr_kappa, max.dist=vlr_cutoff)
            }

        }else {
            if (metodo=="ols"){
            	variograma.ols<-variofit(dados.var,ini=c(contrib,alcance),weights= "equal",cov.model= modelo, max.dist=vlr_cutoff)
            } else {
		variograma.ols<-variofit(dados.var,ini=c(contrib,alcance),cov.model= modelo, max.dist=vlr_cutoff)
            }
        }
       
        lines(variograma.ols,col=cor_linha_ols)
	
	
        #armazena informções da validação cruzada em variáveis
	vc=xvalid(dados,model=variograma.ols,micro.scale=0)     
    
	emr = 1
	dp_emr = 1
	dp_emr_1 = 0
        if ((mean (vc$std.error) != "NaN"))
        {
            emr = mean (vc$std.error) #erro médio reduzido
            dp_emr = round(sd (vc$std.error),digits=20) #desvio padrão do erro médio reduzido
            dp_emr_1 = ((sd (vc$std.error))-1) #desvio padrão do erro médio reduzido - 1
	}
        
      
        em = round(mean (vc$error),digits=20) #erro médio
        
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
	ea = round(sum(abs(vc$predicted-vc$data)),digits=20)  	#armazenar informções do erro absoluto
        
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


   ##########cálculo do ICE - 25/02/2016 - bt	
   ###### bt 06/07/2016 - retirei os indices, só deixei EM ##########

   if (ISI==TRUE)
   {
        ###################################
	## bt 13/09/2016 - correção no cálculo do ISI ###
	max_abs_em = max (abs(vetor_em))
	min_sdae = min (vetor_sdae)
	max_sdae = max (vetor_sdae)
	A = (abs(vetor_em))/max_abs_em
	B = ((vetor_sdae) - min_sdae)/ max_sdae
     
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
    min_ice = min(ice)
    
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
            i = t_cont
        }
    }
    


    #popula matriz com informações do melhor ICE de cada modelo
    #14/09/2016 - bt
    matriz_ice<-rbind(matriz_ice,c(modelo, metodo, min_ice, melhor_contrib, melhor_alcance, melhor_vlr_kappa, j))

    vetor_ice = rbind(vetor_ice,c(min_ice))  ### vetor para armazenar o menor ice de cada molelo

}

dev.off()

########################################
########### BT 13/09/2016 ##############
vetor_em_melhor = c()
vetor_dp_em_melhor = c()

matriz_isi<-matrix(nrow=0,ncol=3,
dimnames = list(c(),c("em", "dpem", "isi")))
isi = c("isi")
A = c()
B = c()

########################################
#### bt 16/06/2016 gráfico com o melhor semivariograma de cada modelo/metodo ###
matriz_legenda<-matrix(nrow=0,ncol=3,
dimnames = list(c(),c("modelo","metodo","vlr_kappa")))

x=paste("semiv_melhores",".png",sep = "")
png(x)
plot(dados.var,xlab='Distância',ylab='Semivariância',main= paste ("Semivariograma ajustado -",atributo) )
dev.off()

i=0

while (i<nro_modelo){
    i = i+1

    modelo = matriz_ice[i,1]
    metodo = matriz_ice[i,2]
    contrib = as.numeric(matriz_ice[i,4])
    alcance = as.numeric(matriz_ice[i,5])
    vlr_kappa = as.numeric(matriz_ice[i,6])
    cor_linha_ols = t_cor_linha_ols$V1[i]

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

    ########### BT 13/09/2016 ##############
    vc=xvalid(dados,model=variograma.ols,micro.scale=0)
    vc$error
    em_melhor = round(mean (vc$error),digits=20) #erro médio
    vc$data
    vc$predicted
    dif = (vc$data - vc$predicted)^2
    media_dif = mean(dif)
    sdae = sqrt(media_dif)
    vetor_em_melhor <- rbind(vetor_em_melhor,c(em_melhor))
    vetor_dp_em_melhor = rbind(vetor_dp_em_melhor,c(sdae))  

}

if (ISI==TRUE)
{
    max_abs_em_melhor = max (abs(vetor_em_melhor))
    min_abs_sdae = min (vetor_dp_em_melhor)
    max_abs_sdae = max (vetor_dp_em_melhor)
    A = (abs(vetor_em_melhor))/max_abs_em_melhor
    B = (vetor_dp_em_melhor - min_abs_sdae)/ max_abs_sdae
}

isi = round(A + B, digits=20)
matriz_isi<-cbind(vetor_em_melhor,vetor_dp_em_melhor,isi)

matriz_isi_melhor = cbind (matriz_ice, matriz_isi)
dev.off()

nome_tab = paste0 ("tb_isi_","testes")

dbWriteTable(con, nome_tab, as.data.table(matriz_isi_melhor), overwrite = T)
dbDisconnect(con)

print("##############")
print(matriz_isi_melhor)
dev.off()