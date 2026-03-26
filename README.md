# MetablicMediaLibrary

Welcome to the **Metabolic Media Library**, a community-driven repository dedicated to standardizing culture media definitions for genome-scale metabolic modeling.
This project provides a curated collection of media formulations mapped to widely used human metabolic models (Recon3D and Human-GEM).

-----------------------

## Media File Format

Each medium is defined as a `.tsv` file with the following columns:


| Metabolite_Name        | Mets_HumanGEM | ExRxns_HumanGEM | Mets_Recon3D | ExRxns_Recon3D | Concentration_M |
| :--------------------- | :------------ | :---------------| :------------| :--------------| :---------------|
| glucose                | MAM01965e     | MAR09034        | glc_D[e]     |	EX_glc_D[e]    | 0.010011        |



> [!NOTE]  
> * All concentrations are in molar units (M).
> * Missing entries can be left blank but the format must be respected.
> * Whenever possible, include identifiers for both models to maximize interoperability.

-----------------------

## Contributing 

We welcome contributions of new media formulations or improvements to existing ones.

### To add a new medium:

1. Copy the template file.
2. Rename it appropriately (e.g., `RPMI1640.tsv`).
3. Fill in all relevant fields:
    * Include both Recon3D and Human-GEM identifiers whenever possible.
4. Submit a pull request including:
    * The completed `.tsv` file in the `media/` directory.
    * (Optional) A reference or note describing the source of concentrations

-----------------------

## Resources

### Genome-Scale Metabolic Models

| Model      | Description                                 | Source |
| :--------- | :------------------------------------------ | :---------------- |
| **Human-GEM**   | An open, community-maintained human metabolic model. | [Human-GEM on GitHub](https://github.com/SysBioChalmers/Human-GEM) |
| **Recon3D**     | A comprehensive human metabolic model with metabolite structures and gene-protein-reaction (GPR) associations. | [VMH - Recon3D](https://www.vmh.life/#downloadview) |

### Modeling Toolboxes

| Toolbox        | Language | Description                                    | Installation / Docs |
| :------------- | :------- | :--------------------------------------------- | :------------------ |
| **COBREXA.jl**    | Julia    | Scalable metabolic modeling in Julia           | [COBREXA.jl Docs](https://cobrexa.github.io/COBREXA.jl/stable/) |
| **COBRApy**       | Python   | Python implementation of the COBRA Toolbox     | [COBRApy Docs](https://cobrapy.readthedocs.io) | 
| **COBRA Toolbox** | MATLAB   | Original MATLAB-based framework for constraint-based modeling | [COBRA Toolbox GitHub](https://github.com/opencobra/cobratoolbox) |
| **RAVEN Toolbox** | MATLAB   | Reconstruction, Analysis and Visualization of Metabolic Networks | [RAVEN Toolbox GitHub](https://github.com/SysBioChalmers/RAVEN) |

-----------------------

## Why This Matters

The composition of culture media strongly influences predictions in constraint-based metabolic models. Standardizing these definitions enables:

* **Reproducibility** of published simulation results
* **Transparency** in modeling assumptions
* **Comparability** across studies, models, and experimental conditions

-----------------------

## Integration Examples

We provide [code example](https://github.com/h-escoffier/MetabolicMediaLibrary/tree/main/integration_scripts/create_medium_specific_model.jl) for integrating medium files into models using COBREXA.jl

> [!IMPORTANT]  
> The media formulations provided can often be too restrictive and lack certain metabolites crucial for the cells growth beyond a given rate.
> To compensate for these missing metabolites, it is recommended to use a gapfilling solution (see [documentation](https://cobrexa.github.io/COBREXA.jl/stable/examples/05h-medium/)). 

-----------------------

## Feedback & Improvements

Feedback is highly appreciated.
If you encounter issues, have suggestions, or would like to propose new features, please open an issue or submit a pull request.

-----------------------

## Acknowledgments

This project builds upon the work of the metabolic modeling community. 
A significant portion of the initial work, particularly on media composition analysis, was carried out by [Claude Haan](https://www.uni.lu/fstm-en/people/claude-haan/). 

-----------------------

## License

This project is licensed under the MIT License. 
