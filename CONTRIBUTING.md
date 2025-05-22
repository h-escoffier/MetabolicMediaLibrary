# Contributing to the Metabolic Media Library

Thank you for your interest in contributing! This repository aims to provide a growing library of standardized culture media for genome-scale metabolic modeling. Contributions of **new media**, **improvements to existing files**, and **integration scripts** are all welcome.

-----------------------

## 1. Add a New Medium

To add a new medium : 

### Step-by-step

1. **Duplicate the template**:
   - Copy [`templates/medium_template.tsv`](../templates/medium_template.csv).
   - Rename it clearly, e.g., `RMPI1640.tsv`.

2. **Fill out the columns**:
   - Use the following format:
   
   | Metabolite_Name        | Mets_HumanGEM | ExRxns_HumanGEM | Mets_Recon3D | ExRxns_Recon3D | Concentration_M |
   | :--------------------- | :------------ | :---------------| :------------| :--------------| :---------------|
   | glucose                | MAM01965e     | MAR09034        | glc_D[e]     | EX_glc_D[e]    | 0.010011        |

   - You may leave some columns blank if data isn't available, but the structure must be preserved.

3. **Source your data**:
   - If possible, include references or links to the source (e.g., vendor datasheets, publications, experimental conditions).

4. **Test integration (optional)**:
   - You may test the medium using the scripts in the `integration_scripts/` folder (Python, MATLAB, Julia).
   - This ensures formatting is correct and compatible with models.

-----------------------

## 2. Improve or Expand Scripts

You can also contribute:
- New scripts for other modeling frameworks (e.g., RAVEN, MEWpy).
- Improvements to existing integration scripts (e.g., error handling, formatting).
- Validation tools for checking the structure of TSV media files.

-----------------------

## Formatting Tips


- Use `.` as the decimal separator, not a comma.
- Concentration units should be in **M (millimolar)**.
- If you’re unsure of a value, leave it blank or note it in a comment in your PR.

-----------------------

## Acknowledgment

All contributors will be listed in the [Acknowledgments](../README.md#) section of the README. Contributions are valuable regardless of size — even small fixes help!

-----------------------

## Need Help?

Open an issue with your question or join the discussion in the [Discussions tab](https://github.com/h-escoffier/MediumMetaMod/discussions).

