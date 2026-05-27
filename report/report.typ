


#import "conf.typ": *
#import "@preview/subpar:0.2.2": grid as subgrid

#show: conf.with(
  title: "Unsupervised Learning on Country Data",
  authors: (
    (
      name: "Luca Cicu",
      matn: 100001,
      email: "l.cicu@campus.unimib.it",
    ),
    (
      name: "Lorenzo Liuzzo",
      matn: 942123,
      email: "l.liuzzo2@campus.unimib.it",
    ),
  ),
  abstract: lorem(50),
  references: none,
)


=== Exploratory Data Analysis
#let data_dict = csv("../data/data-dictionary.csv")

#figure(
  table(
    columns: 2,
    stroke: none,
    align: center,
    table.hline(stroke: 1pt),
    table.header(..data_dict.first()),
    table.hline(stroke: 1pt),
    ..data_dict.slice(1).flatten(),
    table.hline(stroke: 1pt),
  ),
  gap: 15pt,
  caption: "Dataset description",
  supplement: "Table",
)


== t-SNE Visualization

#figure(
  image("../images/tsne.png", width: 50%),
  caption: [t-SNE scatter plot used to visualize the dataset in a two-dimensional space (perplexity=10). Highlighting the most extreme observation for GDP (per capita),child mortality, life expectancy and fertility, the projection reveals a clear separation between countries with different socio-economic profiles.],
) <fig:t_sne>

== Column Distributions

#figure(
  image("../images/distributions.png", width: 55%),
  caption: [Histograms showing the distribution of each numerical variable. The univariate distributions show that several development indicators are highly skewed and contain extreme values, motivating the use pre-processing strategies before further analysis.],
) <fig:dists_no_scaling>


// #figure(
//   image("../images/../plots/pairwise_scatterplots.png", width: 90%),
//   caption: "Pairwise scatterplot.",
// ) <fig:scatterplots>



== Preprocessing Strategy
#subgrid(
  columns: 2,
  gutter: 10pt,
  figure(image("../images/distributions_std.png", width: 100%),  caption: "Standard Scaled"), <a>,
  figure(image("../images/distributions_pwr.png", width: 100%), caption: "Power Transformed"), <b>,
  caption: [Comparison of variable distributions before and after power transformation in order to assess the effect of preprocessing on data shape. The comparison between standard scaling and power transformation shows that the power transformation reduces skewness and makes the variables more suitable for distance-based clustering.],
  label: <fig-dists-scaled>
)

#subgrid(
  columns: 2,
  gutter: 10pt,
  figure(image("../images/correlations.png", width: 100%),  caption: "Raw/Standard Scaled"), <a>,
  figure(image("../images/correlations_pwr.png", width: 100%), caption: "Power Transformed"), <b>,
  caption: [Correlation heatmaps used to compare pairwise relationships between variables before and after power transformation. The correlation matrices show that the main relationships among variables are preserved and in some case enhanced.],
  label: <fig-correlations>
)

#subgrid(
  columns: 2,
  gutter: 10pt,
  figure(image("../images/comparison_distributions.png", width: 100%), 
  caption: []), <a>,
  figure(image("../images/comparison_boxplots.png", width: 100%), caption: "Box Plots"), <b>,
  caption: [Density plots and boxplots used to compare the distribution and spread of variables under different preprocessing strategies. Density plots and boxplots confirm that the power-transformed data have more balanced distributions and fewer extreme outliers than the simply scaled data.],
  label: <fig-comparison>
)

== Cluster Analysis

=== Clustering Comparison

#subgrid(
  columns: 2,
  gutter: 10pt,
  figure(image("../images/comparison_silhouette_score.png", width: 100%)),<a>,
  figure(image("../images/comparison_davies_bouldin_index.png", width: 100%)),<b>,
  caption: [Boxplots comparing the clustering performance metrics obtained by K-Means, Agglomerative clustering and HDBSCAN. The model comparison shows that HDBSCAN performs better overall than K-Means and Agglomerative clustering, with higher silhouette scores and lower Daviesâ€“Bouldin values.],
  label: <agglomerative_visual>
)


#figure(
  image("../images/diagnostic_kmeans.png", width: 90%),
  caption: [Line plots of Silhouette Score and Daviesâ€“Bouldin Index used to decide among different K-Means starting configurations. The K-Means validation curves indicate that a two-cluster solution provides the best trade-off between cluster separation and compactness.],
) <fig:kmeans_diagnostic>

#figure(
  image("../images/diagnostic_agglomerative.png", width: 90%),
  caption: [Line plots of Silhouette Score and Daviesâ€“Bouldin Index used to decide among different Agglomerative algorithm configurations. The best solution coincide with five different clusters; anyway since the last three contains less then 5% of total observations we consider just the biggest two.],
) <fig:agglomerative_diagnostic>

#figure(
  image("../images/diagnostic_hdbscan.png", width: 90%),
  caption: [Line plots of Silhouette Score and Daviesâ€“Bouldin Index used to evaluate different HDBSCAN parameter settings. HDBSCAN shows a strong density-based structure, reaching high silhouette values and low Daviesâ€“Bouldin scores for the selected configuration.],
) <fig:dbscan_diagnostic>

=== Matrix
#figure(image("../images/proximity_matrices.png", width: 100%), 
  caption: [Distance heatmaps used to visualize the cluster structure produced by the different clustering algorithms. The ordered distance heatmaps visualize the internal structure found by each algorithm, showing clearer block patterns where countries are grouped into more coherent clusters.])

=== Centroids Comparison
// 1. Load the generated datasets
#let kmeans = csv("../data/kmeans_centroids.csv")
#let agglo = csv("../data/agglomerative_centroids.csv")
#let hdbscan = csv("../data/hdbscan_centroids.csv")

// 2. Group them to iterate through dynamically
#let datasets = (kmeans, agglo, hdbscan)
#let method-names = ("K-Means", "Agglomerative", "HDBSCAN")
#let features = kmeans.at(0).slice(1)

// Helper Functions: These safely extract data just in case a method 
// (like DBSCAN) only managed to find 1 valid cluster.
#let safe-val(data, r, c, is-pct) = {
  if data.len() > r {
    let val = data.at(r).at(c)
    if is-pct { val + "%" } else { val }
  } else { "-" }
}

#let safe-col-name(data, r) = {
  if data.len() > r { "Cluster " + data.at(r).at(0) } else { "-" }
}

#figure(
  caption: [Features of the Top 2 Centroids Across Clustering Methods],
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: (col, row) => if col == 0 { center + horizon } else { center + horizon },
    inset: 6pt,
    
    stroke: (col, row) => (
      top: if row == 0 { 1pt + black } else { none },
      bottom: if row == 1 { 0.5pt + black } else if row == features.len() + 1 { 1pt + black } else { none }
    ),
    
    [],
    ..method-names.map(m => table.cell(colspan: 2)[*#m*]),
    
    [*Feature*],
    ..datasets.map(d => (
      strong(safe-col-name(d, 1)), 
      strong(safe-col-name(d, 2))  
    )).flatten(),
    
    ..features.enumerate().map(((i, feat)) => {
      let is-pct = feat == "Observation_Percentage"
      let clean-feat = feat.replace("_", " ")       
      (
        clean-feat,
        ..datasets.map(d => (
          safe-val(d, 1, i + 1, is-pct),
          safe-val(d, 2, i + 1, is-pct)
        )).flatten()
      )
    }).flatten()
  )
)

#subgrid(
  columns: (22fr, 40fr),
  gutter: 10pt,
  figure(image("../images/kmeans_tsne.png", width: 100%)), <a>,
  figure(image("../images/kmeans_map.png", width: 100%)), <b>,
  caption: [t-SNE scatter plot showing the cluster assignments obtained with the K-Means algorithm. K-Means separates the countries into two broad development profiles: a high-risk group with higher child mortality and fertility, and a more developed group with higher income, GDP per capita and life expectancy. World map showing the geographical distribution of the clusters obtained with K-Means. The K-Means world map shows that the high-risk cluster is geographically concentrated in Sub-Saharan Africa and parts of South Asia, while the more developed cluster dominates Europe, North America and other high-income regions.], 
  label: <fig-dists-scaled>
)

#subgrid(
  columns: (22fr, 40fr),
  gutter: 10pt,
  figure(image("../images/agglomerative_tsne.png", width: 100%)), <a>,
  figure(image("../images/agglomerative_map.png", width: 100%)), <b>,
  caption: [t-SNE scatter plot showing the cluster assignments obtained with Agglomerative clustering. Agglomerative clustering divides the data into five groups, distinguishing broad development levels while also isolating small groups of countries with extreme trade or demographic profiles. World map showing the geographical distribution of the clusters obtained with Agglomerative clustering. The Agglomerative world map highlights the spatial concentration of lower-development clusters and reveals small outlier groups that are not captured by the simpler two-cluster solution],
  label: <fig-dists-scaled>
)

#subgrid(
  columns: (22fr, 40fr),
  gutter: 10pt,
  figure(image("../images/hdbscan_tsne.png", width: 100%)), <a>,
  figure(image("../images/hdbscan_map.png", width: 100%)), <b>,
  caption: [In <a> t-SNE scatter plot showing the cluster assignments obtained with HDBSCAN. HDBSCAN identifies a compact high-risk cluster and a compact higher-development cluster, while leaving many intermediate countries outside dense cluster regions. In <b> the world map showing the geographical distribution of the clusters and noise points detected by HDBSCAN. The HDBSCAN map shows the geographic location of dense clusters and noise points, emphasizing that the algorithm detects only countries with sufficiently similar profiles.],
  label: <fig-dists-scaled>
)


// #figure(
//   table(
//     columns: 3,
//     stroke: none,
//     align: center,
//     table.hline(stroke: 1pt),
//     table.header(..data_dict.first()),
//     table.hline(stroke: 1pt),
//     ..data_dict.slice(1).flatten(),
//     table.hline(stroke: 1pt),
//   ),
//   gap: 15pt,
//   caption: "coherence table",
//   supplement: "Table",
// )



== Bayesian Network

=== Conditional Independence Tests



=== PC Algorithm
#figure(
  image("../images/causal_dag.png", width: 90%),
  caption: [Directed acyclic graph obtained through the PC algorithm to represent conditional dependence relationships among variables. The PC algorithm graph summarizes conditional independence relationships among the variables, suggesting a dependency structure in which child mortality plays a central role between economic, demographic and health indicators.],
) <fig:dag_bn>

