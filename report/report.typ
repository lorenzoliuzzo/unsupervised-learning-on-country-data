#import "conf.typ": *

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
#lorem(40)

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
  image("../images/2_distributions_No_Scaling.png", width: 75%),
  caption: "Columns distribution of X and Y, after a transformation.",
) <fig:dists_no_scaling>


=== Correlation Matrix
#figure(
  image("../plots/correlation.png", width: 60%),
  caption: "Correlation matrix",
) <fig:corr_matrix>


#figure(
  image("../plots/pairwise_scatterplots.png", width: 90%),
  caption: "Pairwise scatterplot.",
) <fig:scatterplots>


=== t-SNE
#figure(
  image("../images/tsne_plot.png", width: 60%),
  caption: "",
) <fig:tsne>

// #figure(
//   image("../images/2_distributions_Power_Transform.png", width: 60%),
//   caption: "Histograms and distributions for the columns",
// ) <fig:dists_pwr_scaling>

=== Preprocessing Strategy
// #figure(
//   image("../images/2_comparison_distributions.png", width: 60%),
//   caption: "Columns distribution of X and Y, after a transformation.",
// ) <fig:dists_combined>

// #figure(
//   image("../images/2_comparison_boxplots.png", width: 60%),
//   caption: "Columns distribution of X and Y, after a transformation.",
// ) <fig:boxplots_combined>


#figure(
  grid(
    columns: 2,
    rows: 1,
    gutter: 10pt,
    image("../images/2_comparison_distributions.png", width: 100%), 
    image("../images/2_comparison_boxplots.png", width: 104%),
  ),
  caption: "Diocan"
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
  caption: "Diocan"
)


=== Clustering Validation

== Bayesian Network

=== Conditional Independence Tests

=== PC Algorithm
#figure(
  image("../plots/dag.png", width: 90%),
  caption: "Directed Acyclic Graph builded using PC",
) <fig:dag_bn>
