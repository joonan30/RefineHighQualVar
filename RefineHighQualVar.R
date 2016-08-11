setwd('./RefineHighQualVar/')

##############################
## Load packages
library(ROCR) # ROC analysis
library(ggplot2) # plot
library(grid) # plot
library(gridExtra) # plot
library(Cairo) # plot

##############################
## Set function
# optimal cutoff
opt.cut = function(perf){
  cut.ind = mapply(FUN=function(x, y, p){
    d = (x - 0)^2 + (y-1)^2
    ind = which(d == min(d))
    c(sensitivity = y[[ind]], specificity = 1-x[[ind]], 
      cutoff = p[[ind]])
  }, perf@x.values, perf@y.values, perf@alpha.values)
}

# violin plot with ggplot2
my.vioplot <- function(df,dfScore,factorA,title_text,y_title) {
  p <- ggplot(df, aes(factorA,dfScore)) +
    geom_violin(aes(fill = factorA)) +
    labs(x="", y=y_title,title=title_text) + 
    theme_grey(base_size = 16) +
    scale_fill_brewer(palette="Set1") + theme_grey(base_size = 11) + 
    guides(fill = guide_legend(reverse=FALSE, title=NULL)) +
    geom_boxplot(width=0.05) + 
    stat_summary(fun.y=mean, geom="point", shape=23, size=3, color="red")
  return(p)
}

###################
# Load data
dataVar = read.delim('table.testVar.txt',sep='\t'); colnames(dataVar)

#####################
## Explore distribution of quality metrics between positive and negative calls
p1 = my.vioplot(dataVar,dataVar$GQ,dataVar$VAL,'GQ', 'Score')
p2 = my.vioplot(dataVar,dataVar$MQ,dataVar$VAL,'MQ', 'Score')
p3 = my.vioplot(dataVar,dataVar$QUAL,dataVar$VAL,'QUAL', 'Score')
p4 = my.vioplot(dataVar,dataVar$DP,dataVar$VAL,'DP', 'X')

png(filename="plot.distribution.png", type="cairo", units="in", width=10, height=10, pointsize=12, res=256)
grid.arrange(p1,p2,p3,p4, ncol = 2)
dev.off()


#####################
## Evaluate prediction performance of each quality metric by varying threshold cutoff

png(filename="plot.roc.png", type="cairo", units="in", width=10, height=10, pointsize=12, res=256)
par(mfrow=c(2,2))

pred <- prediction(dataVar$GQ, dataVar$VAL); roc.perf <- performance(pred, measure = "tpr", x.measure = "fpr")
auc.perf.pcnv = round(performance(pred, measure = "auc")@y.values[[1]],3); cutoff_value = opt.cut(roc.perf)['cutoff',1]
plot(roc.perf, colorize=T, main='GQ') + abline(a=0, b=1) + text(0.7, 0.3, paste('AUC=',auc.perf.pcnv)) + text(0.7, 0.1, paste('Best Cut=',cutoff_value)) 

pred <- prediction(dataVar$MQ, dataVar$VAL); roc.perf <- performance(pred, measure = "tpr", x.measure = "fpr")
auc.perf.pcnv = round(performance(pred, measure = "auc")@y.values[[1]],3); cutoff_value = opt.cut(roc.perf)['cutoff',1]
plot(roc.perf, colorize=T, main='MQ') + abline(a=0, b=1) + text(0.7, 0.3, paste('AUC=',auc.perf.pcnv)) + text(0.7, 0.1, paste('Best Cut=',cutoff_value)) 

pred <- prediction(dataVar$QUAL, dataVar$VAL); roc.perf <- performance(pred, measure = "tpr", x.measure = "fpr")
auc.perf.pcnv = round(performance(pred, measure = "auc")@y.values[[1]],3); cutoff_value = opt.cut(roc.perf)['cutoff',1]
plot(roc.perf, colorize=T, main='QUAL') + abline(a=0, b=1) + text(0.7, 0.3, paste('AUC=',auc.perf.pcnv)) + text(0.7, 0.1, paste('Best Cut=',cutoff_value))

pred <- prediction(dataVar$DP, dataVar$VAL); roc.perf <- performance(pred, measure = "tpr", x.measure = "fpr")
auc.perf.pcnv = round(performance(pred, measure = "auc")@y.values[[1]],3); cutoff_value = opt.cut(roc.perf)['cutoff',1]
plot(roc.perf, colorize=T, main='DP') + abline(a=0, b=1) + text(0.7, 0.3, paste('AUC=',auc.perf.pcnv)) + text(0.7, 0.1, paste('Best Cut=',cutoff_value)) 

dev.off()

