# MediumMetaMod

Welcome to the **Metabolic Media Library**, a community-driven resource for standardized definitions of culture media used in genome-scale metabolic modeling. This repository provides a growing collection of media formulations mapped to popular human metabolic models (**Recon3D** and **Human-GEM**). It also includes integration scripts for **COBRA (MATLAB)**, **COBRApy (Python)**, and **COBREXA (Julia)** to easily load these media into metabolic models.

## Media File Format

Each medium is defined as a .tsv file with the following columns:


| Mets_Recon3D | Mets_HumanGEM | ExRxns_Recon3D | ExRxns_HumanGEM | Concentration_M |
| :--------------- | :--------------- | :--------------- | :--------------- | :--------------- | :--------------- | :--------------- | :--------------- |
| glc_D[e] | MAM01965e | EX_glc_D[e] | MAR08386 | 0.0111012 |


* All concentrations are in molar (M).
* Missing entries can be left blank but the format must be respected.

## Integration Examples

We provide code examples for integrating medium files into models in various environments:

### Julia (using COBREXA)

```
TODO
```

### Python (using COBRApy)

```
TODO
```

### MATLAB (using COBRA Toolbox)

```
TODO
```

## Contributing 

We welcome contributions of new media formulations or improvements to existing ones.

### To add a new medium:

1. Copy the template file.
2. Rename it appropriately (e.g., HamF12.csv).
3. Fill in the required columns. Try to include both Recon3D and Human-GEM identifiers.
4. Submit a pull request with:
* A completed CSV file in the media/ directory.
* Optionally, a brief note or citation about the source of concentrations.
* Update the CONTRIBUTING.md file if needed.

See CONTRIBUTING.md for more details.

## License

This project is licensed under the MIT License unless otherwise stated. Please cite original model references when using this data in publications.

## Why This Matters

Culture medium composition has a strong impact on predicted phenotypes in constraint-based modeling. Standardizing and sharing these definitions will help:

* Reproduce published models more accurately.
* Encourage transparency in simulation assumptions.
* Facilitate comparison of metabolic behaviors across models and environments.

## Feedback & Improvements

Suggestions and feedback are very welcome! If you encounter any issues, have ideas for new features, or notice room for improvement, feel free to open an issue or submit a pull request.