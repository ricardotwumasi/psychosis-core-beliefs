# 🧠 Core Beliefs in Psychosis Meta-Analysis Code

[![DOI](https://zenodo.org/badge/DOI/[pending].svg)](https://doi.org/[pending])
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-4.1.0-blue.svg)](https://cran.r-project.org/)

Full R code for reproducing our meta-analysis of the relationship between core beliefs and psychotic experiences. This repository contains the code used in our systematic review and meta-analysis (Jorovat et al., in press) examining how core beliefs and schemas relate to psychosis, clinical high risk states, and psychotic-like experiences.

## 🎯 Overview

This code implements a meta-analytic approach to synthesise evidence on core beliefs in psychosis, following the steps of:

- Calculating effect sizes
- Fitting RMLE with knha models for each BCSS and YSQ schema
- Identifying and measuring heterogeneity
- Creating forest plots with point estimates, 95% confidence intervals and prediction intervals

## 💻 Requirements

- R (≥ 4.1.0)
- Required R packages:
  ```R
  tidyverse
  metafor
  ```

## 🚀 Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/ricardotwumasi/core-beliefs-meta.git
   ```

2. Install required R packages:
   ```R
   required_packages <- c("tidyverse", "metafor")
   install.packages(required_packages)
   ```
   
## 🤖 AI Statement

This code was edited with the assistance of Claude Sonnet 3.5 (Anthropic, San Francisco: CA)

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📚 Citations

Key methodological references:

```bibtex
@article{chinn2000,
  title={A simple method for converting an odds ratio to effect size for use in meta-analysis},
  author={Chinn, Susan},
  journal={Statistics in medicine},
  volume={19},
  number={22},
  pages={3127--3131},
  year={2000},
  publisher={Wiley Online Library}
}

@book{borenstein2021,
	title = {Introduction to {Meta}-{Analysis}},
	isbn = {978-1-119-55835-4},
	url = {https://books.google.co.uk/books?id=2oYmEAAAQBAJ},
	publisher = {Wiley},
	author = {Borenstein, M. and Hedges, L.V. and Higgins, J.P.T. and Rothstein, H.R.},
	year = {2021},
}


@article{viechtbauer2010,
  title={Conducting meta-analyses in R with the metafor package},
  author={Viechtbauer, Wolfgang},
  journal={Journal of Statistical Software},
  volume={36},
  number={3},
  pages={1--48},
  year={2010}
}
```

[Citation](#citation) 
For citing this repository, please use:

<details>
<summary>BibTeX</summary>
<pre><code>@article{jorovat2024,
  title={Core Beliefs in Psychosis: A Systematic Review and Meta-Analysis},
  author={Jorovat, Alina Twumasi, Ricardo and Georgiades, Anna},
  journal={Schizophrenia},
  year={In Press},
  publisher={Springer Nature},
  doi={[DOI Pending]}
}
</code></pre>
</details>
<details>
<summary>APA</summary>
<pre><code>Jorovat, A., Twumasi, R., & Georgiades, A (In Press). Core Beliefs in Psychosis: A Systematic Review and Meta-Analysis. Schizophrenia.</code></pre>
</details>
<details>
<summary>Vancouver</summary>
<pre><code>Jorovat A , Twumasi R, Georgiades A. Core Beliefs in Psychosis: A Systematic Review and Meta-Analysis. Schizophrenia. In Press.</code></pre>
</details>

---
Contributors: Alina Jorovat, Ricardo Twumasi & Anna Georgiades
