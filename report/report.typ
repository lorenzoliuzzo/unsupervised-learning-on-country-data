#import "report_conf.typ": *

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
#lorem(40)

#figure(
  image("../plots/column_distributions.png", width: 60%),
  caption: "Histograms and distributions for the columns",
) <fig:col_distributions>

#figure(
  image("../plots/column_distributions.png", width: 60%),
  caption: "Columns distribution of X and Y, after a transformation.",
) <fig:t_col_distributions>



=== Correlation Matrix
#lorem(40)

#figure(
  image("../plots/correlation.png", width: 60%),
  caption: "Correlation matrix",
) <fig:corr_matrix>


#figure(
  image("../plots/pairwise_scatterplots.png", width: 90%),
  caption: "Pairwise scatterplot.",
) <fig:scatterplots>


== Clustering
#lorem(40)

#figure(
  image("../plots/correlation.png", width: 60%),
  caption: "Results of clustering algorithms.",
) <fig:clustering_results>

=== Clustering Validation

== Bayesian Network

=== Conditional Independence Tests

=== PC Algorithm
#figure(
  image("../plots/dag.png", width: 90%),
  caption: "Directed Acyclic Graph builded using PC",
) <fig:dag_bn>
