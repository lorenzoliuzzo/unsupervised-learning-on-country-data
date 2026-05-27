#import "conf.typ": *
#import "@preview/subpar:0.2.2": grid as subgrid

#show: conf.with(
  title: "Unsupervised Learning on Country Data",
  authors: (
    (
      name: "Luca Cicu",
      matn: 895545,
      email: "l.cicu@campus.unimib.it",
    ),
    (
      name: "Lorenzo Liuzzo",
      matn: 942023,
      email: "l.liuzzo2@campus.unimib.it",
    ),
  ),
  abstract: [
    This report applies unsupervised learning techniques to a country dataset. The objective is to identify latent structures among countries comparing different clustering strategies in terms of both statistical performance and interpretability. After an exploratory phase, three clustering approaches, K-Means, Agglomerative clustering and HDBSCAN are then compared, pointing out that the data contain a clear separation between countries with high-risk development profiles and countries with stronger socio-economic indicators. Finally, a Bayesian network is used to explore causal relationships in the data. 
  ],
  references: bibliography("main.bib", full: true, style: "ieee"),
)


= Exploratory Data Analysis
The dataset contains numerical indicators describing several dimensions of socio-economic development: child mortality, exports, health expenditure, imports, income, inflation, life expectancy, fertility and GDP per capita, as detailed in @tab-data-dict.

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
) <tab-data-dict>

The first exploratory step consists of visualizing the observations in a lower-dimensional space. As displayed in @fig-tsne, the t-SNE projection (with perplexity = 10) shows that countries tend to organize along a development gradient structured in two groups, with extreme observations in terms of GDP per capita, child mortality, life expectancy and fertility located in distinct areas of the plot. This suggests that the dataset contains meaningful latent structure and that clustering methods may be able to identify coherent groups of countries.

#figure(
  image("../images/tsne.png", width: 50%),
  caption: [t-SNE scatter plot used to visualize the dataset in a two-dimensional space (perplexity=10). Highlighting the most extreme observation for GDP (per capita), child mortality, life expectancy and fertility, the projection reveals a clear separation between countries with different socio-economic profiles.],
) <fig-tsne>

#figure(
  image("../images/distributions.png", width: 55%),
  caption: [Histograms showing the distribution of each numerical variable. The univariate distributions show that several development indicators are highly skewed and contain extreme values, motivating the use of pre-processing strategies before further analysis.],
) <fig-dists-no-scaling>

The univariate histograms in @fig-dists-no-scaling reveal that several variables are strongly skewed and affected by extreme values. This is especially relevant for economic variables such as income and GDP per capita, where a small number of very high-income countries can strongly influence the scale of the data. Similar issues also appear in variables related to mortality, fertility and inflation. These distributional characteristics are highly relevant due to the distance-based nature of many clustering algorithms. Consequently, a robust preprocessing strategy is required before fitting the clustering models.

== Preprocessing
Variables are transformed using a power transformation (Yeo-Johnson) followed by standard scaling. The power transformation is applied first to handle the underlying skewness, stabilize variance, and make the distribution closer to a symmetric shape. Standard scaling is then applied to bring all indicators onto a perfectly comparable scale with zero mean and unit variance for distance-based clustering. Technically, this improves the behaviour of clustering algorithms because distances become less driven by a few extreme observations.
To evaluate the effect of these transformations, @fig-comparison presents density plots and boxplots under different preprocessing strategies.

#subgrid(
  columns: 2,
  gutter: 10pt,
  figure(image("../images/distributions_std.png", width: 100%),  caption: "Standard Scaled"), <fig-dist-std>,
  figure(image("../images/distributions_pwr.png", width: 100%), caption: "Power Transformed"), <fig-dist-pwr>,
  caption: [Comparison of variable distributions before and after power transformation in order to assess the effect of preprocessing on data shape. The comparison shows that the power transformation reduces skewness and makes the variables more suitable for distance-based clustering.],
  label: <fig-preprocessing-distributions>
)

#subgrid(
  columns: 2,
  gutter: 10pt,
  figure(image("../images/comparison_distributions.png", width: 100%), caption: "Distributions"), <fig-comp-dist>,
  figure(image("../images/comparison_boxplots.png", width: 100%), caption: "Box Plots"), <fig-comp-box>,
  caption: [Density plots and boxplots used to compare the distribution and spread of variables under different preprocessing strategies. Density plots and boxplots confirm that the power-transformed data have more balanced distributions and fewer extreme outliers than the simply scaled data.],
  label: <fig-comparison>
)

#v(15pt)
The comparison between standard-scaled and power-transformed variables confirms the importance of this preprocessing step. The density plots and boxplots show that the power-transformed data contain fewer extreme values and more comparable spreads across variables. This does not mean that all outliers are removed, but rather that their influence on the geometry of the dataset is reduced. As a consequence, countries are compared on a more balanced multivariate scale. From the correlation point of view, as seen in @fig-correlations, the relationships between variables remain the same and in some cases are enhanced by the power transformation.

#subgrid(
  columns: 2,
  gutter: 10pt,
  figure(image("../images/correlations.png", width: 100%),  caption: "Raw/Standard Scaled"), <fig-corr-raw>,
  figure(image("../images/correlations_pwr.png", width: 100%), caption: "Power Transformed"), <fig-corr-pwr>,
  caption: [Correlation heatmaps used to compare pairwise relationships between variables before and after power transformation. The correlation matrices show that the main relationships among variables are preserved and in some cases enhanced.],
  label: <fig-correlations>
)


= Cluster Analysis
After preprocessing, we compare three different clustering algorithms distinct in their nature: K-Means, Agglomerative clustering, and HDBSCAN.
- K-Means is a centroid-based method that works well when clusters are compact, relatively spherical and similar in size. Its principal limitation is related to the correct choice of the number of groups.
- The Agglomerative approach provides a hierarchical alternative starting from individual observations and progressively merging them according to a linkage criterion. This allows capturing nested structures in the data. By cutting the dendrogram at a specific cophenetic distance, we can objectively extract the desired number of macro-clusters. 
- Differently from the previous two, HDBSCAN is density-based: it does not require the number of clusters to be fixed in advance and it identifies groups of observations that form dense regions in the feature space, classifying less stable observations as noise. If a density-based algorithm labels the majority of the dataset as noise, it may indicate that the underlying geometry of global country development does not consist of high-density islands, but rather a continuous socio-economic gradient.

=== Clustering Comparison
Two internal validation metrics were then computed in order to assess partition quality. The Silhouette Score measures how similar an observation is to its own cluster compared with other clusters, while the Davies-Bouldin Index measures the average similarity between each cluster and its most similar alternative cluster. If in the first case higher values indicate better separation and greater internal cohesion, in the second lower values indicate better clustering performance.

For the individual algorithms, the results of the best configurations are coherent for both metrics, as shown in @fig-kmeans-diagnostic, @fig-agglomerative-diagnostic, and @fig-hdbscan-diagnostic.

#figure(
  image("../images/diagnostic_kmeans.png", width: 90%),
  caption: [Line plots of Silhouette Score and Davies–Bouldin Index used to decide among different K-Means starting configurations. The K-Means validation curves indicate that a two-cluster solution provides the best trade-off between cluster separation and compactness.],
) <fig-kmeans-diagnostic>

#figure(
  image("../images/diagnostic_agglomerative.png", width: 90%),
  caption: [Line plots of Silhouette Score and Davies–Bouldin Index used to decide among different Agglomerative algorithm configurations. The optimal cut naturally corresponds to a larger group of distinct sub-clusters; however, we can extract the two most substantial groups by cutting the dendrogram higher up in the hierarchy to reflect the global socio-economic macro-partition.],
) <fig-agglomerative-diagnostic>

#figure(
  image("../images/diagnostic_hdbscan.png", width: 90%),
  caption: [Line plots of Silhouette Score and Davies–Bouldin Index used to evaluate different HDBSCAN parameter settings. HDBSCAN shows a strong density-based structure, reaching high silhouette values and low Davies–Bouldin scores for the selected configuration.],
) <fig-hdbscan-diagnostic>

#v(15pt)
The comparison across methods (@fig-metrics-comparison) shows that HDBSCAN performs better overall according to purely internal validation metrics. K-Means and Agglomerative clustering produce meaningful and interpretable partitions, but their performance metrics are generally weaker. This difference can be explained by the nature of the dataset and the mechanical assumptions of the algorithms. 

While K-Means and Agglomerative methods force every observation into a cluster, HDBSCAN requires a minimum density threshold to form one, classifying all points in sparser regions as noise. In this dataset, HDBSCAN classifies the majority of countries as noise. Consequently, its high Silhouette Scores and low Davies-Bouldin values are artificially inflated: the algorithm is only evaluating the extremely dense, tight "core" pockets of data while ignoring the vast majority of the observations. 

From a socio-economic perspective, this behavior highlights a critical insight: global development is not organized into isolated, highly dense islands separated by vast empty spaces. Instead, it forms a continuous socio-economic gradient. By discarding the countries that form the "bridge" of this gradient as noise, HDBSCAN fails to provide a meaningful macro-partition, proving that strictly density-based clustering is ill-suited for capturing the continuous spectrum of global development.

#subgrid(
  columns: 2,
  gutter: 10pt,
  figure(image("../images/comparison_silhouette_score.png", width: 100%)), <fig-comp-sil>,
  figure(image("../images/comparison_davies_bouldin_index.png", width: 100%)), <fig-comp-dbi>,
  caption: [Boxplots comparing the clustering performance metrics obtained by K-Means, Agglomerative clustering and HDBSCAN. The model comparison shows that HDBSCAN performs better overall than K-Means and Agglomerative clustering, with higher silhouette scores and lower Davies–Bouldin values.],
  label: <fig-metrics-comparison>
)

#v(15pt)
The distance heatmaps (@fig-proximity-matrices) provide an additional diagnostic perspective. Clearer block patterns indicate more coherent cluster structures. The heatmaps show that all three methods capture some degree of organization, but the strength and clarity of the blocks vary across algorithms, reflecting their different assumptions about the geometry of the data.

#figure(
  image("../images/proximity_matrices.png", width: 100%), 
  caption: [Distance heatmaps used to visualize the cluster structure produced by the different clustering algorithms. The ordered distance heatmaps visualize the internal structure found by each algorithm, showing clearer block patterns where countries are grouped into more coherent clusters.]
) <fig-proximity-matrices>

=== Centroids Comparison
Across all methods, the most important distinction is between countries with high-risk development profiles and countries with more favourable socio-economic conditions, summarized in @tab-centroids-comparison. The high-risk clusters are characterized by higher child mortality, higher fertility, lower income, lower GDP per capita and lower life expectancy. The more developed clusters show the opposite pattern.

If the K-Means solution is simple and interpretable, compressing the complexity of data into a binary partition, the Agglomerative one provides a more nuanced structure. The two largest clusters still follow the same general structure, but there are also smaller groups of countries with more extreme or unusual profiles. These minor clusters may reflect specific combinations of characteristics that are not captured by K-Means. However, because some of them include very few observations, they should be interpreted cautiously.

#let kmeans = csv("../data/kmeans_centroids.csv")
#let agglo = csv("../data/agglomerative_centroids.csv")
#let hdbscan = csv("../data/hdbscan_centroids.csv")

#let datasets = (kmeans, agglo, hdbscan)
#let method-names = ("K-Means", "Agglomerative", "HDBSCAN")
#let features = kmeans.at(0).slice(1)

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
    align: center + horizon,
    inset: 6pt,
    
    stroke: (col, row) => (
      // Horizontal borders
      top: if row == 0 { 1pt + black } else { none },
      bottom: if row == 1 { 0.5pt + black } else if row == features.len() + 1 { 1pt + black } else { none },
      
      // Vertical borders to separate methods cleanly (|)
      // Draws a line to the right of column 2 and column 4
      right: if (col == 2 or col == 4) and row <= features.len() + 1 { 0.5pt + black } else { none }
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
) <tab-centroids-comparison>#v(15pt)
Evaluating the spatial distribution of the groups reveals distinct global socio-economic patterns (@fig-kmeans-maps). In the first case, the first cluster is mainly concentrated in Sub-Saharan Africa and parts of South Asia, while the other is dominant in Europe and North America. This confirms that the data's intrinsic structure corresponds to recognizable global patterns.

#subgrid(
  columns: (22fr, 40fr),
  gutter: 10pt,
  figure(image("../images/kmeans_tsne.png", width: 100%)), <fig-kmeans-tsne>,
  figure(image("../images/kmeans_map.png", width: 100%)), <fig-kmeans-map>,
  caption: [t-SNE scatter plot showing the cluster assignments obtained with the K-Means algorithm. K-Means separates the countries into two broad development profiles: a high-risk group with higher child mortality and fertility, and a more developed group with higher income, GDP per capita and life expectancy. World map showing the geographical distribution of the clusters obtained with K-Means. The K-Means world map shows that the high-risk cluster is geographically concentrated in Sub-Saharan Africa and parts of South Asia, while the more developed cluster dominates Europe, North America and other high-income regions.], 
  label: <fig-kmeans-maps>
)

#v(10pt)
The Agglomerative solution (@fig-agglomerative-maps) shows a similar broad geography but introduces additional differentiation. The presence of more than two clusters allows the algorithm to isolate smaller groups of countries with specific profiles, including countries that may be extreme in terms of trade, demographic structure or economic indicators. This makes the map more detailed, although also less immediately interpretable than the K-Means map.

#subgrid(
  columns: (22fr, 40fr),
  gutter: 10pt,
  figure(image("../images/agglomerative_tsne.png", width: 100%)), <fig-agglo-tsne>,
  figure(image("../images/agglomerative_map.png", width: 100%)), <fig-agglo-map>,
  caption: [t-SNE scatter plot showing the cluster assignments obtained with Agglomerative clustering. Agglomerative clustering divides the data into groups, distinguishing broad development levels while also isolating small groups of countries with extreme trade or demographic profiles. World map showing the geographical distribution of the clusters obtained with Agglomerative clustering. The Agglomerative world map highlights the spatial concentration of lower-development clusters and reveals small outlier groups that are not captured by the simpler two-cluster solution.],
  label: <fig-agglomerative-maps>
)

Finally, HDBSCAN spatial assignments are shown in @fig-hdbscan-maps.
#subgrid(
  columns: (22fr, 40fr),
  gutter: 10pt,
  figure(image("../images/hdbscan_tsne.png", width: 100%)), <fig-hdbscan-tsne>,
  figure(image("../images/hdbscan_map.png", width: 100%)), <fig-hdbscan-map>,
  caption: [t-SNE scatter plot showing the cluster assignments obtained with HDBSCAN. HDBSCAN identifies a compact high-risk cluster and a compact higher-development cluster, while leaving many intermediate countries outside dense cluster regions. The world map shows the geographical distribution of the clusters and noise points detected by HDBSCAN, emphasizing that the algorithm detects only countries with sufficiently similar profiles.],
  label: <fig-hdbscan-maps>
)


== Bayesian Network

The final part of the analysis uses a Bayesian network learned through the PC algorithm. The algorithm has a constraint-based structure learning method that relies on conditional independence tests. In this context, the power transformation serves as a fundamental tool that better satisfies the structural test assumptions (which are, fundamentally, data independence and normality of the features).

In this analysis, the PC algorithm is not used to prove definitive causal relationships, but to explore the dependency structure suggested by the data. This distinction is important because causal interpretation requires strong assumptions, such as causal sufficiency, faithfulness and reliable conditional independence tests. Moreover, the selected significance level affects how many relationships are retained in the graph.

The learned graph suggests that child mortality plays a central role in the system. It appears as a key connecting variable between demographic, economic and health-related indicators. This is substantively meaningful because child mortality is closely associated with the broader development status of a country: it is related to health conditions, fertility patterns, life expectancy and economic resources. The network also captures dependencies involving income, GDP per capita, exports, imports and inflation, showing that economic and demographic dimensions are not independent but part of a broader structure of development, as depicted in @fig-dag-bn.

#figure(
  image("../images/causal_dag.png", width: 90%),
  caption: [Directed acyclic graph obtained through the PC algorithm to represent conditional dependence relationships among variables. The PC algorithm graph summarizes conditional independence relationships among the variables, suggesting a dependency structure in which child mortality plays a central role between economic, demographic and health indicators.],
) <fig-dag-bn>


= Conclusion

This report systematically explored the underlying socio-economic structure of global development using a multi-step unsupervised learning pipeline. The initial exploratory data analysis revealed severe skewness across fundamental economic and demographic indicators, reflecting real-world global inequality. Applying a Yeo-Johnson power transformation followed by standard scaling proved to be a critical preprocessing step, stabilizing variance and allowing distance-based algorithms to evaluate countries on a balanced multivariate scale without being entirely distorted by extreme outliers.

The clustering analysis demonstrated that the dataset is best understood through a primary dichotomy. While HDBSCAN achieved the highest statistical validation scores by isolating dense pockets and discarding the continuous development gradient as noise, K-Means and Agglomerative clustering provided much more practical and interpretable partitions. K-Means successfully extracted a robust binary macro-structure, separating the world into a high-risk group (characterized by high child mortality, high fertility, and low GDP) and a more developed group. Agglomerative clustering validated this broad division while further segmenting smaller, highly specific sub-profiles, providing a more nuanced hierarchy.

Spatial mapping confirmed that these mathematical partitions correspond strongly to real-world geographical divisions, highlighting a persistent divide between regions like Sub-Saharan Africa and the developed economies of Europe and North America. Finally, the structural learning performed via the PC algorithm provided a network perspective on these variables. The resulting Directed Acyclic Graph (DAG) identified child mortality not just as a lagging indicator, but as a central connecting node dynamically linked to economic prosperity, health expenditure, and demographic trends. Ultimately, this combination of centroid-based clustering, hierarchical profiling, and causal exploration confirms that global development is a highly interconnected, continuous system structured around a few critical macro-economic and health divides.