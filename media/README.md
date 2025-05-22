# Media

This folder contains definitions of various culture media used for metabolic modeling.

## Available Media

| Medium Name                            | Reference/Source Link                        | Notes            |
| :------------------------------------- | :------------------------------------------- | :--------------- |
| [RPMI-1640](https://github.com/h-escoffier/MediumMetaMod/blob/main/media/RPMI1640.tsv) | [Thermo Fisher RPMI-1640](https://www.thermofisher.com/lu/en/home/technical-resources/media-formulation.187.html) | None |
| [DMEM](https://github.com/h-escoffier/MediumMetaMod/blob/main/media/DMEM.tsv) | [Thermo Fisher DMEM](https://www.thermofisher.com/us/en/home/technical-resources/media-formulation.8.html) | None |
| [DMEM/F-12](https://github.com/h-escoffier/MediumMetaMod/blob/main/media/DMEM_F12.tsv) | [Thermo Fisher DMEM/F-12](https://www.thermofisher.com/lu/en/home/technical-resources/media-formulation.55.html) | None |
| [MEM](https://github.com/h-escoffier/MediumMetaMod/blob/main/media/MEM.tsv) | [Merck MEM](https://www.sigmaaldrich.com/LU/en/technical-documents/technical-article/cell-culture-and-cell-culture-analysis/mammalian-cell-culture/mem-formulation) | None |
| [FBS](https://github.com/h-escoffier/MediumMetaMod/blob/main/media/FBS.tsv) | [Price, P.J., Gregory In Vitro Cell.Dev.Biol.-Plant 18, 1982](https://doi.org/10.1007/BF02810081) | Prostaglandin F removed to causing infinitely large objective values |

> **Note:** Feel free to contribute new media by creating a new file and adding an entry to this table.

-----------------------

## Default Metabolites and Exchange Reactions

Some metabolites are always included in the media definitions, as they represent essential environmental conditions or atmospheric gases (e.g., oxygen). Below is a list of these metabolites and their associated exchange reactions typically included by default.

| Metabolite_Name        | Mets_HumanGEM | ExRxns_HumanGEM | Mets_Recon3D | ExRxns_Recon3D |
| :--------------------- | :------------ | :---------------| :------------| :--------------|
| Oxygen                 | MAM02630e     | MAR09048        | o2[e]        | EX_o2[e]       |
| Water                  | MAM02040e     | MAR09047        | h2o[e]       | EX_h2o[e]      |
| Carbon dioxide         | MAM01596e     | MAR09058        | co2[e]       | EX_co2[e]      |
| Proton                 | MAM02039e     | MAR09079        | h[e]         | EX_h[e]        |

> Modify these defaults in your script or media file as needed for your specific application.
