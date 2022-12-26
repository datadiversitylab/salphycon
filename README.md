# The `salphycon` `shiny` app <a href='https://cromanpa94.github.io/salphycon'><img src='www/img/salphycon.png' align="right" height="300" /></a>

### Phylogenetics with `phruta`

## What is `salphycon`?

 {Salphycon} is a shiny app that extends the functionalities of the {phruta} R package. {Salphycon} is able to (1) find potentially (phylogenetically) relevant gene regions for a given set of taxa based on GenBank, (2) retrieve gene sequences and curate taxonomic information from the same database, (3) combine downloaded and local gene sequences, and (4) perform sequence alignment, phylogenetic inference, and basic tree dating tasks. Both {phruta} and {salphycon} are focused on species-level analyses. 

 ## Where can I find `salphycon`?

 I live version of `salphycon` is currently hosted [here](https://viz.datascience.arizona.edu/salphycon/). Please note that the server is farly slow and that the author is still working on adjusting the release to the constrains imposed by the server.

## What is `phruta`?

The `phruta` R package is designed to simplify the basic phylogenetic pipeline. All the code is run within the same program and data from intermediate steps are saved in independent folders (optional). `phruta` retrieves gene sequences, combines newly downloaded to local gene sequences, performs sequence alignments, and basic phylogenetic inference. 

## Who should consider using `phruta` and `salphycon`

The main functions in the `phruta` R package and  `salphycon` allow for a quick mining and curation of GenBank sequences. This package is designed for students and researchers interested in generating species-level genetic datasets for particular sets of taxa. Specifically, if you have a clade or group of species in mind, `phruta` will help you to assemble a molecular dataset with information available in GenBank. Note that `phruta` is more flexible than the functions implemented in `salphycon`.

## Why use `phruta` and `salphycon`?

`phruta` and `salphycon` simplify the phylogenetic pipeline, increases reproducibility, and helps organizing information used to infer molecular phylogenies.

## Etymology

Salpicon is sort of a fruit salad in Colombian Spanish. `Salphycon` intends to expand the functionality of `phruta`, from the  _Fruta_ is the Spanish word for _Fruit_ and _ph_ for phylogenetics, for multiple simulatenous searches across different taxonomic groups.

## Contributing

Please see our [contributing guide](CONTRIBUTING).
