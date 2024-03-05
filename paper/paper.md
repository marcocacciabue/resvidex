
---
title: 'ReSVidex: An R package for molecular classification of Respiratory Syncytial (HRSV) Virus sequences'
tags:
  - R
  - Virology
  - HRSV
  - Classification
  - Phyilogeny
date: "28 february 2024"
output:
  html_document:
    df_print: paged
  pdf_document:
    latex_engine: xelatex
authors:
  - name: "Marco Cacciabue"
    orcid: "0000-0002-1429-4252"
    corresponding: yes
    equal-contrib: no
    affiliation: 1, 2
  - name: Nahuel Axel Fenoglio
    orcid: "0009-0000-9741-1890"
    equal-contrib: no
    affiliation: 3
  - name: Melina Obregón
    orcid: "0009-0007-3163-2181"
    affiliation: 3
  - name: Stephanie Goya
    orcid: "0000-0001-7479-3064"
    affiliation: 4
  - name: Mariana Viegas
    orcid: "0000-0002-6506-1635"
    affiliation: 5, 1

bibliography: paper.bib

affiliations:
  - name: Consejo Nacional de Investigaciones Científicas y Técnicas (CONICET), Buenos Aires, Argentina.
    index: 1
  - name: Departamento de Ciencias Básicas, Universidad Nacional de Luján, Luján, Argentina.
    index: 2
  - name: Universidad Nacional de Luján, Luján, Argentina.
    index: 3
  - name: Department of Laboratory Medicine and Pathology, University of Washington Medical Center, Seattle, WA, USA
    index: 4
  - name: Laboratorio de Salud Pública, Facultad de Ciencias Exactas, Universidad Nacional de La Plata, La Plata, Buenos Aires, Argentina
    index: 5
---

# Summary

The human respiratory syncytial virus (HRSV) is one of the leading causes of 
acute lower respiratory tract infection in children, elderly and immunocompromised individuals. Below species level, there are two antigenic groups: HRSV subgroup A (HRSV-A) and B (HRSV-B). Within each subgroup, genotypes are defined based on statistically supported phylogenetic clades that can be inferred with the second hypervariable region (2HR) of the G gene, which encodes the attachment glycoprotein and exhibits the highest genetic and antigenic variability. 

Advanced machine learning techniques have proven to make accurate predictions, using algorithms that reveal patterns in large datasets. In the analysis of viral data, machine learning methods have been recently implemented, for example, in: COVIDEX, a tool that classifies complete genome nucleotide sequences of SARS‐CoV‐2 into lineages [@cacciabue_covidex_2022],  or iNFINITY, another tool used to make human influenza virus classification into subtypes and clades [@cacciabue_infinity_2023].


# Statement of need

`Resvidex` is a tool based on alignment‐free machine learning for HRSV classification into subtypes and clades. Resvidex is a web application that runs on an internet connection without any installation and has a user‐friendly interface. It is fast, sensitive, specific, and ready to implement. Additionally, it is available to run locally for R and Rstudio users as an R package.

The overall classification algorithm that `Resvidex` uses is divided into three phases:

1. The first phase loads the user data in a multifasta format and performs the k‐mer counting operation using the k‐mer package [@kmer]. Each k‐mer count is normalized over the k‐mer size (k = 6) and the sequence length.
2. The second phase calls the ranger package [@wright_ranger_2015] predict function using a pre‐trained random forest model and obtains a probability score based on the rule of majority vote. From this, the app obtains the score for each query sequence classification, the proportion of N bases in the genome, and the genome length.
3. Finally, two tables are created, one showing the sequences that passed all the quality checks and another with sequences that did not pass some of the filter steps. These filters controls: that each sequence obtained a probability score of 0.4 or more, that the sequence length is close to the expected sequence length for the classification model for a factor of no more that 50%, and that the percentage of ambiguous bases in the sequence (N) is not larger than 2%. A brief report can be produced including the results table, date of analysis, and model information.

`Resvidex` was designed to be used by researchers who want to classify their samples of HRSV. It is used at the moment as a part of a HRSV phylogeny investigation [@goya_unified_2024]

# How to use the aplication
![lalalalala](Imagen.jpg)

# Acknowledgements


# References
