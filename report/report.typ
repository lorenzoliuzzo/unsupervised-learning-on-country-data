

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
  image("../images/tsne.png", width: 60%),
  caption: "t-SNE (perplexity=10).",
) <fig:t_sne>

== Column Distributions

// #subgrid(
//   columns: 2,
//   gutter: 10pt,
//   figure(image("../images/distributions.png", width: 100%)),<a>,
//   // figure(image("../images/pairwise_scatterplots.png", width: 100%)),<b>,
//   caption: [Columns distribution of X and Y after a transformation (left),
//     and pairwise scatterplot (right)],
//   label: <kmeans_visual>
// )

#figure(
  image("../images/distributions.png", width: 75%),
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

=== Clustering Optimization

#figure(
  image("../images/diagnostic_kmeans.png", width: 90%),
  caption: "Silouhette and Davies Bouldin index for best K-means.",
) <fig:kmeans_diagnostic>


#figure(
  image("../images/diagnostic_agglomerative.png", width: 90%),
  caption: "Silouhette and Daviesâ€“Bouldin index for best Agglomerative",
) <fig:agglomerative_diagnostic>

#figure(
  image("../images/diagnostic_hdbscan.png", width: 90%),
  caption: "Silouhette and Daviesâ€“Bouldin index for best HDBSCAN",
) <fig:dbscan_diagnostic>


=== Clustering Comparison

#subgrid(
  columns: 2,
  gutter: 10pt,
  figure(image("../images/algo_distribution_silhouette_score.png", width: 100%)),<a>,
  figure(image("../images/algo_distribution_davies_bouldin_index.png", width: 100%)),<b>,
  caption: [index comparison],
  label: <agglomerative_visual>
)

#figure(image("../images/proximity_matrices.png", width: 100%)),<c>,

// #subgrid(
//   columns: 3,
//   gutter: 10pt,
//   figure(image("../images/kmeans_similaritymatrix.png", width: 100%)),<a>,
//   figure(image("../images/agglomerative_similaritymatrix.png", width: 100%)),<b>,
//   figure(image("../images/dbscan_similaritymatrix.png", width: 100%)),<c>,
//   caption: [similarity matrix],
//   label: <similarity_matrix>
// )


=== Clustering executions
// Load your specific generated CSV

=== K-Means
#let data = csv("../data/kmeans_centroids.csv")
#let headers = data.at(0)

#align(center)[
  #table(
    columns: headers.len(),
    align: center + horizon,
    fill: (col, row) => if row == 0 { luma(230) } else { none },
    stroke: 0.5pt + luma(100),
    
    // Render Header Row
    ..headers.map(h => strong(h)),
    
    // Render Data Rows and append "%" to the last column
    ..data.slice(1).map(row => {
      let formatted_row = row.slice(0, -1)
      formatted_row.push(row.last() + "%")
      formatted_row
    }).flatten()
  )
]

#figure(image("../images/tsne_kmeans.png", width: 60%))
#figure(image("../images/map_kmeans.png", width: 100%))

// #subgrid(
//   columns: 2,
//   gutter: 10pt,
//   figure(image("../images/tsne_kmeans.png", width: 100%)),<a>,
//   figure(image("../images/map_kmeans.png", width: 100%)),<b>,
//   caption: [k-means in low dimension and geomap],
//   label: <kmeans_visual>
// )

// #let data_dict = csv("../data/kmeans_centroids.csv")

// #figure(
//   table(
//     columns: 9,
//     stroke: none,
//     align: center,
//     table.hline(stroke: 1pt),
//     table.header(..data_dict.first()),
//     table.hline(stroke: 1pt),
//     ..data_dict.slice(1).flatten(),
//     table.hline(stroke: 1pt),
//   ),
//   gap: 15pt,
//   caption: "K-means centroids",
//   supplement: "Table",
// )
// 

=== Agglomerative
#let data = csv("../data/agglomerative_centroids.csv")
#let headers = data.at(0)

#align(center)[
  #table(
    columns: headers.len(),
    align: center + horizon,
    fill: (col, row) => if row == 0 { luma(230) } else { none },
    stroke: 0.5pt + luma(100),
    
    // Render Header Row
    ..headers.map(h => strong(h)),
    
    // Render Data Rows and append "%" to the last column
    ..data.slice(1).map(row => {
      let formatted_row = row.slice(0, -1)
      formatted_row.push(row.last() + "%")
      formatted_row
    }).flatten()
  )
]

#subgrid(
  columns: 2,
  gutter: 10pt,
  figure(image("../images/tsne_agglomerative.png", width: 100%)),<a>,
  figure(image("../images/map_agglomerative.png", width: 100%)),<b>,
  caption: [Agglomerative in low dimension and geomap],
  label: <agglomerative_visual>
)

// #let data_dict = csv("../data/agglomerative_centroids.csv")

// #figure(
//   table(
//     columns: 9,
//     stroke: none,
//     align: center,
//     table.hline(stroke: 1pt),
//     table.header(..data_dict.first()),
//     table.hline(stroke: 1pt),
//     ..data_dict.slice(1).flatten(),
//     table.hline(stroke: 1pt),
//   ),
//   gap: 15pt,
//   caption: "Agglomerative centroids",
//   supplement: "Table",
// )

==== HDBSCAN
#let data = csv("../data/hdbscan_centroids.csv")
#let headers = data.at(0)

#align(center)[
  #table(
    columns: headers.len(),
    align: center + horizon,
    fill: (col, row) => if row == 0 { luma(230) } else { none },
    stroke: 0.5pt + luma(100),
    
    // Render Header Row
    ..headers.map(h => strong(h)),
    
    // Render Data Rows and append "%" to the last column
    ..data.slice(1).map(row => {
      let formatted_row = row.slice(0, -1)
      formatted_row.push(row.last() + "%")
      formatted_row
    }).flatten()
  )
]

#subgrid(
  columns: 2,
  gutter: 10pt,
  figure(image("../images/tsne_hdbscan.png", width: 100%)),<a>,
  figure(image("../images/map_hdbscan.png", width: 100%)),<b>,
  caption: [HDBSCAN in low dimension and geomap],
  label: <dbscan_visual>
)

// #let data_dict = csv("../data/HDBSCAN_centroids.csv")

// #figure(
//   table(
//     columns: 9,
//     stroke: none,
//     align: center,
//     table.hline(stroke: 1pt),
//     table.header(..data_dict.first()),
//     table.hline(stroke: 1pt),
//     ..data_dict.slice(1).flatten(),
//     table.hline(stroke: 1pt),
//   ),
//   gap: 15pt,
//   caption: "JDBSCAN centroids",
//   supplement: "Table",
// )

// #let data_dict = csv("../data/clustering_summaries.csv")

// #figure(
//   table(
//     columns: 4,
//     stroke: none,
//     align: center,
//     table.hline(stroke: 1pt),
//     table.header(..data_dict.first()),
//     table.hline(stroke: 1pt),
//     ..data_dict.slice(1).flatten(),
//     table.hline(stroke: 1pt),
//   ),
//   gap: 15pt,
//   caption: "Summary of the different results",
//   supplement: "Table",
// )

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
  image("../images/causal_dag_hierarchical.png", width: 90%),
  caption: "Directed Acyclic Graph builded using PC",
) <fig:dag_bn>

#figure(image("../images/correlations_pwr.png", width: 100%), caption: "Power Transformed"), <b>,
