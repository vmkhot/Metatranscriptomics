BiocManager::install('WGCNA')
BiocManager::install("GO.db")
BiocManager::install(c("AnnotationDbi", "impute"))
BiocManager::install(c("preprocessCore"))
install.packages(c(
  "fastcluster",    # fast hierarchical clustering
  "flashClust",     # alternative clustering
  "dynamicTreeCut" # module detection
))
install.packages("pheatmap")
library(WGCNA)

# setwd("./OneDrive - University of Calgary/Transcriptomics/DESeq2/cyano/")

# read in your log2FC table
df <- read.csv("wide_cyano_results_vs_T0.csv", row.names = 1, check.names = FALSE)

# transpose so rows = samples (timepoints), columns = genes
datExpr <- t(df)

gsg <- goodSamplesGenes(datExpr, verbose = 3)
if(!gsg$allOK){
  datExpr <- datExpr[gsg$goodSamples, gsg$goodGenes]
}

powers <- c(1:20)
sft <- pickSoftThreshold(datExpr, powerVector = powers, verbose = 5)

# plot to pick a power where scale-free topology index > 0.8
plot(sft$fitIndices[,1], sft$fitIndices[,2],
     xlab="Soft Threshold (power)", ylab="Scale Free Topology Model Fit (R^2)",
     type="b", main="Scale-free topology")

softPower <- 12  # replace with chosen power
adjacency <- adjacency(datExpr, power = softPower)

# Turn adjacency into Topological Overlap Matrix (TOM)
TOM <- TOMsimilarity(adjacency)
dissTOM <- 1 - TOM

# Hierarchical clustering
geneTree <- hclust(as.dist(dissTOM), method = "average")
geneTree
# Module identification using dynamic tree cut
dynamicMods <- cutreeDynamic(dendro = geneTree, distM = dissTOM,
                             deepSplit = 2, pamRespectsDendro = FALSE,
                             minClusterSize = 30)

# assign colors to modules
moduleColors <- labels2colors(dynamicMods)
table(moduleColors)

traitTime <- as.numeric(sub("_log2FoldChange", "", rownames(datExpr)))
traitTime
MEs <- moduleEigengenes(datExpr, colors = moduleColors)$eigengenes
MEs <- orderMEs(MEs)
moduleTraitCor <- cor(MEs, traitTime, use = "p")
moduleTraitCor[is.na(moduleTraitCor)] <- 0

moduleTraitPvalue <- corPvalueStudent(moduleTraitCor, nSamples = nrow(datExpr))

# set column name
colnames(moduleTraitCor) <- "Time"

# Sort moduleTraitCor by correlation with Time
sortedModules <- rownames(moduleTraitCor)[order(moduleTraitCor[, "Time"], decreasing = TRUE)]
moduleTraitCorSorted <- moduleTraitCor[sortedModules, , drop = FALSE]

# Optional: sorted p-values if you want to display significance
moduleTraitPvalueSorted <- moduleTraitPvalue[sortedModules, , drop = FALSE]

# now plot
labeledHeatmap(
  Matrix = moduleTraitCorSorted,
  xLabels = colnames(moduleTraitCorSorted),   # "Time"
  yLabels = rownames(moduleTraitCorSorted),   # modules
  ySymbols = rownames(moduleTraitCorSorted),
  colorLabels = TRUE,
  colors = blueWhiteRed(50),
  textMatrix = round(moduleTraitCorSorted, 2),
  setStdMargins = FALSE,
  cex.text = 0.5,
  zlim = c(-1,1),
  main = "Module-trait relationships"
)

# genes in the "blue" module
bisque4ModuleGenes <- colnames(datExpr)[which(moduleColors == "bisque4")]
head(bisque4ModuleGenes)

greenModuleGenes <- colnames(datExpr)[which(moduleColors == "green")]
head(greenModuleGenes)


library(ggplot2)
library(tidyverse)
library(tibble)

# -------------------------
# Prepare data
# -------------------------
datExpr <- as.data.frame(datExpr)

datExpr <- tibble::rownames_to_column(datExpr, "Time")
datExpr$Time <- traitTime  # numeric timepoints
rownames(datExpr) <- datExpr[,1]
datExpr[,1] <- NULL

# Transpose datExpr so rows = timepoints, columns = genes
datExpr_df <- as.data.frame(t(datExpr))
datExpr_df <- tibble::rownames_to_column(datExpr_df, "Gene")


datExpr_long <- datExpr_df %>%
  pivot_longer(
    cols = -Gene,              # everything except 'Gene' becomes long
    names_to = "Time",         # column name for timepoints
    values_to = "log2FC"       # column name for values
  ) %>%
  mutate(
    # Convert Time from e.g. "12_log2FoldChange" -> 12 numeric
    Time = as.numeric(sub("_log2FoldChange", "", Time))
  )

head(datExpr_long)

# Add module color for each gene
gene_colors <- data.frame(Gene = colnames(datExpr), Module = moduleColors)
datExpr_long <- left_join(datExpr_long, gene_colors, by = "Gene")

# -------------------------
# Faceted line plot
# -------------------------

ggplot(datExpr_long, aes(x = Time, y = log2FC, group = Gene, color = Module)) +
  geom_line(alpha = 0.7) +
  geom_point(size = 1) +
  scale_color_identity() +  # use the moduleColors directly
  facet_wrap(~ Module, scales = "free_y") +  # one facet per module
  theme_minimal() +
  labs(title = "Gene expression profiles per module",
       x = "Time (h)", y = "Log2 fold change") +
  scale_x_continuous(breaks = traitTime) +
  theme(legend.position = "none",
        strip.text = element_text(face = "bold"))


# GET GENE | MODULE MEMBERSHIP
gene_module_df <- data.frame(
  Gene   = datExpr_df$Gene,
  Module = moduleColors
)
write.csv(gene_module_df, "gene_module_assignment_WGCNA.csv", row.names = FALSE)
