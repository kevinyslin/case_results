# Approach for Analytics Engineer Challenge

## Data Ingestion

1) Check and explore provided link 
    1.1) See if we receive a valid status code
    1.2) Explore JSON, looking at the keys and what type of data exists in each key
    1.3) Visualize important sections
2) Through exploration there are some main **keys** for our code:
- data: contains the data we want to extract
- total_pages: is the total number of pages that we can loop through
- total_items: total amount of entries
- page_size: number of entries per page
3) Using a loop we can import and append the data of each page onto a dataframe.
4) We also sum the page_size's to validate that we have pulled the correct amount of entries.
5) Check if data has proper data types and don't contain nulls. 
6) Change datetime columns to their proper data type. 
7) Export to csv.

## SQL Section

1) These are the main definitions we use for the analysis:
- If there is a user “approved” match, it cannot be overwritten by a system match.
- An invoice-transaction match is considered “active” if it is the most recent record for the given invoice-transaction pair.
- An invoice is considered “reconciled” if it has at least one active approved match.

2) The main table created is adding a row number column, which is partitioned by invoice ID and transaction ID, and then ordered by create date.
3) I use this base table for analysis in questions 1 to 3