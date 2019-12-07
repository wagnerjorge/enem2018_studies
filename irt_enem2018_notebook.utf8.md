
<!-- rnb-text-begin -->

---
title: "R Notebook"
output: html_notebook
---

This is an [R Markdown](http://rmarkdown.rstudio.com) Notebook. When you execute code within the notebook, the results appear beneath the code. 


Installation of the packages to clean and extract knowledge from ENEM dataset. 


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxubGlicmFyeShkcGx5cilcbmxpYnJhcnkoZGF0YS50YWJsZSlcbmxpYnJhcnkodGlkeXIpXG5saWJyYXJ5KHN0cmluZ3IpXG5saWJyYXJ5KHNwbGl0c3RhY2tzaGFwZSlcbmxpYnJhcnkobWlydClcbmxpYnJhcnkoR0dhbGx5KVxuYGBgIn0= -->

```r
library(dplyr)
library(data.table)
library(tidyr)
library(stringr)
library(splitstackshape)
library(mirt)
library(GGally)
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


Due the size of the raw data we read the data from a local directory. To illustrate the analysis built here, we use only the first 100k individuals. This will be modefied for all students in other analysis.


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuc2V0d2QoXCJGOi9taWNyb2RhZG9zL0RBRE9TXCIpICBcbm1lbW9yeS5saW1pdCgyNDU3NilcblxuZGF0IDwtIGRhdGEudGFibGU6OmZyZWFkKGlucHV0PSdlbmVtMjAxOC5jc3YnLFxuICAgICAgICAgICAgICAgICAgICAgICAgIGludGVnZXI2ND0nY2hhcmFjdGVyJyxcbiAgICAgICAgICAgICAgICAgICAgICAgICBza2lwPTAsICAjTGVyIGRvIGluaWNpb1xuICAgICAgICAgICAgICAgICAgICAgICAgIG5yb3dzPTEwMDAwMCxcbiAgICAgICAgICAgICAgICAgICAgICAgICBuYS5zdHJpbmdzID0gXCJcIiwgXG4gICAgICAgICAgICAgICAgICAgICAgICAgc2hvd1Byb2dyZXNzID0gVFJVRSlcbmBgYCJ9 -->

```r
setwd("F:/microdados/DADOS")  
memory.limit(24576)

dat <- data.table::fread(input='enem2018.csv',
                         integer64='character',
                         skip=0,  #Ler do inicio
                         nrows=100000,
                         na.strings = "", 
                         showProgress = TRUE)
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


The construction of IRT model is made from four test that compose the exam (CN - Ciencias e Natureza, CH - Ciencias Humanas, Linguagens e Codigos, MT - Matematica e suas Tecnologias which indicate Sciences and Nature, Sciences and Humans, Languages, and Codes, and Mathematic and its Technology, respectively). For this, We build the answers given by students and answer key datasets (`ans` and `gab`, respectively) droping missing values for all items in each test.


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYW5zIDwtIGRhdCAlPiUgc2VsZWN0KFRYX1JFU1BPU1RBU19DTiwgVFhfUkVTUE9TVEFTX0NILCBcbiAgICAgICAgICAgICAgICAgICAgICBUWF9SRVNQT1NUQVNfTEMsIFRYX1JFU1BPU1RBU19NVClcbmdhYiA8LSBkYXQgJT4lIHNlbGVjdChUWF9HQUJBUklUT19DTiwgVFhfR0FCQVJJVE9fQ0gsXG4gICAgICAgICAgICAgICAgICAgICAgVFhfR0FCQVJJVE9fTEMsIFRYX0dBQkFSSVRPX01UKVxuYW5zIDwtIGFucyAlPiUgZHJvcF9uYSgpXG5nYWIgPC0gZ2FiICU+JSBkcm9wX25hKClcbmBgYCJ9 -->

```r
ans <- dat %>% select(TX_RESPOSTAS_CN, TX_RESPOSTAS_CH, 
                      TX_RESPOSTAS_LC, TX_RESPOSTAS_MT)
gab <- dat %>% select(TX_GABARITO_CN, TX_GABARITO_CH,
                      TX_GABARITO_LC, TX_GABARITO_MT)
ans <- ans %>% drop_na()
gab <- gab %>% drop_na()
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



The number of questions is computed. Also, the answers given by the students for each test are stored in four datasets as can be seen below. Similarly is made with the answers key.


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxubnVtYl9xdWVzdGlvbiA8LSBnYWJbMSwgXSAlPiUgc3RyX2xlbmd0aCgpXG5uYW1lc19jbiA8LSBwYXN0ZSgnUScsIHNlcV9sZW4obnVtYl9xdWVzdGlvblsxXSksIHNlcCA9ICcnKVxubmFtZXNfbGMgPC0gcGFzdGUoJ1EnLCBzZXFfbGVuKG51bWJfcXVlc3Rpb25bM10pLCBzZXAgPSAnJylcbm5hbWVzX210IDwtIHBhc3RlKCdRJywgc2VxX2xlbihudW1iX3F1ZXN0aW9uWzRdKSwgc2VwID0gJycpXG5hbnNfY24gPC0gIGFuc1ssIDFdICU+JVxuICBjU3BsaXQoJ1RYX1JFU1BPU1RBU19DTicsIHNlcCA9ICcnLCBzdHJpcFdoaXRlID0gRkFMU0UpXG5hbnNfY2ggPC0gIGFuc1ssIDJdICU+JVxuICBjU3BsaXQoJ1RYX1JFU1BPU1RBU19DSCcsIHNlcCA9ICcnLCBzdHJpcFdoaXRlID0gRkFMU0UpXG5hbnNfbGMgPC0gIGFuc1ssIDNdICU+JVxuICBjU3BsaXQoJ1RYX1JFU1BPU1RBU19MQycsIHNlcCA9ICcnLCBzdHJpcFdoaXRlID0gRkFMU0UpXG5hbnNfbXQgPC0gIGFuc1ssIDRdICU+JVxuICBjU3BsaXQoJ1RYX1JFU1BPU1RBU19NVCcsIHNlcCA9ICcnLCBzdHJpcFdoaXRlID0gRkFMU0UpXG5gYGAifQ== -->

```r
numb_question <- gab[1, ] %>% str_length()
names_cn <- paste('Q', seq_len(numb_question[1]), sep = '')
names_lc <- paste('Q', seq_len(numb_question[3]), sep = '')
names_mt <- paste('Q', seq_len(numb_question[4]), sep = '')
ans_cn <-  ans[, 1] %>%
  cSplit('TX_RESPOSTAS_CN', sep = '', stripWhite = FALSE)
ans_ch <-  ans[, 2] %>%
  cSplit('TX_RESPOSTAS_CH', sep = '', stripWhite = FALSE)
ans_lc <-  ans[, 3] %>%
  cSplit('TX_RESPOSTAS_LC', sep = '', stripWhite = FALSE)
ans_mt <-  ans[, 4] %>%
  cSplit('TX_RESPOSTAS_MT', sep = '', stripWhite = FALSE)
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


Next, we renamed the answers and answers key for `Q.`, where `.` indicates the question number.


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxubmFtZXMoYW5zX2NoKSA8LSBuYW1lc19jblxubmFtZXMoYW5zX2NuKSA8LSBuYW1lc19jaFxubmFtZXMoYW5zX2xjKSA8LSBuYW1lc19sY1xubmFtZXMoYW5zX210KSA8LSBuYW1lc19tdFxubmFtZXMoZ2FiX2NoKSA8LSBuYW1lc19jblxubmFtZXMoZ2FiX2NuKSA8LSBuYW1lc19jaFxubmFtZXMoZ2FiX2xjKSA8LSBuYW1lc19sY1xubmFtZXMoZ2FiX210KSA8LSBuYW1lc19tdFxuYGBgIn0= -->

```r
names(ans_ch) <- names_cn
names(ans_cn) <- names_ch
names(ans_lc) <- names_lc
names(ans_mt) <- names_mt
names(gab_ch) <- names_cn
names(gab_cn) <- names_ch
names(gab_lc) <- names_lc
names(gab_mt) <- names_mt
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


To apply the IRT model with three parameters we define as one the correct answers and zero otherwise.


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuI0NvcnJlY3Rpb24gb2YgcXVlc3Rpb25zXG5jb3JfY24gPC0gKyAoYXMubWF0cml4KGFuc19jbikgPT0gYXMubWF0cml4KGdhYl9jbikpXG5jb3JfY2ggPC0gKyAoYXMubWF0cml4KGFuc19jaCkgPT0gYXMubWF0cml4KGdhYl9jaCkpXG5jb3JfbGMgPC0gKyAoYXMubWF0cml4KGFuc19sYykgPT0gYXMubWF0cml4KGdhYl9sYykpXG5jb3JfbXQgPC0gKyAoYXMubWF0cml4KGFuc19tdCkgPT0gYXMubWF0cml4KGdhYl9tdCkpXG5gYGAifQ== -->

```r
#Correction of questions
cor_cn <- + (as.matrix(ans_cn) == as.matrix(gab_cn))
cor_ch <- + (as.matrix(ans_ch) == as.matrix(gab_ch))
cor_lc <- + (as.matrix(ans_lc) == as.matrix(gab_lc))
cor_mt <- + (as.matrix(ans_mt) == as.matrix(gab_mt))
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


From `mirt` function the Multivariate Item Response Theory (MIRT) was applied. We highlight that the problem is univariate, i.e. there is only one population in study.


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxubW9kZWxfY24gPC0gbWlydChjb3JfY24sIDEsIHR5cGUgPSAnM1BMJylcbm1vZGVsX2NoIDwtIG1pcnQoY29yX2NoLCAxLCB0eXBlID0gJzNQTCcpXG5tb2RlbF9sYyA8LSBtaXJ0KGNvcl9sYywgMSwgdHlwZSA9ICczUEwnKVxubW9kZWxfbXQgPC0gbWlydChjb3JfbXQsIDEsIHR5cGUgPSAnM1BMJylcbmBgYCJ9 -->

```r
model_cn <- mirt(cor_cn, 1, type = '3PL')
model_ch <- mirt(cor_ch, 1, type = '3PL')
model_lc <- mirt(cor_lc, 1, type = '3PL')
model_mt <- mirt(cor_mt, 1, type = '3PL')
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


Coefficients and performance are displayed below.


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuI0NvZWZmaWNpZW50c1xuY29lZl9jbiA8LSBjb2VmKG1vZGVsX2NuLCBzaW1wbGlmeSA9IFRSVUUsIElSVHBhcnMgPSBUUlVFKVxuY29lZl9jaCA8LSBjb2VmKG1vZGVsX2NoLCBzaW1wbGlmeSA9IFRSVUUsIElSVHBhcnMgPSBUUlVFKVxuY29lZl9sYyA8LSBjb2VmKG1vZGVsX2xjLCBzaW1wbGlmeSA9IFRSVUUsIElSVHBhcnMgPSBUUlVFKVxuY29lZl9tdCA8LSBjb2VmKG1vZGVsX210LCBzaW1wbGlmeSA9IFRSVUUsIElSVHBhcnMgPSBUUlVFKVxuXG4jTTIgcGVyZm9ybWFuY2UgbWVhc3VyZVxuTTIobW9kZWxfY24pXG5NMihtb2RlbF9jaClcbk0yKG1vZGVsX2xjKVxuTTIobW9kZWxfbXQpXG5gYGAifQ== -->

```r
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
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


Once that the modeling is made we calculate the scores for each student and each test in (0, 1) scale. The (0, 1) means that the scores are have mean zero and standard deviation 100.



<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucHJvZl9jbiA8LSBmc2NvcmVzKG1vZGVsX2NuLCBtZXRob2QgPSAnRUFQJylcbnByb2ZfY2ggPC0gZnNjb3Jlcyhtb2RlbF9jaCwgbWV0aG9kID0gJ0VBUCcpXG5wcm9mX2xjIDwtIGZzY29yZXMobW9kZWxfbGMsIG1ldGhvZCA9ICdFQVAnKVxucHJvZl9tdCA8LSBmc2NvcmVzKG1vZGVsX210LCBtZXRob2QgPSAnRUFQJylcbmBgYCJ9 -->

```r
prof_cn <- fscores(model_cn, method = 'EAP')
prof_ch <- fscores(model_ch, method = 'EAP')
prof_lc <- fscores(model_lc, method = 'EAP')
prof_mt <- fscores(model_mt, method = 'EAP')
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


Based on the ENEM IRT approach, we resize the scores. The adopted range is (500, 100); the more or less distant from 500, the student will be considered more or less proficient, respectively.


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuc2NhbGVfY2hhbmdlIDwtIGZ1bmN0aW9uKHZhbHVlLCBtdSwgc2lnbWEpe1xuICBzaWdtYSAqIHZhbHVlICsgbXVcbn1cbnByb2ZfY24gPC0gYXBwbHkocHJvZl9jbiwgMSwgZnVuY3Rpb24oeCkgc2NhbGVfY2hhbmdlKHgsIDUwMCwgMTAwKSApXG5wcm9mX2NoIDwtIGFwcGx5KHByb2ZfY2gsIDEsIGZ1bmN0aW9uKHgpIHNjYWxlX2NoYW5nZSh4LCA1MDAsIDEwMCkgKVxucHJvZl9sYyA8LSBhcHBseShwcm9mX2xjLCAxLCBmdW5jdGlvbih4KSBzY2FsZV9jaGFuZ2UoeCwgNTAwLCAxMDApIClcbnByb2ZfbXQgPC0gYXBwbHkocHJvZl9tdCwgMSwgZnVuY3Rpb24oeCkgc2NhbGVfY2hhbmdlKHgsIDUwMCwgMTAwKSApXG5gYGAifQ== -->

```r
scale_change <- function(value, mu, sigma){
  sigma * value + mu
}
prof_cn <- apply(prof_cn, 1, function(x) scale_change(x, 500, 100) )
prof_ch <- apply(prof_ch, 1, function(x) scale_change(x, 500, 100) )
prof_lc <- apply(prof_lc, 1, function(x) scale_change(x, 500, 100) )
prof_mt <- apply(prof_mt, 1, function(x) scale_change(x, 500, 100) )
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->






<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucGxvdChtb2RlbF9jbiwgdHlwZSA9ICd0cmFjZScpXG5wbG90KG1vZGVsX2NoLCB0eXBlID0gJ3RyYWNlJylcbnBsb3QobW9kZWxfbGMsIHR5cGUgPSAndHJhY2UnKVxucGxvdChtb2RlbF9tdCwgdHlwZSA9ICd0cmFjZScpXG5gYGAifQ== -->

```r
plot(model_cn, type = 'trace')
plot(model_ch, type = 'trace')
plot(model_lc, type = 'trace')
plot(model_mt, type = 'trace')
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucGxvdChtb2RlbF9jbiwgdHlwZSA9ICdpbmZvdHJhY2UnKVxucGxvdChtb2RlbF9jaCwgdHlwZSA9ICdpbmZvdHJhY2UnKVxucGxvdChtb2RlbF9sYywgdHlwZSA9ICdpbmZvdHJhY2UnKVxucGxvdChtb2RlbF9tdCwgdHlwZSA9ICdpbmZvdHJhY2UnKVxuYGBgIn0= -->

```r
plot(model_cn, type = 'infotrace')
plot(model_ch, type = 'infotrace')
plot(model_lc, type = 'infotrace')
plot(model_mt, type = 'infotrace')
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->









<!-- rnb-text-end -->

