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

| Name | Mets_Recon3D | Mets_HumanGEM | Rxns_Recon3D | Rxns_HumanGEM | Default Bounds |
| :--- | :----------- | :------------ | :----------- | :------------ | :------------- | 
| Oxygen | o2[e] | MAM02630e | EX_o2[e] | MAR09048 | -1000 to 0 | 
| Water | h2o[e] | MAM02040e | EX_h2o[e] | MAR09047 | -1000 to 1000 |
| Carbon dioxide | co2[e] | MAM01596e | EX_co2[e] | MAR09058 | -1000 to 1000 |
| Proton | h[e] | MAM02039e | EX_h[e] | MAR09079 | -1000 to 1000 |

> Modify these defaults in your script or media file as needed for your specific application.
