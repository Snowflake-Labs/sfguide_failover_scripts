-----------------------------------------------------------------------------
-- PREREQUISITE: download DATA to /tmp/data, download SCRIPTS to /tmp/scripts
-----------------------------------------------------------------------------

-- snowsql -a myorganization-myaccount -u snowgrid -f /tmp/scripts/snowsql/tpcdi_load.sql -o output_format=csv -o output_file=output_file.csv

use role accountadmin;
use schema tpcdi_stg.base;

-- Load into internal named stage with directory enabled
-- CREATE OR REPLACE STAGE TPCDI_FILES DIRECTORY = (ENABLE = TRUE);
put file:///tmp/data/tpcdi-scale5/batch1/* @tpcdi_files/tpcdi-scale5/batch1;
put file:///tmp/data/tpcdi-scale5/batch2/* @tpcdi_files/tpcdi-scale5/batch2;
put file:///tmp/data/tpcdi-scale5/batch3/* @tpcdi_files/tpcdi-scale5/batch3;
put file:///tmp/data/tpcdi-scale5/batch4/* @tpcdi_files/tpcdi-scale5/batch4;
put file:///tmp/data/tpcdi-scale5/batch5/* @tpcdi_files/tpcdi-scale5/batch5;
put file:///tmp/data/tpcdi-scale10/batch1/* @tpcdi_files/tpcdi-scale10/batch1;
put file:///tmp/data/tpcdi-scale10/batch2/* @tpcdi_files/tpcdi-scale10/batch2;
put file:///tmp/data/tpcdi-scale10/batch3/* @tpcdi_files/tpcdi-scale10/batch3;
put file:///tmp/data/tpcdi-scale10/batch4/* @tpcdi_files/tpcdi-scale10/batch4;
put file:///tmp/data/tpcdi-scale10/batch5/* @tpcdi_files/tpcdi-scale10/batch5;