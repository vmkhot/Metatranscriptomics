# This script uses Mfuzz package to perform soft clustering of differentially expressed across time
# It uses log2 fold changes output by DESeq2, regardless of whether they are significant or not
# fuzzifier "m" and number of clusters needs to be optimized
# Plotting functionality of mfuzz is crap so it's better to ouput data from mfuzz and use ggplot to produce cluster graphs
# For plotting clusters: \Metatranscriptomics\R-scripts\clusters_ggplot2.R
# Refer to http://mfuzz.sysbiolab.eu/

library(Mfuzz)
library(Biobase)
library(plyr)

setwd('./DESeq2/cyano/clustering_genes/')

df <- read.csv("./all_genes/trial_mfuzz_logFC_data.csv",header = TRUE, sep = ',')
rownames(df) <- df[,1]
df[,1] <- NULL

exp.set <- ExpressionSet(assayData = as.matrix(df))

set.seed(123)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# FUZZIFIER AND CLUSTER NUMBER OPTIMIZATION

# estimate fuzzifier "m"
m1 <- mestimate(exp.set)

# find optimal number of clusters (takes a while to run)
# seq(min,max,step)
cselec <- cselection(exp.set,m=m1,crange=seq(4,50,2),repeats=5,visu=TRUE)
#OR
Dmin(exp.set,m1,crange=seq(4,50,2),repeats=3,visu=TRUE)

# ~~~~~~~~~~~~~~~~~~~~~~~~
# CHECK CLUSTER OVERLAP
# do the c-means clustering using multiple cluster numbers and m1 generated above and check overlap of the clusters
c18 <- mfuzz(exp.set,c=18,m=m1)
c22 <- mfuzz(exp.set,c=22,m=m1)
c30 <- mfuzz(exp.set,c=30,m=m1)

o18 <- overlap(c18)
o22 <- overlap(c22)
o30 <- overlap(c30)

overlap.plot(exp.set,cl=c22,thres = 0.05,over=o22)
overlap.plot(exp.set,cl=c18,thres = 0.05,over=o18)
overlap.plot(exp.set,cl=c30,thres = 0.05,over=o30)


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PLOTTING CLUSTERS WITH DIFF NUMBERS

mfuzz.plot2(exp.set,cl=c18,mfrow=c(4,5),x11=FALSE,
            ylim.set=c(-6,6), ax.col = "black", col = "purple",
            time.points=c(0,12,24,30,36,40,44,48,52,56,60,66,68,72,78,84),
            time.labels=c(0,12,24,30,36,40,44,48,52,56,60,66,68,72,78,84),
            xlab = "Hours", ylab = "Log2 Fold Change");drawLines()

drawLines <- function() abline(v=c(36,66),col="dodgerblue",lwd=2) # draws vertical lines


mfuzz.plot2(exp.set,cl=c22,mfrow=c(5,5),x11=FALSE,
            ylim.set=c(-6,6), ax.col = "black", col = "purple",
            time.points=c(0,12,24,30,36,40,44,48,52,56,60,66,68,72,78,84),
            time.labels=c(0,12,24,30,36,40,44,48,52,56,60,66,68,72,78,84))

mfuzz.plot2(exp.set,cl=c30,mfrow=c(5,6),x11=FALSE,
            ylim.set=c(-6,6), ax.col = "black", col = "purple",
            time.points=c(0,12,24,30,36,40,44,48,52,56,60,66,68,72,78,84),
            time.labels=c(0,12,24,30,36,40,44,48,52,56,60,66,68,72,78,84))

mfuzzColorBar(col="fancy",main="Membership",cex.main=1)


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# COMPARE WITH K-MEANS CLUSTERING

k1 <- kmeans2(exp.set,k = 18,iter.max = 99)
kmeans2.plot(exp.set,kl = k1,mfrow =c(4,5))
k_df <- k1$cluster
write.csv(k_df, "k_means_membership.csv")


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# WHAT GENES ARE IN WHAT CLUSTERS?
#get membership of clusters
set.seed(123)
acore_clust <- acore(exp.set,cl=c18, min.acore=0.7) # set membership threshold 
library(dplyr)
library(purrr)
library(tidyr)

acore_clust %>%
  imap(function(x, y) x %>% rename_with(~paste(y, sep = '_'), -"NAME")) %>% 
  reduce(full_join, by = 'NAME') -> final_df

final_df_m <- melt()

final_df_m <- pivot_longer(final_df, names_to = "cluster", values_to = "membership",
                           cols = c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18"))
final_df_m_na <- na.omit(final_df_m)

# produces a csv file with clsuter memberships
write.csv(final_df_m_na, "clusters_w_memship.csv")