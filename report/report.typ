

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
  caption: "t-SNE (perplexity=10).",
) <fig:t_sne>

== Column Distributions

#figure(
  image("../images/distributions.png", width: 55%),
  caption: "Columns distribution of X and Y, after a transformation.",
) <fig:dists_no_scaling>


// #figure(
//   image("../plots/pairwise_scatterplots.png", width: 90%),
//   caption: "Pairwise scatterplot.",
// ) <fig:scatterplots>



== Preprocessing Strategy
#subgrid(
  columns: 2,
  gutter: 10pt,
  figure(image("../images/distributions_std.png", width: 100%),  caption: "Standard Scaled"), <a>,
  figure(image("../images/distributions_pwr.png", width: 100%), caption: "Power Transformed"), <b>,
  caption: [Correlations],
  label: <fig-dists-scaled>
)

#subgrid(
  columns: 2,
  gutter: 10pt,
  figure(image("../images/correlations.png", width: 100%),  caption: "Raw/Standard Scaled"), <a>,
  figure(image("../images/correlations_pwr.png", width: 100%), caption: "Power Transformed"), <b>,
  caption: [Correlations],
  label: <fig-correlations>
)

#subgrid(
  columns: 2,
  gutter: 10pt,
  figure(image("../images/comparison_distributions.png", width: 100%),  caption: "Distributions"), <a>,
  figure(image("../images/comparison_boxplots.png", width: 100%), caption: "Box Plots"), <b>,
  caption: [Comparison],
  label: <fig-comparison>
)

== Cluster Analysis

=== Clustering Comparison

#subgrid(
  columns: 2,
  gutter: 10pt,
  figure(image("../images/comparison_silhouette_score.png", width: 100%)),<a>,
  figure(image("../images/comparison_davies_bouldin_index.png", width: 100%)),<b>,
  caption: [index comparison],
  label: <agglomerative_visual>
)


#figure(
  image("../images/diagnostic_kmeans.png", width: 90%),
  caption: "Silouhette and Davies Bouldin index for best K-means.",
) <fig:kmeans_diagnostic>

#figure(
  image("../images/diagnostic_agglomerative.png", width: 90%),
  caption: "Silouhette and Davies Bouldin index for best Agglomerative",
) <fig:agglomerative_diagnostic>

#figure(
  image("../images/diagnostic_hdbscan.png", width: 90%),
  caption: "Silouhette and Davies Bouldin index for best HDBSCAN",
) <fig:dbscan_diagnostic>

=== Matrix
#figure(image("../images/proximity_matrices.png", width: 100%), caption: "")

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
  figure(image("../images/kmeans_tsne.png", width: 100%), caption: ""), <a>,
  figure(image("../images/kmeans_map.png", width: 100%), caption: ""), <b>,
  caption: [],
  label: <fig-dists-scaled>
)

#subgrid(
  columns: (22fr, 40fr),
  gutter: 10pt,
  figure(image("../images/agglomerative_tsne.png", width: 100%),  caption: ""), <a>,
  figure(image("../images/agglomerative_map.png", width: 100%), caption: ""), <b>,
  caption: [Correlations],
  label: <fig-dists-scaled>
)

#subgrid(
  columns: (22fr, 40fr),
  gutter: 10pt,
  figure(image("../images/hdbscan_tsne.png", width: 100%),  caption: ""), <a>,
  figure(image("../images/hdbscan_map.png", width: 100%), caption: ""), <b>,
  caption: [Correlations],
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
  caption: "Directed Acyclic Graph builded using PC",
) <fig:dag_bn>
