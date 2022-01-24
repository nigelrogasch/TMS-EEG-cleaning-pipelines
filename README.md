# TMS-EEG-cleaning-pipelines

This repository contains code to reproduce cleaning pipelines and figures from our paper:

Rogasch NC, Biabani M, & Mutanen TP. (2021) [Designing and comparing cleaning pipelines for TMS-EEG data: a theoretical overview and practical example](https://www.biorxiv.org/content/10.1101/2021.11.18.469167v1). *bioRxiv*

## Data

TMS-EEG data used in the paper are available from this [data repository](https://doi.org/10.26180/18805994.v4).

The data provided are the output from `pipeline_step1.m` and are epoched around the TMS pulse (-1000 to 1000 ms) and baseline corrected (-500 to -10 ms). Unused channels have been removed.

## Code implementation

To run the main pipelines compared in the paper, sequentially run through the pipeline scripts as below. Note that file paths to data and other toolboxes will need to be personalised:

- `pipeline_step1.m` (note that the output data from this script is provided above)

- `pipeline_step2.m`

- `pipeline_step3_FastICA_1.m` *and* 
`pipeline_step3_FastICA_2.m`
**or**
`pipeline_step3_SOUND.m`
**or**
`pipeline_step3_FrecheModel.m`

- `pipeline_step4.m`

To generate TEPs and global mean field amplitudes used in the figure scripts, run:
`save_out_tep_gmfa.m`

Variants on the above pipelines used for different comparisons in the paper are indicated in the script names.

## Dependencies

The scripts require the following toolboxes:

- [EEGLAB](https://sccn.ucsd.edu/eeglab/index.php)

- [TESA](https://nigelrogasch.github.io/TESA/) (needs to be added to the plugins folder in EEGLAB)

- [FieldTrip](https://www.fieldtriptoolbox.org/)
