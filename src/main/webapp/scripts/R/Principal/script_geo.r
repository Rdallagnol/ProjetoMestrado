args<-commandArgs(TRUE) 

# -- INFORMAÇÕES DE PASTAS E DO BANCO DE DADOS -- #
mainDir<-args[1]
mainDir

dataBaseName<-args[2]
dataBaseHost<-args[3]
dataBaseUser<-args[4]
dataBasePassword<-args[5]
dataBasePort<-args[6]
# -- PARAMETROS ENVIADOS PELA TELA -- #
usuario<-as.numeric(args[7])
area<-as.numeric(args[8])
amostra<-as.numeric(args[9])
desc<-args[10]
ISI<-args[11]
v_lambda<-as.numeric(args[12])
auto_lags<-args[13]
nro_lags<-as.numeric(args[14])
estimador<-args[15]
cutoff<-as.numeric(args[16])
tam_pixel_x<-as.numeric(args[17])
tam_pixel_y<-as.numeric(args[18])
nro_intervalos_alc<-as.numeric(args[19])
nro_intervalos_contr<-as.numeric(args[20])
nro_pares<-as.numeric(args[21])
min_seq_contr<-as.numeric(args[22]) 
min_seq_alc<-as.numeric(args[23])  

ISI <- TRUE #somente ISI, pois foi definido como sendo melhor para avaliação do melhor ajuste

if (auto_lags == "true") {
   auto_lags <- TRUE
} else {
   auto_lags <- FALSE
}

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
require (nortest)

options(encoding="UTF8")
# ---- #

# -- MAPEAR O LUGAR NO SERVIDOR AONDE VÃO FICAR AS PASTAS COM AS ANALISES  -- #
subDir <- usuario
ifelse(!dir.exists(file.path(mainDir, subDir)), dir.create(file.path(mainDir, subDir)), FALSE)
mainDir <- paste(paste(mainDir,"/",sep = ""),usuario,sep = "")
subDir <- desc
ifelse(!dir.exists(file.path(mainDir, subDir)), dir.create(file.path(mainDir, subDir)), FALSE)
setwd(paste(paste(mainDir,"/",sep = ""),subDir,sep = ""))
# ---- #

# -- INICIO CONFIGURAÇÕES DO SEMIVARIOGRAMA E INICIO DO PROCESSO GEOESTATÍSTICO  -- #
t_cor_linha_ols = data.table(
			rbind(
				"GOLD", 
				"PURPLE", 
				"VIOLET", 
				"YELLOW", 
				"BLACK", 
				"GREEN", 
				"ORANGE", 
				"PINK", 
				"GRAY",
				"BROWN",
				"BLUE", 
				"RED", 
				"MAGENTA"
				)
			)
						
t_modelos = data.table(
			rbind(
                "matern", 
                "matern",
			    "matern",
                "exp", 
                "sph",
			    "gaus",
			    "matern",
			    "matern",
			    "matern",
			    "exp", 
			    "sph",
			    "gaus")
			)
					
t_kappa = data.table(
            rbind(
                 1.0, 
			     1.5, 
			     2.0, 
			     0.5, 
			     0.5,
				 0.5,
				 1.0, 
				 1.5, 
				 2.0, 
				 0.5, 
				 0.5, 
				 0.5)
             )
					
t_metodo = data.table(
                    rbind(
			"ols",
			"ols", 
			"ols", 
			"ols", 
			"ols",
			"ols", 		
			"wl", 
			"wl", 
			"wl", 
			"wl", 
			"wl", 
			"wl"
                    )
		)
# ---- #

nro_modelo = length(t_modelos$V1)	
vlr_kappa=0

# -- INFORMAÇÕES PARA GRÁFICO  -- #
leg_x_pamostrais ="O - L"
leg_y_pamostrais ="S - N"
titulo_BoxPlot = "Gráfico Boxplot"
titulo_PostPlot = "Gráfico Postplot"
titulo_BoxPlot = iconv(titulo_BoxPlot, to="latin1", from="utf-8")
titulo_PostPlot = iconv(titulo_PostPlot, to="latin1", from="utf-8")
# ---- #

# -- BUSCAR DADOS DA AMOSTRA NA BASE DE DADOS E REALIZAR TRANSFORMAÇÃO EM OBJETO GEODATA  -- #
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname=dataBaseName,host=dataBaseHost,port=dataBasePort,user=dataBaseUser,password=dataBasePassword)
local = 29182
atributo = paste("select st_x(st_transform(geometry, 29182)), 
			             st_y(st_transform(geometry, 29182)),
			             CAST(valor AS numeric) 
	              from pixelamostra where amostra_codigo = ", amostra  )

frame_dados <- dbGetQuery(con,atributo)
dados <- as.geodata(frame_dados)

# -- CONSTROI A SQL DO CABEÇALHO DA ANALISE  -- #
seq_header = dbGetQuery(con, " select nextval('geo_analise_header_seq') ")
insertHeader = paste0("INSERT INTO geo_analise_header(
								analise_header_id, descricao_analise,area_id, amostra_id, created_by, 
								creation_date, status, isi, v_lambda, auto_lags, nro_lags, 
								estimador, cutoff,tam_pixel_x,tam_pixel_y,nro_intervalos_alc,
								nro_intervalos_contr,nro_pares,min_seq_contr,min_seq_alc,tipo_analise) ", 
						"VALUES(",seq_header,",'",desc,"',",area,",",amostra,",",usuario,
								", current_date, 'A', ",ISI,",",v_lambda,",",auto_lags,
								",",nro_lags,",'",estimador,"',",cutoff,",",tam_pixel_x,
								",",tam_pixel_y,",",nro_intervalos_alc,","
								,nro_intervalos_contr,",",nro_pares,",",min_seq_contr,",",min_seq_alc,",'KRIG')")

# ---- #

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

# -- INICIO ANÁLISE ESPACIAL  -- #
max_dist <- max(dist(dados$coords))
min_dist <- min(dist(dados$coords))
vlr_cutoff <- max_dist*cutoff/100

if (auto_lags==TRUE){
    nro_lags = round(vlr_cutoff/min_dist)	## menor distancia das variancias	
}

# Gera o variograma inicial
dados.var <- variog(
        	dados,
			coords=dados$coords, 
			data=dados$data, 
			uvec=seq(min_dist,vlr_cutoff,l=nro_lags), 
			lambda=v_lambda,
			estimator.type=estimador, 
			max.dist=vlr_cutoff, 
			pairs.min=nro_pares
            ) 

# Informações do variograma inicial
distancia <-  dados.var$u 
semivariancia <- dados.var$v
pares <- dados.var$n
min_dist_var = min(dados.var$u)  ## menor distancia das variancias
min_var = min(semivariancia) # menor variância 
max_var = max(semivariancia) # maior variância

if (min_seq_alc==0){
   min_seq_alc = vlr_cutoff/4	
}
if (min_seq_contr==0){
    min_seq_contr = min_var		
}

vals <- expand.grid(
		seq(min_seq_contr,max_var, l=nro_intervalos_contr), 
		seq(min_seq_alc, vlr_cutoff, l=nro_intervalos_alc)
		)


cont = nro_intervalos_contr * nro_intervalos_alc

#cria matriz para armazenar informações do ice
matriz_ice<-matrix(
		 nrow=0,
		 ncol=7, 
		 dimnames = list
                    (
			c(),
		        c("modelo","metodo","min_ice", "melhor_contrib", "melhor_alcance", "melhor_vlr_kappa", "gid")
		    )
		 )

vetor_ice = c()  ### vetor para armazenar o menor ice de cada modelo
j=0


while (j < nro_modelo){  

 
    #cria matriz para armazenar informações da validação cruzada
    matriz_vc<-matrix(
		nrow=0,
		ncol=9, 
		dimnames = list
		(
                    c(),
                    c("Modelo", "EM", "EMR", "DP_EM", "DP_EMR", "DP_EMR_1", "EA","Metodo", "SDAE")
		)
					)
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
    t_cont = 0  # zera a variável que armazena o tamanho da tabela table_ice de cada modelo

    while (i<cont)
    {
        i <- i+1
    
        contrib = as.numeric(vals$Var1[i])
        alcance = as.numeric(vals$Var2[i])
	
	
        if (modelo == "matern"){

            if (metodo == "ols"){
                variograma.ols <- variofit(
                            dados.var,
                            ini=c(contrib,alcance),
                            weights= "equal",
                            cov.model= modelo, 
                            kappa= vlr_kappa, 
                            max.dist=vlr_cutoff
			  )
            }else {
                variograma.ols<-variofit(
                            dados.var,
                            ini=c(contrib,alcance),
                            cov.model= modelo, 
                            kappa= vlr_kappa, 
                            max.dist=vlr_cutoff
			)
            }

        }else {
            if (metodo=="ols"){
            	variograma.ols<-variofit(
			    dados.var,
			    ini=c(contrib,alcance),
			    weights= "equal",
			    cov.model= modelo, 
			    max.dist=vlr_cutoff
			)
            } else {
		variograma.ols<-variofit(
			    dados.var,
			    ini=c(contrib,alcance),
			    cov.model= modelo, 
			    max.dist=vlr_cutoff
			)
            }
        }
       
        lines(
            variograma.ols,
            col=cor_linha_ols
	)
	    

	#armazena informções da validação cruzada em variáveis
	vc = xvalid(
            dados,
	    model=variograma.ols,
	    micro.scale=0
	)     

	emr = 1
	dp_emr = 1
	dp_emr_1 = 0
		
	
        if ((mean (vc$std.error) != "NaN"))
        {
            emr = mean (vc$std.error) #erro médio reduzido
            dp_emr = round(sd(vc$std.error),digits=20) #desvio padrão do erro médio reduzido
            dp_emr_1 = ((sd (vc$std.error))-1) #desvio padrão do erro médio reduzido - 1
	}
              
        em = round(mean(vc$error),digits=20) #erro médio        
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
			
		vc$data
		vc$predicted	
		dif = (vc$data - vc$predicted)^2	
		media_dif = mean(dif)	
		sdae = sqrt(media_dif)
		
        
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

        t_cont = t_cont +1    ###variável para armazenar o tamanho da tabela
   }


   #Cálculo do indice	
   if (ISI==TRUE)
   {
		max_abs_em = max (abs(vetor_em))
		min_sdae = min (vetor_sdae)
		max_sdae = max (vetor_sdae)
		A = (abs(vetor_em))/max_abs_em
		B = ((vetor_sdae) - min_sdae)/ max_sdae
		
   }

    ice = round(A + B, digits=20)   
    min_ice = min(ice)    
    table_ice <- data.table(
                    cbind(
			  ice, 
                          vetor_contr,
			  vetor_alcance, 
			  vetor_modelo,
			  vetor_metodo, 
			  vetor_vlr_kappa,
			  vetor_em, 
			  vetor_dp_em
			)
		)
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
    


    #popula matriz com informações do melhor ICE de cada modelo e metodo
   
    matriz_ice<-rbind(matriz_ice,c(
                        	   modelo, 
				   metodo, 
				   min_ice, 
				   melhor_contrib, 
				   melhor_alcance, 
                   melhor_vlr_kappa, 
                   j
				 )
			)

    vetor_ice = rbind(vetor_ice,c(min_ice))  ### vetor para armazenar o menor ice de cada modelo e metodo

}


# bloco para verificar qual é o melhor de todos
vetor_em_melhor = c()
vetor_dp_em_melhor = c()
vetor_cor_linha = c()
vetor_nugget_mel = c()

matriz_isi<-matrix(nrow=0,ncol=5,dimnames = list(c(),c("em", "dpem", "isi","cor_linha","nugget")))
isi = c("isi")
A = c()
B = c()

#### Gráfico com o melhor semivariograma de cada modelo/metodo ###
i=0
x=paste("modelos",".png",sep = "")
png(x)
plot(dados.var,xlab=iconv("Distância", to="latin1", from="utf-8"),ylab=iconv("Semivariância", to="latin1", from="utf-8"),main= "Semivariograma variancias" )
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
            variograma.ols<-variofit(
				dados.var,
				ini=c(contrib,alcance),
				weights= "equal",
				cov.model= modelo, 
                                kappa= vlr_kappa, 
				max.dist=vlr_cutoff
				)
	} else {
            variograma.ols<-variofit(
				dados.var,
				ini=c(contrib,alcance),
				cov.model= modelo, 
				kappa= vlr_kappa, 
				max.dist=vlr_cutoff
				)
	}
		
    } else {
	
        if (metodo=="ols"){
            variograma.ols<-variofit(
				dados.var,
				ini=c(contrib,alcance),
				weights= "equal",
				cov.model= modelo, 
				max.dist=vlr_cutoff
			)
	} else {
            variograma.ols<-variofit(
				dados.var,
				ini=c(contrib,alcance),
				cov.model= modelo, 
				max.dist=vlr_cutoff
			)
	}
    }   

    lines(variograma.ols,col=cor_linha_ols, lwd=2)

    vc = xvalid(dados,model=variograma.ols,micro.scale=0)
    em_melhor = round(mean(vc$error),digits=20) #erro médio
    dif = (vc$data - vc$predicted)^2
    media_dif = mean(dif)
    sdae = sqrt(media_dif)
    vetor_em_melhor <- rbind(vetor_em_melhor,c(em_melhor))
    vetor_dp_em_melhor = rbind(vetor_dp_em_melhor,c(sdae))  
    vetor_cor_linha = rbind(vetor_cor_linha,c(cor_linha_ols))		
	vetor_nugget_mel = rbind(vetor_nugget_mel,c(variograma.ols$nugget))
}

dev.off()

if (ISI==TRUE)
{
    max_abs_em_melhor = max (abs(vetor_em_melhor))
    min_abs_sdae = min (vetor_dp_em_melhor)
    max_abs_sdae = max (vetor_dp_em_melhor)
    A = (abs(vetor_em_melhor))/max_abs_em_melhor
    B = (vetor_dp_em_melhor - min_abs_sdae)/ max_abs_sdae
}

isi = round(A + B, digits=20)
matriz_isi<-cbind(vetor_em_melhor,vetor_dp_em_melhor,isi,vetor_cor_linha,vetor_nugget_mel)
matriz_isi_melhor = cbind (matriz_ice, matriz_isi)

#### Registra analises e seus parametrôs ######
registra <- dbGetQuery(con,insertHeader)
linhas = 1
while (linhas <= nro_modelo){   
    insertLines = paste0("INSERT INTO geo_analise_lines(
				  analise_header_id, modelo, metodo, min_ice, melhor_contrib, 
				  melhor_alcance, melhor_val_kappa,created_by, creation_date, erro_medio, dp_erro_medio, isi, nugget)",
			"VALUES (  ",seq_header,",'",matriz_isi_melhor[linhas,1],"','",matriz_isi_melhor[linhas,2],
				   "',",matriz_isi_melhor[linhas,3],", ",matriz_isi_melhor[linhas,4],","
				   ,matriz_isi_melhor[linhas,5],", ",matriz_isi_melhor[linhas,6],
				   ", 1, current_date, ",matriz_isi_melhor[linhas,8],",",matriz_isi_melhor[linhas,9],
				   ", ",matriz_isi_melhor[linhas,10],",",matriz_isi_melhor[linhas,12] ,")")
   
    dbGetQuery(con,insertLines)
    linhas <- linhas + 1
}
# ---- #

## Gera a representação gráfica do melhor modelo ##
melhores = 0
atual_melhor = 0;
while (melhores < length(matriz_isi_melhor[,10])){  
	melhores = melhores + 1
	if (atual_melhor == 0){
		atual_melhor = as.numeric(matriz_isi_melhor[melhores,10])
	}	
	if (atual_melhor > as.numeric(matriz_isi_melhor[melhores,10])){
		atual_melhor = as.numeric(matriz_isi_melhor[melhores,10])
		gid_melhor = as.numeric(matriz_isi_melhor[melhores,7])
	}
	
}

if( matriz_isi_melhor[gid_melhor,2] == "ols" ){
            variograma.ols<-variofit(
            dados.var,
            ini=c(as.numeric(matriz_isi_melhor[gid_melhor,4]),as.numeric(matriz_isi_melhor[gid_melhor,5])),
            cov.model= matriz_isi_melhor[gid_melhor,1], 
            max.dist=vlr_cutoff,
            wei="equal"
	)
} else {
	variograma.ols<-variofit(
            dados.var,
            ini=c(as.numeric(matriz_isi_melhor[gid_melhor,4]),as.numeric(matriz_isi_melhor[gid_melhor,5])),
            cov.model= matriz_isi_melhor[gid_melhor,1], 
            max.dist=vlr_cutoff
	)
}

x=paste("melhor_modelo",".png",sep = "")
png(x)
legenda = paste(paste("Melhor modelo é", variograma.ols$cov.model), paste("com ajuste " , variograma.ols$method))
plot(dados.var,xlab=iconv("Distância", to="latin1", from="utf-8"),ylab=iconv("Semivariância", to="latin1", from="utf-8"),main=iconv(legenda,to="latin1", from="utf-8") )
lines(variograma.ols,col=matriz_isi_melhor[gid_melhor,11], lwd=2)
dev.off()								
# ---- #
dbDisconnect(con)
dev.off()

### Código 9999 que avisa que o processamento foi concluido com sucesso
9999
dev.off()
