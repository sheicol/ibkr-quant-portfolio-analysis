# KNIME ETL

Place the exported workflow here as:

`ibkr_etl_workflow.knwf`

The binary workflow is not available in the referenced conversation and must be exported from KNIME by the project owner. Before committing it, verify that it does not embed:

- an Activity Statement or cached row-level data;
- account identifiers;
- PostgreSQL usernames, passwords or connection strings;
- absolute local paths revealing private information.

Documented pipeline concepts: positions and individual trade orders, column normalization, date/time conversion, sign validation, duplicate checks and portfolio-weight calculation.
