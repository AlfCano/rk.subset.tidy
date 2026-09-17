# rk.subset.tidy

![Version](https://img.shields.io/badge/Version-0.0.1-blue.svg)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.subset.tidy/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.subset.tidy/actions/workflows/lintr.yml)
![AI Gemini](https://img.shields.io/badge/AI-Gemini-4285F4?logo=googlegemini&logoColor=white)

**An RKWard GUI Plugin for Subsetting Cases and Variables using `dplyr`**

`rk.subset.tidy` provides a fast, intuitive, point-and-click graphical interface for core data manipulation tasks in R. Acting as a lightweight wrapper for the popular [`dplyr`](https://dplyr.tidyverse.org/) package, this plugin allows users to seamlessly filter, slice, select, and sort datasets without writing code.

*Note: This plugin is laser-focused on subsetting (rows and columns). For joining tables, see [`rk.dplyr`](https://github.com/AlfCano/rk.dplyr). For mutating and aggregating data, see [`rk.data.wrangling`](https://github.com/AlfCano/rk.data.wrangling).*

---

## 🌟 Key Features

* **Zero-Code Tidyverse:** Harness the power of `filter()`, `slice()`, `select()`, and `arrange()` via a highly optimized GUI.
* **"Focus Magic" UI:** The variable selector panel dynamically collapses to show *only* the columns belonging to the dataframe you are currently working on, making variable selection effortless.
* **Tidy Evaluation Safety:** Automatically protects variable names containing spaces or special characters by wrapping them in backticks (``` `my var` ```) during R code generation.
* **Crash-Proof Previews:** Live data previews are intelligently capped at 100 rows (`%>% head(100)`) behind the scenes. This prevents RKWard from freezing when previewing manipulations on massive datasets (e.g., census microdata).
* **Multilingual:** Fully translated into English, Spanish, French, German, and Portuguese (Brazil).

---

## ⚙️ Prerequisites

You must have [RKWard](https://rkward.kde.org/) installed along with the following R package:

```R
install.packages("dplyr")
```

---

## 🚀 Installation

You can install this plugin directly from GitHub using `devtools` inside your RKWard console:

```R
# Install the plugin
devtools::install_github("AlfCano/rk.subset.tidy")
```

Once installed, restart RKWard, navigate to **Settings -> Configure RKWard -> Plugins**, and activate `rk.subset.tidy`.

---

## 🛠️ Usage Workflow

This plugin adds two new powerful tools to your RKWard menus, located under **Data ➔ Data Transformation (dplyr)**:

### 1. Subset Cases (Filter & Slice)
*Extract rows based on logical conditions or their physical position in the dataframe.*
* **Filter by Logic:**
  * **Basic Filter:** Use dropdown menus to create logical rules (e.g., `Variable == Value`, `< =`, or `is.na()`). The UI smartly adapts to your choices.
  * **Advanced Filter:** Write complex, multi-condition custom statements (e.g., `skin_color == 'light' & height > 150`).
* **Slice by Position:** Select exactly which rows to keep. Choose between a specific Range, Top Rows (`slice_head`), Bottom Rows (`slice_tail`), or taking a Random Sample (`slice_sample`).

### 2. Select Variables & Arrange
*Choose which columns to keep/drop and sort your data.*
* **Select Columns:** 
  * Pick variables to **Keep** or **Drop** directly from the UI slots. 
  * Use the **Advanced Select** text box to harness the full power of tidyselect helpers (e.g., `starts_with("hair")` or `hair_color:eye_color`).
* **Arrange Rows:** Select one or multiple variables to sort your dataframe. Easily toggle descending order (`desc()`) with a single click.

---

## 🌍 Internationalization (i18n)

The graphical interface automatically adapts to your RKWard language settings. Currently supported languages:
* 🇺🇸 English (Default)
* 🇪🇸 Spanish (Español)
* 🇫🇷 French (Français)
* 🇩🇪 German (Deutsch)
* 🇧🇷 Portuguese (Português do Brasil)

---

## 📝 License and Author

**Author:** Alfonso Cano ([@AlfCano](https://github.com/AlfCano))  
**Email:** alfonso.cano@correo.buap.mx  
*   **Assisted by:** Gemini, a large language model from Google.
*   **License:** GPL (>= 3)

This project is licensed under the **GPL (>= 3)** License.
