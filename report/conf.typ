#import "@preview/tablex:0.0.5": tablex
#import "@preview/cetz:0.3.1"

#let conf(
  title: "",
  authors: (),
  date: datetime.today(),
  abstract: none,
  references: none,
  body,
) = {
  set document(title: title)
  set text(size: 11pt)
  set par(justify: true, leading: 0.65em)
  set page(
    paper: "a4",
    margin: (x: 2.5cm, y: 3cm),
    numbering: "1",
    header: context {
      let cur = counter(page).get().first()
      if cur > 1 {
        let headings = query(heading.where(level: 1))
        let relevant = headings.filter(h => h.location().page() <= cur)
        if relevant.len() > 0 {
          let txt = relevant.last().body
          [ #text(fill: luma(100), size: 0.9em)[#title -- #txt] #h(1fr) #cur ]
          v(-0.5em)
          line(length: 100%, stroke: 0.5pt + luma(150))
        }
      }
    },
  )
  show figure.caption: set text(size: 0.9em, style: "italic")

  place(
    top + center,
    float: true,
    scope: "parent",
    clearance: 2em,
    {
      text(title, size: 16pt, weight: "bold")
      grid(
        columns: (1fr,) * authors.len(),
        ..authors.map(author => [
          #author.name \
          Mat. #author.matn \
          #link("mailto:" + author.email)
        ])
      )
      par(justify: false)[
        *Abstract* \
        #abstract
      ]
    },
  )

  body

  if references != none {
    references
  }
}
