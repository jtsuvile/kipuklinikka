## Synopsis

Code for downloading and writing keholliset tuntemukset data and writing it to .mat and .csv files. See instructions below.

## Process

How to download and process the raw data from Pain clinic project
1. Navigate to bml.becs.aalto.fi/keholliset_tuntemukset/admin/ and make & download .tar file
2. Run get_data_from_tar.sh on command line in the location where you downloaded your .tar file
get_data_from_tar.sh /path/to/output/folder
3. Run s1_screening_kipu.m, make sure you change path names and include code & bodyspm in your matlab path
4. Run s2_preprocessing_kipu.m, make sure you change path names and include code & bodyspm in your matlab path
5. Run load_bg_data.R, make sure you change path names

## Todo

1. Finish R code for combining background info
2. Document 'load_bg_data.R' 
3. Figure out why number of subjects passing screening is not same as number of 'full' subjects from admin view of the app

## Problems?
Contact juulia dot suvilehto at aalto dot fi . 