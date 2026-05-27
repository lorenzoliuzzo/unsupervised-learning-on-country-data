#import "presentation_conf.typ": *
#import "@preview/subpar:0.2.2": grid as subgrid

#show: bamboo-theme.with(
	title: "Unsupervised Learning on Country Data", 
	author: "Luca Cicu - Lorenzo Liuzzo", 
	date: datetime.today(),
)

// // Global overrides to prevent slide overflow
// #show figure.caption: set text(size: 0.72em)
// #show figure: set block(spacing: 0.5em)

#set align(horizon)
#title-slide()


== Dataset Description
#let data_dict = csv("../data/data-dictionary.csv")

#figure(
  text(size: 0.75em)[
    #table(
      columns: 2,
      stroke: none,
      align: center,
      table.hline(stroke: 1pt),
      table.header(..data_dict.first()),
      table.hline(stroke: 1pt),
      ..data_dict.slice(1).flatten(),
      table.hline(stroke: 1pt),
    )
  ]
)

#focus-slide("Exploratory Data Analysis")

== t-SNE Visualization
#figure(image("../images/tsne.png", width: 45%))

== Feature Distributions
#figure(image("../images/distributions.png", width: 40%))

== Scaled Feature Distributions
#subgrid(
  columns: 2,
  gutter: 8pt,
  figure(image("../images/distributions_std.png", width: 80%), caption: "Standard Scaled"), <a>,
  figure(image("../images/distributions_pwr.png", width: 80%), caption: "Power Transformed"), <b>,
)

== Preprocessing Comparison
#subgrid(
  columns: 2,
  gutter: 8pt,
  figure(image("../images/comparison_distributions.png", width: 80%)), <a>,
  figure(image("../images/comparison_boxplots.png", width: 80%)), <b>,
)

== Scaled Feature Correlations
#subgrid(
  columns: 2,
  gutter: 8pt,
  figure(image("../images/correlations.png", width: 80%), caption: "Raw/Standard Scaled"), <a>,
  figure(image("../images/correlations_pwr.png", width: 80%), caption: "Power Transformed"), <b>,
)

#focus-slide("Cluster Analysis")

== K-Means Diagnostic
#figure(image("../images/diagnostic_kmeans.png", width: 100%))

== Agglomerative Diagnostic
#figure(image("../images/diagnostic_agglomerative.png", width: 100%))

== HDBSCAN Diagnostic
#figure(image("../images/diagnostic_hdbscan.png", width: 100%))

== Comparison Scores
#subgrid(
  columns: 2,
  gutter: 8pt,
  figure(image("../images/comparison_silhouette_score.png", width: 100%)),
  figure(image("../images/comparison_davies_bouldin_index.png", width: 100%)),
)

== Proximity Matrix
#figure(image("../images/proximity_matrices.png", width: 100%))


== K-Means Results
#subgrid(
  columns: (22fr, 40fr),
  gutter: 8pt,
  figure(image("../images/kmeans_tsne.png", width: 100%)),
  figure(image("../images/kmeans_map.png", width: 100%))
)

== Agglomerative Results
#subgrid(
  columns: (22fr, 40fr),
  gutter: 8pt,
  figure(image("../images/agglomerative_tsne.png", width: 100%)),
  figure(image("../images/agglomerative_map.png", width: 100%))
)

== HDBSCAN Results
#subgrid(
  columns: (22fr, 40fr),
  gutter: 8pt,
  figure(image("../images/hdbscan_tsne.png", width: 100%)),
  figure(image("../images/hdbscan_map.png", width: 100%))
)

== Casual Bayesian Network
#figure(
  image("../images/causal_dag.png", width: 50%),
  caption: [DAG obtained through the PC algorithm.],
)

#focus-slide("Thank You for the Attention")