# Media

This folder contains definitions of various culture media used for metabolic modeling.

## Available Media

| Medium Name                            | Reference/Source Link                        |
| :------------------------------------- | :------------------------------------------- |
| [RPMI-1640](https://github.com/h-escoffier/MediumMetaMod/blob/main/media/RPMI1640.tsv) | [Thermo Fisher RPMI-1640](https://www.thermofisher.com/order/catalog/product/11875093) |

> **Note:** Feel free to contribute new media by creating a new file and adding an entry to this table.

-----------------------

## Default Metabolites and Exchange Reactions

Some metabolites are always included in the media definitions, as they represent essential environmental conditions or atmospheric gases (e.g., oxygen). Below is a list of these metabolites and their associated exchange reactions typically included by default.

| Name | Mets_Recon3D | Mets_HumanGEM | Rxns_Recon3D | Rxns_HumanGEM | Default Bounds |
| :--- | :----------- | :------------ | :----------- | :------------ | :------------- | 
| Oxygen | O2[e] | TODO | TODO | TODO | -1000 to 0 | 
| Water | H2O[e] | TODO | TODO | TODO | -1000 to 1000 |
| Carbon dioxide | CO2[e] | TODO | TODO | TODO | -1000 to 1000 |
| Proton | H[e] | TODO | TODO | TODO | -1000 to 1000 |
| Hydroxide | OH[e] | TODO | TODO | TODO | -1000 to 1000 |

> Modify these defaults in your script or media file as needed for your specific application.
