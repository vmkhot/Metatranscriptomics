library(tidyverse)
library(igraph)
library(Hmisc)      # for rcorr()
library(stats)      # for p.adjust()

# --- Read and prepare data ---
df <- read.csv("wide_cyano_results_vs_T0.csv", row.names = 1, check.names = FALSE)

# Transpose so rows = samples, columns = genes
datExpr <- t(df)

# --- Compute correlations and p-values ---
rc <- rcorr(datExpr, type = "pearson")

# Extract correlation coefficients and p-values
cor_mat <- rc$r
p_mat <- rc$P

# --- Convert to long format ---
edges <- as.data.frame(as.table(cor_mat)) %>%
  rename(Var1 = Var1, Var2 = Var2, Correlation = Freq) %>%
  mutate(P.value = as.vector(p_mat))

# Remove self-correlations first
edges <- edges %>% filter(Var1 != Var2)

edges <- edges %>%
  filter(Var1 != Var2) %>%
  mutate(
    Var1 = as.character(Var1),
    Var2 = as.character(Var2),
    g1 = pmin(Var1, Var2),
    g2 = pmax(Var1, Var2)
  ) %>%
  distinct(g1, g2, .keep_all = TRUE) %>%
  select(Var1 = g1, Var2 = g2, Correlation, P.value)


# --- Multiple testing correction ---
edges <- edges %>%
  mutate(FDR = p.adjust(P.value, method = "BH"))   # Benjamini-Hochberg correction

# --- Filter for significant + strong correlations ---
edges_filtered_95 <- edges %>%
  filter(abs(Correlation) > 0.95, FDR < 0.05)

# --- Build igraph object ---
g <- graph_from_data_frame(edges_filtered_95, directed = FALSE)

# --- Quick visualization ---
plot(
  g,
  vertex.size = 5,
  vertex.label = NA,
  edge.width = E(g)$Correlation * 2,
  edge.color = "darkgrey"
)

# --- Save results ---
write.csv(edges_filtered_95, "gene_coexpression_pear0_95_FDR0_05.csv", row.names = FALSE)
