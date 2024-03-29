#---------------#
# Packages used #
#---------------#
library(dplyr)
library(data.table)
library(tidyr)
library(stringr)
library(splitstackshape)
library(mirt)
library(GGally)

#-----------------#
# Reading dataset #
#-----------------#
setwd("F:/microdados/DADOS")  
memory.limit(24576)


##Reading first 100k observations
#if nrows = -1 all observations will be readed
dat <- data.table::fread(input='enem2018.csv',
                         integer64='character',
                         skip=0,  #Ler do inicio
                         nrows=100000,
                         na.strings = "", 
                         showProgress = TRUE)

#----------------------------------------#
# IRT variables selection and data clean #
#----------------------------------------#
ans <- dat %>% select(TX_RESPOSTAS_CN, TX_RESPOSTAS_CH, 
                      TX_RESPOSTAS_LC, TX_RESPOSTAS_MT)
gab <- dat %>% select(TX_GABARITO_CN, TX_GABARITO_CH,
                      TX_GABARITO_LC, TX_GABARITO_MT)

ans <- ans %>% drop_na()
gab <- gab %>% drop_na()


numb_question <- gab[1, ] %>% str_length()

names_cn <- paste('Q', seq_len(numb_question[1]), sep = '')
names_ch <- paste('Q', seq_len(numb_question[2]), sep = '')
names_lc <- paste('Q', seq_len(numb_question[3]), sep = '')
names_mt <- paste('Q', seq_len(numb_question[4]), sep = '')


# Answers of cn
ans_cn <-  ans[, 1] %>%
  cSplit('TX_RESPOSTAS_CN', sep = '', stripWhite = FALSE)
# Answers of ch
ans_ch <-  ans[, 2] %>%
  cSplit('TX_RESPOSTAS_CH', sep = '', stripWhite = FALSE)
# Answers of lc
ans_lc <-  ans[, 3] %>%
  cSplit('TX_RESPOSTAS_LC', sep = '', stripWhite = FALSE)
# Answers of cn
ans_mt <-  ans[, 4] %>%
  cSplit('TX_RESPOSTAS_MT', sep = '', stripWhite = FALSE)

# Gabarito of cn
gab_cn <-  gab[, 1] %>%
  cSplit('TX_GABARITO_CN', sep = '', stripWhite = FALSE)
# Answers of ch
gab_ch <-  gab[, 2] %>%
  cSplit('TX_GABARITO_CH', sep = '', stripWhite = FALSE)
# Answers of lc
gab_lc <-  gab[, 3] %>%
  cSplit('TX_GABARITO_LC', sep = '', stripWhite = FALSE)
# Answers of cn
gab_mt <-  gab[, 4] %>%
  cSplit('TX_GABARITO_MT', sep = '', stripWhite = FALSE)

#Chaging question names in ans and gab
names(ans_ch) <- names_cn
names(ans_cn) <- names_ch
names(ans_lc) <- names_lc
names(ans_mt) <- names_mt

names(gab_ch) <- names_cn
names(gab_cn) <- names_ch
names(gab_lc) <- names_lc
names(gab_mt) <- names_mt

#Correction of questions
cor_cn <- + (as.matrix(ans_cn) == as.matrix(gab_cn))
cor_ch <- + (as.matrix(ans_ch) == as.matrix(gab_ch))
cor_lc <- + (as.matrix(ans_lc) == as.matrix(gab_lc))
cor_mt <- + (as.matrix(ans_mt) == as.matrix(gab_mt))

#--------------#
# IRT Modeling #
#--------------#
model_cn <- mirt(cor_cn, 1, type = '3PL')
model_ch <- mirt(cor_ch, 1, type = '3PL')
model_lc <- mirt(cor_lc, 1, type = '3PL')
model_mt <- mirt(cor_mt, 1, type = '3PL')

#Coefficients
coef_cn <- coef(model_cn, simplify = TRUE, IRTpars = TRUE)
coef_ch <- coef(model_ch, simplify = TRUE, IRTpars = TRUE)
coef_lc <- coef(model_lc, simplify = TRUE, IRTpars = TRUE)
coef_mt <- coef(model_mt, simplify = TRUE, IRTpars = TRUE)

#M2 performance measure
M2(model_cn)
M2(model_ch)
M2(model_lc)
M2(model_mt)

#Calculating proficiency by exam
prof_cn <- fscores(model_cn, method = 'EAP')
prof_ch <- fscores(model_ch, method = 'EAP')
prof_lc <- fscores(model_lc, method = 'EAP')
prof_mt <- fscores(model_mt, method = 'EAP')

#Rescaling proficiencies for scale (500, 100) 
prof_cn <- apply(prof_cn, 1, function(x) scale_change(x, 500, 100) )
prof_ch <- apply(prof_ch, 1, function(x) scale_change(x, 500, 100) )
prof_lc <- apply(prof_lc, 1, function(x) scale_change(x, 500, 100) )
prof_mt <- apply(prof_mt, 1, function(x) scale_change(x, 500, 100) )

prof <- data.frame(CN = prof_cn, CH = prof_ch, LC = prof_lc, MT = prof_mt)

#Number of corrected questions (ncq)
ncq_cn <- apply(cor_cn, 1, sum)
ncq_ch <- apply(cor_ch, 1, sum)
ncq_lc <- apply(cor_lc, 1, sum)
ncq_mt <- apply(cor_mt, 1, sum)

#------------------#
# Items diagnostic #
#------------------#
# Graphics
plot(model_cn, type = 'trace')
plot(model_ch, type = 'trace')
plot(model_lc, type = 'trace')
plot(model_mt, type = 'trace')

##Information by item
plot(model_cn, type = 'infotrace')
plot(model_ch, type = 'infotrace')
plot(model_lc, type = 'infotrace')
plot(model_mt, type = 'infotrace')


#------------------------------#
# Information analysis by item #
#------------------------------#

theta <- matrix(seq(-4, 4, by = .1))
seq_cn <- matrix(seq_len(length(names_cn)), ncol = 1)
seq_ch <- matrix(seq_len(length(names_ch)), ncol = 1)
seq_lc <- matrix(seq_len(length(names_lc)), ncol = 1)
seq_mt <- matrix(seq_len(length(names_mt)), ncol = 1)

extr_item_cn <- lapply(seq_cn, function(x) extract.item(model_cn, x))
extr_item_ch <- lapply(seq_ch, function(x) extract.item(model_ch, x))
extr_item_lc <- lapply(seq_lc, function(x) extract.item(model_lc, x))
extr_item_mt <- lapply(seq_mt, function(x) extract.item(model_mt, x))

info_item_cn <- lapply(extr_item_cn, function(x) iteminfo(x, theta))
info_item_ch <- lapply(extr_item_ch, function(x) iteminfo(x, theta))
info_item_lc <- lapply(extr_item_lc, function(x) iteminfo(x, theta))
info_item_mt <- lapply(extr_item_mt, function(x) iteminfo(x, theta))

#The items are sorted from difficulty parameters b
dif_cn <- data.frame(question = seq_cn, coef_cn$items) %>% arrange(desc(b))
dif_ch <- data.frame(question = seq_ch, coef_ch$items) %>% arrange(desc(b))
dif_lc <- data.frame(question = seq_lc, coef_lc$items) %>% arrange(desc(b))
dif_mt <- data.frame(question = seq_mt, coef_mt$items) %>% arrange(desc(b))



#Correlation between proficiencies of the exam
##Scatterplot of the variables combined with probability distribution and correlation
prof %>% ggpairs()
##Low correlation between variables, then we use independent modeling analysis. In other
##words, due the response variables are not correlated the recommended is to use a
##regression model for each variable, i.e. three regression problems
cor(prof)
