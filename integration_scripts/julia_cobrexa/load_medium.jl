# Copyright (c) 2021-2024, University of Luxembourg                         #src
# Copyright (c) 2021-2024, Heinrich-Heine University Duesseldorf            #src
#                                                                           #src
# Licensed under the Apache License, Version 2.0 (the "License");           #src
# you may not use this file except in compliance with the License.          #src
# You may obtain a copy of the License at                                   #src
#                                                                           #src
#     http://www.apache.org/licenses/LICENSE-2.0                            #src
#                                                                           #src
# Unless required by applicable law or agreed to in writing, software       #src
# distributed under the License is distributed on an "AS IS" BASIS,         #src
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  #src
# See the License for the specific language governing permissions and       #src
# limitations under the License.         

# # Tutorial: Medium specific Gap-Filling a Human Metabolic Model with COBREXA.jl
# ## Overview
# 
# This tutorial demonstrates how to apply gap-filling to a human genome-scale metabolic model (Human-GEM) constrained with the composition of RPMI-1640 + 5% FBS medium.

# ---
 
# ## Requirements

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

# ## 1. Load and convert the Human-GEM SBML model.
#
# You can download the HumanGEM model in XML format from https://github.com/SysBioChalmers/Human-GEM

model_path = "integration_scripts/data/Human-GEM.xml"
sbml_model = load_model(model_path)
model = convert(CM.Model, load_model(model_path)) 

# Check the objective of the model 
objective = A.objective(model)
# objective_idx, _ = findnz(objective_rxn)
# If you want to set the objective to a specific reaction use : 
A.objective(model) = "MAR13082" # Biomass reaction
# Set the objective function to the proliferation rate of the cell line 
model.reactions["MAR13082"].lower_bound = 0.02729

# ---

# ## 2. Load Medium Composition
# We load a TSV file that contains the list of metabolites present in RPMI and FBS.

# rpmi1640 = CSV.read("media/RPMI1640.tsv", DataFrame; delim='\t')
# fbs = CSV.read("media/FBS.tsv", DataFrame; delim='\t')

# combined = vcat(rpmi1640, fbs)
# group_cols = [:Mets_HumanGEM, :ExRxns_HumanGEM]
# df_medium = combine(groupby(combined, group_cols), :Concentration_M => sum => :Concentration_M) # TODO: Convert conventration to fluxes

df_medium = CSV.read("media/MPM.tsv", DataFrame; delim='\t', comment="#")

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

# ---

# ## 3. Identify Exchange Reactions

function get_exchange_rxns(model)
    S = A.stoichiometry(model)
    ex_rxn_idx = [i for i in 1:size(S, 2) if count(!iszero, S[:, i]) == 1]
    A.reactions(model)[ex_rxn_idx]
end

ex_rxns = get_exchange_rxns(model)

# ---

# ## 4. Integrate Medium into the Model

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

# ---

# ## 5. Perform Flux Balance Analysis (FBA) on the Medium Constrained Model and the Base Model

flux_balance_analysis(medium_model, optimizer = Gurobi.Optimizer) |> println
flux_balance_analysis(model, optimizer = Gurobi.Optimizer) |> println

# fba_medium_model = flux_balance_analysis(medium_model, optimizer = Gurobi.Optimizer)
# fba_model = flux_balance_analysis(model, optimizer = Gurobi.Optimizer)

# ---

# ## 6. Making the model feasible based on the likelihood of the medium composition

# Create cost based on the data 
# Set the cost of the reactions in the medium to 0. 
medium_rxns = Set(keys(medium))
# discouraged_rxns = Set(["MAR13051", "MAR13042", "MAR09276"])
discouraged_rxns = Set()

function fluxes_costs(rxn; medium_cost=0.1, default_cost=500.0, discouraged_cost=1e8)
    if rxn in medium_rxns
        return medium_cost
    elseif rxn in discouraged_rxns
        return discouraged_cost
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

# ---

filled_reactions = [k for (k, v) in gap_fill.fill_flags if v > 0]  

for (k, v) in gap_fill.fill_flags
    if v > 0
        println("k: $k, v: $v")
    end
end

# Questions : 
# Some reactions have a flag of 0.XX, then the cost looks wierd ? 
# Why the objective reeaction is always include in the filled reactions ?

# ## 7. Complete the Medium Model with the Filled Reactions
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

# Check the fluxes 
for (rxn, flux) in fba_result.fluxes
    rxn_id = String(rxn)
    if rxn_id in ex_rxns && flux < 0
        println(medium_model.reactions[rxn_id].name)
        println("Reaction: $rxn, Flux: $flux")
    end
end
