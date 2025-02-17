#Basics
x<- 2
y <- c(10,9,4)
w <-c (y,5,y)
v <- seq(1,10,by=2)
t <- letters[1:4]
names(v) <- letters[1:5]
t<- numeric()
t[3]<- 17
length(t) <- 5 
x <- array(1:20, dim=c(4,5))
x[2,]
x[,2]
x[3,4]
x[3,4]=100
a <- c(1,2,3,4,6) 
b <- c(2,4,6,8,9) 
d <- c("A","B","A","B","AB")
levels <- factor(d)
ba <- data.frame(first=a, second=b, f=levels)

#Differential expression analysis
library('affy')
library(gcrma)
library(limma)
library(Biobase)
library('simpleaffy')
library('annotate')
library('hgu133plus2.db')

library(gplots)


gset <- ReadAffy()
pData(gset)
image(gset[,1])
hist(gset)

b1<-log2(exprs(gset))
boxplot(b1, col = 2:4)
hist(b1)

#Correlation
#
plot(exprs(gset)[,1], exprs(gset)[,2])

#Normalization
#mas5

data <- mas5(gset)
b2<-log2(exprs(data))
boxplot(b2, col = 2:4)
hist(b2)

#Design Matrix mas5

ex <- exprs(data)
exprs(data) <- log2(ex) 
gsms <- "111000"
sml <- c()
for (i in 1:nchar(gsms)) { sml[i] <- substr(gsms,i,i) }
sml <- paste("G", sml, sep="")
fl <- as.factor(sml)
data$description <- fl
design <- model.matrix(~ description + 0, data)
colnames(design) <- levels(fl)
design

#P Value mas5

fit <- lmFit(data, design)
cont.matrix <- makeContrasts(G1-G0, levels=design)
fit2 <- contrasts.fit(fit, cont.matrix)
fit2 <- eBayes(fit2, 0.01)
top <- topTable(fit2, adjust="fdr", sort.by="B", number=5000)
head(top, n=2)
write.table(top, file="DEAmas5.csv", sep=",")

#Gene Symbols mas5

selected  <- fit2$p.value <0.001
esetSel <- data [selected, ]
probeList <- rownames(top)
geneSymbol <- getSYMBOL(probeList,'hgu133plus2.db')
write.table(geneSymbol, file="geneSymbolmas5.csv",row.names=FALSE,col.names=F, quote=F, sep="\t")


#rma

data2 <- rma(gset)
b3<-log2(exprs(data2))
boxplot(b3, col = 2:4)
hist(b3)

#Design Matrix rma

ex <- exprs(data2)
exprs(data2) <- log2(ex) 
gsms <- "111000"
sml <- c()
for (i in 1:nchar(gsms)) { sml[i] <- substr(gsms,i,i) }
sml <- paste("G", sml, sep="")
fl <- as.factor(sml)
data2$description <- fl
design <- model.matrix(~ description + 0, data2)
colnames(design) <- levels(fl)
design

#P Value rma

fit <- lmFit(data2, design)
cont.matrix <- makeContrasts(G1-G0, levels=design)
fit2 <- contrasts.fit(fit, cont.matrix)
fit2 <- eBayes(fit2, 0.01)
top <- topTable(fit2, adjust="fdr", sort.by="B", number=5000)
head(top, n=2)
write.table(top, file="DEArma.csv", sep=",")

#Gene Symbols rma

selected  <- fit2$p.value <0.001
esetSel <- data2 [selected, ]
probeList <- rownames(top)
geneSymbol <- getSYMBOL(probeList,'hgu133plus2.db')
write.table(geneSymbol, file="geneSymbolrma.csv",row.names=FALSE,col.names=F, quote=F, sep="\t")

#Heatmap

heatmap(exprs(esetSel))
heatmap.2(exprs(esetSel), col=redgreen(100), scale="row", cexCol=0.6,
          key=TRUE, symkey=FALSE, density.info="none", trace="none", cexRow=0.5, main="Significant Genes with p-value < 0.001")
