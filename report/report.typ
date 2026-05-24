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

== Exploratory Data Analysis
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


=== Column Distributions
#figure(
  image("../images/distributions.png", width: 75%),
  caption: "Columns distribution of X and Y, after a transformation.",
) <fig:dists_no_scaling>


// #figure(
//   image("../plots/pairwise_scatterplots.png", width: 90%),
//   caption: "Pairwise scatterplot.",
// ) <fig:scatterplots>


=== t-SNE
#figure(
  image("../images/tsne.png", width: 60%),
  caption: "t-SNE ignorant analysis",
) <fig:tsne>


=== Preprocessing Strategy
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


== Clustering
#figure(
  grid(
    columns: 1,
    rows: 3,
    image("../images/3_silhouette_comparison.png", width: 70%), 
    image("../images/3_davies_bouldin_comparison.png", width: 70%),
    image("../images/3_calinski_harabasz_comparison.png", width: 70%)
  ),
  caption: "Clustering Evaluation"
)


=== Clustering Validation

== Bayesian Network

=== Conditional Independence Tests

=== PC Algorithm
#figure(
  image("../plots/dag.png", width: 90%),
  caption: "Directed Acyclic Graph builded using PC",
) <fig:dag_bn>
