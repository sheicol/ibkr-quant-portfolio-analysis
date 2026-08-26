# KNIME ETL

The KNIME workflow is intentionally kept private and is not distributed with
this repository. This prevents database credentials, local paths, account
identifiers, and cached broker data from being published accidentally.

Any future workflow artifact must be reviewed before publication to ensure it
does not embed:

- an Activity Statement or cached row-level data;
- account identifiers;
- PostgreSQL usernames, passwords or connection strings;
- absolute local paths revealing private information.

Documented pipeline concepts: positions and individual trade orders, column normalization, date/time conversion, sign validation, duplicate checks and portfolio-weight calculation.

