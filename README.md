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

We provide code examples for integrating medium files into models using COBREXA:

### [COBREXA.jl](https://cobrexa.github.io/COBREXA.jl/stable/)

```{julia}
using COBREXA
using CSV, DataFrames
using SparseArrays
import JSONFBCModels, SBMLFBCModels, HiGHS
import AbstractFBCModels as A
import AbstractFBCModels.CanonicalModel as CM
import ConstraintTrees as C

# Optional  
# import Pkg; Pkg.pkg"add Gurobi_jll@11.0.3"
import Gurobi


# 1. Load and convert the Human-GEM SBML model.
# You can download the HumanGEM model in XML format from https://github.com/SysBioChalmers/Human-GEM

model_path = "Human-GEM.xml"
sbml_model = load_model(model_path)
model = convert(CM.Model, load_model(model_path)) 

# Check the objective of the model 
objective = A.objective(model)
# objective_idx, _ = findnz(objective_rxn)
# If you want to set the objective to a specific reaction use : 
A.objective(model) = "MAR13082" # Biomass reaction
# Set the objective function to the proliferation rate of the cell line 
model.reactions["MAR13082"].lower_bound = 0.02729


# 2. Load Medium Composition
df_medium = CSV.read("MPM.tsv", DataFrame; delim='\t', comment="#")

medium = Dict{String, Float64}()
for row in eachrow(df_medium)
    medium[row.ExRxns_HumanGEM] = -1000.0
end

mandatory_ex_rxns = Dict(
    "MAR09048" => -1000.0,  # O2
    "MAR09047" => -1000.0,  # H2O
    "MAR09058" => -1000.0,  # CO2
    "MAR09079" => -1000.0,  # H+
)

medium = merge(medium, mandatory_ex_rxns)
medium 

# 3. Identify Exchange Reactions

function get_exchange_rxns(model)
    S = A.stoichiometry(model)
    ex_rxn_idx = [i for i in 1:size(S, 2) if count(!iszero, S[:, i]) == 1]
    A.reactions(model)[ex_rxn_idx]
end

ex_rxns = get_exchange_rxns(model)

# 4. Integrate Medium into the Model

medium_model = deepcopy(model)

for rxn in ex_rxns
    # Skip changing the objective reaction
    if rxn == "MAR13082" # objective
        continue
    end
    if rxn in keys(medium)
        medium_model.reactions[rxn].lower_bound = medium[rxn]
    else
        medium_model.reactions[rxn].lower_bound = 0.0
    end
end


# 5. Perform Flux Balance Analysis (FBA) on the Medium Constrained Model and the Base Model

flux_balance_analysis(medium_model, optimizer = Gurobi.Optimizer) |> println
flux_balance_analysis(model, optimizer = Gurobi.Optimizer) |> println

# 6. Making the model feasible
# Set the cost of the reactions in the medium to 0. 

medium_rxns = Set(keys(medium))

function fluxes_costs(rxn; medium_cost=0, default_cost=500.0)
    if rxn in medium_rxns
        return medium_cost
    else
        return default_cost
    end
end

gap_fill = gap_filling_analysis(  
    medium_model,        # incomplete model
    model,               # reference model
    0.02729,             # target objective value set to the proliferation rate of the cell line
    universal_reaction_cost = fluxes_costs,  # cost of universal reactions
    max_cost = Inf,       # maximum number of reactions to add
    optimizer = Gurobi.Optimizer,
)

filled_reactions = [k for (k, v) in gap_fill.fill_flags if v > 0]  

for (k, v) in gap_fill.fill_flags
    if v > 0
        println("k: $k, v: $v")
    end
end

# 7. Complete the Medium Model with the Filled Reactions
for rxn in filled_reactions
    rxn_id = String(rxn) 
    
    if rxn_id == "MAR13082" # Don't change the objective value
        continue
    end
    
    println(medium_model.reactions[rxn_id].name)    
    medium_model.reactions[rxn_id].lower_bound = -1000.0
end

# Check the objective value of the model after gap-filling
fba_result = flux_balance_analysis(medium_model, optimizer = Gurobi.Optimizer)
```


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
