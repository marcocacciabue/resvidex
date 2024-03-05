
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

`Resvidex` is a tool based on alignment‐free machine learning for HRSV classification into subtypes and clades. Resvidex is a web application that has a user‐friendly interface. It is fast, sensitive, specific, and ready to implement. It is available to run locally for R and Rstudio users as an R package. Additionally, it can be tested on an internet connection without any installation (only for small datasets).

The overall classification algorithm that `Resvidex` uses is divided into three majors steps. In the initial phase, the user data is loaded in a multifasta format, and the k-mer counting operation is executed utilizing the k-mer package (citation). Each count of k-mers undergoes normalization based on both the k-mer size (k = 6) and the length of the sequence. Alternatively, the user can copy and paste the query sequence directly to the app.
In the second step, the predict function from the ranger package (Wright et al., 2015) is invoked using a pre-trained random forest model. It calculates a probability score through a majority vote rule. Using this score, the application determines the classification score for each query sequence. Additionally,the app also calculates the proportion of N bases in the genome and the genome length. These values are important as divergencies from the expected values can impact notably over the classification results. On the final step, sequences are separated in two tables, one showing the sequences that passed all the quality checks and another with sequences that did not pass at least one of the filter steps. These filters ensure that each sequence achieves a probability score of 0.4 or higher, that the sequence length aligns closely with the expected length for the classification model (with a tolerance of up to 50%), and that the proportion of ambiguous bases (N) in the sequence does not exceed 2% of the genome length. Sequences that do not meet the necessary criteria should be analyzed manually with other methodologies (i.e. alignment-dependant tools) that may shield a more robust result. Although not recommended, the app allows the user to manually tweak these filters. Additionally, a concise report can be generated, incorporating the results table, date of analysis, and model information. 

`Resvidex` was designed to be used by researchers who want to classify their samples of HRSV. It is used at the moment as a part of a HRSV phylogeny investigation [@goya_unified_2024]

# How to use the aplication
![lalalalala](Imagen.jpg)

# Acknowledgements


# References
