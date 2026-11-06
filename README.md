\# Simpress – End-to-End Data Engineering Project



\## Project Overview



This project demonstrates an end-to-end data engineering pipeline for logistics and shipment data. It ingests data from AWS S3 into Snowflake, transforms and validates it using dbt, and prepares curated shipment data for business intelligence and analytics.



The project focuses on building a reliable, scalable, and maintainable ELT pipeline.



\## Architecture



\*\*AWS S3 → Snowpipe → Snowflake RAW → dbt STAGING → dbt MART → Analytics\*\*



\### Technologies Used



\- \*\*AWS S3:\*\* Cloud storage for source CSV files.

\- \*\*AWS IAM:\*\* Access management and permissions.

\- \*\*AWS SQS:\*\* Event notifications for Snowpipe auto-ingestion.

\- \*\*AWS SNS:\*\* Notification integration.

\- \*\*Snowflake:\*\* Cloud data warehouse and data processing.

\- \*\*Snowpipe:\*\* Automated ingestion of files from S3.

\- \*\*Snowflake Streams and Tasks:\*\* Change tracking and automated processing.

\- \*\*dbt Core:\*\* SQL-based transformations, incremental processing, and data quality testing.

\- \*\*SQL:\*\* Data cleansing, validation, joins, and business logic.

\- \*\*Power BI:\*\* Business intelligence and reporting.



\## Data Pipeline



\### 1. Data Ingestion – RAW Layer



Source files are stored in AWS S3 and loaded into Snowflake using Snowpipe.



The RAW layer contains:



\- Carrier

\- Destination

\- Product

\- Status

\- Shipment



Ingestion metadata is captured, including source filename, file row number, and ingestion timestamp.



\### 2. Data Transformation – STAGING Layer



dbt is used to:



\- Clean and standardize source data.

\- Handle NULL and invalid values.

\- Perform data type conversions.

\- Remove duplicate records.

\- Implement incremental MERGE processing.

\- Generate surrogate keys.

\- Join shipment data with reference data.

\- Build a shipment-level silver model.



\### 3. Analytics – MART Layer



The MART layer contains a curated shipment fact table.



It supports analysis of:



\- Delivery duration.

\- Delivery performance.

\- Late and pending shipments.

\- Carrier performance.

\- Shipment distance.

\- Product and destination analysis.



\## dbt Project Structure



```text

simpress/

│

├── README.md

├── .gitignore

│

└── simpress\_dbt/

&#x20;   ├── analyses/

&#x20;   ├── macros/

&#x20;   ├── models/

&#x20;   │   ├── Staging/

&#x20;   │   ├── Mart/

&#x20;   │   └── sources.yml

&#x20;   ├── seeds/

&#x20;   ├── snapshots/

&#x20;   ├── tests/

&#x20;   ├── dbt\_project.yml

&#x20;   └── README.md

```



\## Running the dbt Project



\### Prerequisites



\- Python

\- dbt Core

\- dbt Snowflake adapter

\- Snowflake account

\- AWS account



\### Setup



1\. Clone the repository.

2\. Install dbt Core and the Snowflake adapter.

3\. Configure your local dbt profile in `\~/.dbt/profiles.yml`.

4\. Set your Snowflake password through an environment variable.

5\. Install project dependencies.

6\. Run the dbt models and tests.



\### Commands



```bash

dbt deps

dbt debug

dbt run

dbt test

```



\## Data Quality and Validation



The project includes dbt tests to validate data quality and model integrity.



Examples include:



\- Unique key validation.

\- NOT NULL checks.

\- Referential integrity.

\- Business rule validation.

\- Duplicate record handling.



\## Project Goals



\- Build an end-to-end cloud-based ELT pipeline.

\- Implement automated file ingestion.

\- Handle incremental data processing.

\- Maintain data quality and consistency.

\- Prepare shipment data for business analytics.



\---



\*\*Project:\*\* Simpress Data Engineering Pipeline  

\*\*Focus:\*\* AWS | Snowflake | dbt | SQL | ELT | Data Quality

