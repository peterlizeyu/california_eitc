# Too Much of a Good Thing? How Narrow Targeting and Policy Interactions Influence Responses to California’s EITC

### Authors: David Neumark, Zeyu Li  
This repository contains the code and data used in our paper _"Too Much of a Good Thing? How Narrow Targeting and Policy Interactions Influence Responses to California’s EITC."_ The study evaluates the employment effects of California's Earned Income Tax Credit (EITC) supplement compared to other state and federal EITC programs, with a focus on low-income, less-educated single mothers. The findings suggest that, despite the generosity of California’s EITC, there is no positive employment effect, which contrasts with other EITC programs. This repository includes Stata code used to reproduce the results and figures presented in the paper.

## Repository Structure

- **Master Do-File**: `master.do`  
  This is the main script that calls the sub-do files and reproduces all the results and figures presented in the paper. It coordinates data import, processing, analysis, and graph generation.
  
## Data

- **CPS** All CPS data are from IPUMS (https://cps.ipums.org/cps/) and are not included in this repository.
- 
- **`stateeitcdn.xls`**, **`eitc_credit_federal_ca.xlsx`**, and **`state_eitc_pctg.xlsx`**  
  Contains historical data on federal and state EITC implementation, including the date each state introduced its EITC and the basic parameters of each program. These data is crucial for understanding policy variation across states.

- **`ur_cps.xls`**  
  Contains state-level unemployment rate data that is merged with CPS data to control for business-cycle effects by state and year.


## How to Run the Code
1. Clone this repository:
   ```bash
   git clone https://github.com/peterlizeyu/california_eitc.git

2. Update directory paths:

Before running the code, open the master.do file in Stata or a text editor and update the global directory variables dir and data_dir to reflect the paths where you have saved the repository on your local machine. This ensures the code runs correctly on your setup.

2. Open Stata and run the master do-file:
   ```bash
   do master.do
   
This will generate all results and figures in the outfiles directory.

If you use this repository or data, please cite the paper:

**Neumark, D. & Li, Z. (2024). _Too Much of a Good Thing? How Narrow Targeting and Policy Interactions Influence Responses to California’s EITC._ NBER Working Paper No. 32883.**

