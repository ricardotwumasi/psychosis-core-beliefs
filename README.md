# 🧠 Core Beliefs in Psychosis: Meta-Analysis Pipeline

[![DOI](https://zenodo.org/badge/DOI/[pending].svg)](https://doi.org/[pending])
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-4.1.0-blue.svg)](https://cran.r-project.org/)

Full R code for reproducing our meta-analysis of the relationship between core beliefs and psychotic experiences. This repository contains the code used in our systematic review and meta-analysis (Jorovat et al., in press) examining how core beliefs and schemas relate to psychosis, clinical high risk states, and psychotic-like experiences.

## 📋 Table of Contents
- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Pipeline Structure](#pipeline-structure)
- [Usage](#usage)
- [Effect Size Calculations](#effect-size-calculations)
- [Citation](#citation)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This pipeline implements a meta-analytic approach to synthesise evidence on core beliefs in psychosis, following the steps of:

- Converting diverse effect sizes to a common metric (Fisher's z)
- Handling complex dependency structures in the data
- Conducting subgroup analyses by clinical population
- Examining moderating effects of belief and symptom types

## 💻 Requirements

- R (≥ 4.1.0)
- Required R packages:
  ```R
  tidyverse
  metafor
  meta
  gridExtra
  ggplot2
  dplyr
  ```

## 🚀 Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/[username]/core-beliefs-meta.git
   ```

2. Install required R packages:
   ```R
   required_packages <- c("tidyverse", "metafor", "meta", "gridExtra", "ggplot2", "dplyr")
   install.packages(required_packages)
   ```

## 🏗️ Pipeline Structure

The analysis pipeline consists of two main scripts:

1. `cleaning_escalc.R`: Data preprocessing and effect size calculation
   - Standardizes variable names
   - Converts effect sizes to Fisher's z
   - Calculates sampling variances
   - Creates separate datasets for different analyses

2. `meta_analysis.R`: Meta-analytic procedures
   - Implements random-effects models
   - Conducts subgroup analyses
   - Performs meta-regression
   - Assesses publication bias

## 📊 Effect Size Calculations

Our pipeline implements standardised effect size calculations following established guidelines:

1. Direct correlations (r) are transformed to Fisher's z using:
   ```R
   fishers_z = atanh(r)
   ```

2. Odds ratios are converted following Chinn's (2000) method:
   ```R
   logOR = log(OR)
   r = logOR / (sqrt(3) * pi)
   ```

3. Cohen's d is converted using:
   ```R
   r = d / sqrt(d^2 + 4)
   ```

4. Standard errors for Fisher's z are calculated as:
   ```R
   se = 1/sqrt(n - 3)
   ```

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📚 Citations

Key methodological references:

```bibtex
@article{chinn2000simple,
  title={A simple method for converting an odds ratio to effect size for use in meta-analysis},
  author={Chinn, Susan},
  journal={Statistics in medicine},
  volume={19},
  number={22},
  pages={3127--3131},
  year={2000},
  publisher={Wiley Online Library}
}

@incollection{borenstein2009effect,
  title={Effect sizes for continuous data},
  author={Borenstein, Michael},
  booktitle={The handbook of research synthesis and meta-analysis},
  pages={221--235},
  year={2009},
  publisher={Russell Sage Foundation}
}

@article{viechtbauer2010conducting,
  title={Conducting meta-analyses in R with the metafor package},
  author={Viechtbauer, Wolfgang},
  journal={Journal of Statistical Software},
  volume={36},
  number={3},
  pages={1--48},
  year={2010}
}
```

For citing this repository, see [Citation](#citation) please use:

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
