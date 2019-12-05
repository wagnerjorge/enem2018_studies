#
#
#
library(dplyr)

#--------------------
# Intalacao do pacote Data.Table
# Se nao estiver instalado
#--------------------
if(!require(data.table)){install.packages('data.table')}

#--------------------
# Caso deseje trocar o local do arquivo, 
# edit a fun??o setwd() a seguir informando o local do arquivo.
# Ex. Windows setwd("C:/temp")
#     Linux   setwd("/home")
#--------------------
setwd("F:/microdados/DADOS")  

#---------------
# Aloca??o de mem?ria
#---------------
memory.limit(24576)

#------------------
# Carga dos microdados

dat <- data.table::fread(input='enem2018.csv',
                               integer64='character',
                               skip=0,  #Ler do inicio
                               nrow=-1, #Ler todos os registros
                               na.strings = "", 
                               showProgress = TRUE)

enem2018 <- cbind.data.frame(CO_MUNICIPIO_RESIDENCIA = dat$CO_MUNICIPIO_RESIDENCIA,
                             moradores = dat$Q005,
                             NU_IDADE = dat$NU_IDADE,
                             NU_NOTA_CN = dat$NU_NOTA_CN,
                             NU_NOTA_CH = dat$NU_NOTA_CH, 
                             NU_NOTA_LC = dat$NU_NOTA_LC,
                             NU_NOTA_MT = dat$NU_NOTA_MT, 
                             NU_NOTA_REDACAO = dat$NU_NOTA_REDACAO)

#
# Outliers remotion
#
enem2018 <- enem2018[complete.cases(enem2018), ]

#Students with zero score in redation
enem2018 <- enem2018 %>% filter(NU_NOTA_REDACAO != 0)

cr <-  enem2018 %>% group_by(CO_MUNICIPIO_RESIDENCIA) %>% 
  summarise_all(list(center = ~mean(.), radius = ~ 2 * sd(.)))



