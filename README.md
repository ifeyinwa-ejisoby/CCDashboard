# Cervical Cancer and Treatment in the United States

Each year, approximately 13,000-14,000 new cervical cancer cases are diagnosed in 
the United States, with about 4,000 women succumbing to the disease 
[[CDC](https://www.cdc.gov/cervical-cancer/statistics/index.html)]. This dashboard
contains exploratory and statistical analyses of the regional make-up of cases, 
mortality rates by region, the relative mortality risk by the International 
Federation of Gynecology and Obstetrics (FIGO) stages when adjusting for 
baseline demographic and clinico-pathologic characteristics, and the common
treatment types for these stages post-hysterectomy.

## Data Source and Description

Data used in this dashboard is from the National Cancer Database (NCDB)
Cervical Cancer Participant User File (PUF) 2022. This de-identified patient-level data, with ~190,000 patients, 
is collected from Commission on Cancer (CoC)-accredited registries and hospitals from 2004
to 2022. As a Health Insurance Portability and Accountability Act (HIPAA)-compliant data file, the data 
used is confidential. Access to NCDB PUFs is only permitted through an application process 
to investigators associated with CoC-accredited cancer programs. 

To learn more, visit the American College of Surgeons PUF documentation,
[here](https://www.facs.org/quality-programs/cancer-programs/national-cancer-database/puf/).

## Repository Format
- `code/`: file directory for code
  - `clean_data.R`: R script for cleaning raw cervix uteri PUF 2022 file
  - `analysis.R`: R script for manipulating data and performing widget specific
  analysis
- `output/`: where the processed data is stored as .rds files (not visible to Git)
- `index.Rmd`: R Markdown file for formatting and knitting dashboard
- `index.html`: html file of dashboard
- `styles.css`: CSS file for additional styling of dashboard tabs

## Findings and Real-World Impact

Although cervical cancer mortality rate in the U.S. has steadily declined, 
it is still important to highlight regions in need of improved care. Additionally, 
understanding relative mortality risks among FIGO stages and their current 
treatment types is pertinent in shifting the direction of innovative research.