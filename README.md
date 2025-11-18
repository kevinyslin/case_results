# Re:cap Analytics case

Repo containing code and queries for case assessment.
It contains the following files:
- Import_data.ipynb 
- endpoint_export.csv
- invoice_transaction_matches.csv
- SQL_analysis.sql
- Approach.md

## Import_data
Is a python code that extracts data from an endpoint and exports it to a CSV

### Endpoint_export
Is the CSV export from Import_data

## SQL_analysis
Is a SQLquery written using Big query. It uses both CSV's in this repo to answer the following questions
- For what percentage of invoices did the system propose at least one match?
- What is the total amount of invoices that have at least one active rejected match by our customers?
- Which 5 customers have the most reconciled invoices? What percentage of those were reconciled by the system versus the customers?

## Approach
A step by step on how I approached each section of the problem
