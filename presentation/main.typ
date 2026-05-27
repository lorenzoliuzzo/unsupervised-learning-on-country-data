#import "presentation_conf.typ": *

#show: bamboo-theme.with(
	title: "Unsupervised Learning on Country Data", 
	author: "Luca Cicu - Lorenzo Liuzzo", 
	date: datetime.today(),
)

#title-slide()


== Country DataSet
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


