# Too Much of a Good Thing? How Narrow Targeting and Policy Interactions Influence Responses to California’s EITC

### Authors: David Neumark, Zeyu Li  
This repository contains the code and data used in our paper _"Too Much of a Good Thing? How Narrow Targeting and Policy Interactions Influence Responses to California’s EITC."_ The study evaluates the employment effects of California's Earned Income Tax Credit (EITC) supplement compared to other state and federal EITC programs, with a focus on low-income, less-educated single mothers. The findings suggest that, despite the generosity of California’s EITC, there is no positive employment effect, which contrasts with other EITC programs. This repository includes Stata code used to reproduce the results and figures presented in the paper.

## Repository Structure

- **Master Do-File**: `master.do`  
  This is the main script that calls the sub-do files and reproduces all the results and figures presented in the paper. It coordinates data import, processing, analysis, and graph generation.
  
- **Sub Do-Files**:
  - `analysis_figure_1.do`: Generates Figure 1, which compares the income-credit relationships for the federal EITC, California’s EITC, and the combined effect. It uses data from `eitc_credit_federal_ca.xlsx`.
  - `analysis_figure_2.do`: Produces Figure 2, an event study that visualizes the employment effects over time in California compared to states without EITC supplements, using data from `analysis_6.dta`.
  
- **Data**:
  - `eitc_credit_federal_ca.xlsx`: Contains raw data on federal and California EITC credits, used for generating the income-credit relationship plots.
  - `state_eitc_pctg_dt.dta`: Dataset that provides state-level EITC percentages used in the event studies.
  - `analysis_6.dta`: Processed dataset used in the event studies for Figure 2, which includes employment, hours worked, and other demographic variables.

## Output Files

- **Figures**:
  - `figures/credit_fed.jpg`: Federal EITC income-credit graph.
  - `figures/credit_ca.jpg`: California EITC income-credit graph.
  - `figures/credit_sum.jpg`: Combined federal and California EITC graph.
  - `figures/emp_yr.jpg`: Event study graph for employment effects over time.

## How to Run the Code
1. Clone this repository:
   ```bash
   git clone https://github.com/peterlizeyu/california_eitc.git
   '''

2. Open Stata and run the master do-file:
   ```bash
   do master.do
   '''
This will generate all results and figures in the outfiles directory.

If you use this repository or data, please cite the paper:

**Neumark, D. & Li, Z. (2024). _Too Much of a Good Thing? How Narrow Targeting and Policy Interactions Influence Responses to California’s EITC._ NBER Working Paper No. 32883.**

