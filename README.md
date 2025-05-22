# MediumMetaMod

Welcome to the **Medium Metablic Modeling Library**, a community-driven resource for standardized definitions of culture media used in genome-scale metabolic modeling. This repository provides a growing collection of media formulations mapped to popular human metabolic models (**Recon3D** and **Human-GEM**). It also includes integration scripts for **COBREXA (Julia)**, **COBRApy (Python)**, and **COBRA (MATLAB)** to easily load these media into metabolic models.

-----------------------

## Media File Format

Each medium is defined as a .tsv file with the following columns:


| Metabolite_Name        | Mets_HumanGEM | ExRxns_HumanGEM | Mets_Recon3D | ExRxns_Recon3D | Concentration_M |
| :--------------------- | :------------ | :---------------| :------------| :--------------| :---------------|
| glucose                | MAM01965e     | MAR09034        | glc_D[e]     |	EX_glc_D[e]    | 0.010011        |


* All concentrations are in molar (M).
* Missing entries can be left blank but the format must be respected.

-----------------------

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

-----------------------

## Contributing 

We welcome contributions of new media formulations or improvements to existing ones.

### To add a new medium:

1. Copy the template file.
2. Rename it appropriately (e.g., `RPMI1640.tsv`).
3. Fill in the required columns. Try to include both Recon3D and Human-GEM identifiers.
4. Submit a pull request with:
    * A completed TSV file in the media/ directory.
    * Optionally, a brief note or citation about the source of concentrations.
    * Update the CONTRIBUTING.md file if needed.

See CONTRIBUTING.md for more details.

-----------------------

## Resources

### Genome-Scale Metabolic Models

| Model      | Description                                 | Source / Download |
| :--------- | :------------------------------------------ | :---------------- |
| **Human-GEM**   | An open, community-maintained human metabolic model. | [Human-GEM on GitHub](https://github.com/SysBioChalmers/Human-GEM) |
| **Recon3D**     | A comprehensive human metabolic model with metabolite structures and gene-protein-reaction (GPR) associations. | [VMH - Recon3D](https://www.vmh.life/#downloadview) |

### Modeling Toolboxes

| Toolbox        | Language | Description                                    | Installation / Docs |
| :------------- | :------- | :--------------------------------------------- | :------------------ |
| **COBRA Toolbox** | MATLAB   | Original MATLAB-based framework for constraint-based modeling. | [COBRA Toolbox GitHub](https://github.com/opencobra/cobratoolbox) |
| **COBRApy**       | Python   | Python implementation of the COBRA Toolbox.     | [COBRApy Docs](https://cobrapy.readthedocs.io) |
| **COBREXA.jl**    | Julia    | Scalable metabolic modeling in Julia.           | [COBREXA.jl Docs](https://lcsb-biocore.github.io/COBREXA.jl/dev/) |

-----------------------

## Why This Matters

Culture medium composition has a strong impact on predicted phenotypes in constraint-based modeling. Standardizing and sharing these definitions will help:

* Reproduce published models more accurately.
* Encourage transparency in simulation assumptions.
* Facilitate comparison of metabolic behaviors across models and environments.

-----------------------

## Feedback & Improvements

Suggestions and feedback are very welcome! If you encounter any issues, have ideas for new features, or notice room for improvement, feel free to open an issue or submit a pull request.

-----------------------

## Acknowledgments

This project builds upon the work of the metabolic modeling community.

-----------------------

## License

This project is licensed under the MIT License unless otherwise stated. Please cite original model references when using this data in publications.
