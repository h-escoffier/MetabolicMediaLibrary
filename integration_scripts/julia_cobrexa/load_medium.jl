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

# # Creation of an medium constraint metabolic model 
#
# In this tutorial, we show how to constrain a human genome-scale model (Human-GEM)
# using the composition of RPMI-1640 medium supplemented with 5% FBS.
#
# The medium composition are taken from the [MedumMetaMod repoitory](https://github.com/h-escoffier/MediumMetaMod). 

using COBREXA
using CSV, DataFrames
import JSONFBCModels, SBMLFBCModels, HiGHS
import AbstractFBCModels as A
import ConstraintTrees as C

# ## Load the HumanGEM model
#
# You can download the HumanGEM model in XML format from https://github.com/SysBioChalmers/Human-GEM

model_path = "integration_scripts/data/Human-GEM.xml"
model = load_model(model_path)

# ## Inspecting the medium composition
#
# We load a TSV file that contains the list of metabolites present in RPMI and FBS.

rpmi1640 = CSV.read("media/RPMI1640.tsv", DataFrame; delim='\t')
fbs = CSV.read("media/FBS.tsv", DataFrame; delim='\t')

# Create a DataFrame with the medium composition (RPMI-1640 and FBS)
combined = vcat(rpmi1640, fbs)
group_cols = [:Mets_Recon3D, :Mets_HumanGEM, :ExRxns_Recon3D, :ExRxns_HumanGEM]
medium = combine(groupby(combined, group_cols), :Concentration_M => sum => :Concentration_M)

# Convert concentration (in M) to fluxes (in mmol/gDW/h) based on the function Conc2Rate developed by Ines Thiele
# and Loic Marx

# Cell concentration in cell/mL : 1e6 based on : 
# > For a typical screening experiment, cells are inoculated into 96 well 
# > microtiter plates in 100 μL at plating densities ranging from 5,000 to 40,000 
# > cells/well depending on the doubling time of individual cell lines.

# and 

# > Inoculation Density for MCF7 cells in 96-well plates: 10,000 cells/well

function conc_to_flux(conc_M, cell_conc; cell_weight_g=400e-12, doubling_time_h=24)
    return conc_M / (cell_conc * cell_weight_g * doubling_time_h * 1000)
end

medium.Flux_mmol_gDW_h = conc_to_flux.(medium.Concentration_M, 1e5)

# TODO : Convert fluxes in mmol/gDW/h to fluxes in mg/gDW/h

# Store the medium composition in a Dictionary with the exchange reaction IDs as keys and the concentrations as values.
medium_fluxes = Dict{String, Float64}()
for row in eachrow(medium)
    medium_fluxes[row.ExRxns_HumanGEM] = -1*(row.Flux_mmol_gDW_h)
end

# We also add some metabolites that are **always** included in the media definitions, as they represent essential environmental conditions or atmospheric gases (e.g., oxygen). 
const mandatory_ex_rxns = Dict(
    "MAR09048" => -1000.0, # Oxygen - O2
    "MAR09047" => -1000.0, # Water - H2O
    "MAR09058" => -1000.0, # Carbon Dioxide - CO2
    "MAR09079" => -1000.0, # Proton - H 
    "MAR09386" => -1000.0, # Hydroxide - OH
    ) 

medium_fluxes = merge(medium_fluxes, mandatory_ex_rxns)

# ## Apply medium constraints to the model

# Use ContraintTrees to represent the model strucuture and constraints
model_cst = flux_balance_constraints(model)

model_opt = optimized_values(
    model_cst,
    objective = model_cst.objective.value,
    optimizer = HiGHS.Optimizer,
)

model_opt.objective

# We need to create a constraint that will be represent the medium constraints.
# Thus, we need first to identiy the exchange reactions in the model.

function get_exchange_rxns(model)
    S = A.stoichiometry(model)

    # Identify reactions with only one non-zero entry in the S matrix
    ex_rxn_idx = [i for i in 1:size(S, 2) if count(!iszero, S[:, i]) == 1]

    # Identify the exchange reactions
    exchange_rxns = A.reactions(model)[ex_rxn_idx]
    return exchange_rxns
end

ex_rxns = get_exchange_rxns(model)

# Create Dict of exchange reactions and their corresponding fluxes
medium_constraints = Dict()
for rxn in ex_rxns
    ub = 1000.0
    lb = rxn in keys(medium_fluxes) ? medium_fluxes[rxn] : 0.0
    # lb = rxn in keys(medium_fluxes) ? -1000.0 : 0.0
    medium_constraints[rxn] = (lb, ub)
end

# Add the medium constraints to ConstraintTree
medium_model_cst = model_cst * :medium_constraint^C.ConstraintTree(Symbol(ex_rxn) => C.Constraint(model_cst.fluxes[Symbol(ex_rxn)].value, (lb, ub)) for (ex_rxn, (lb, ub)) in medium_constraints)
# medium_model_cst = model_cst * :medium_constraint^C.ConstraintTree(Symbol(ex_rxn) => C.Constraint(model_cst.fluxes[Symbol(ex_rxn)].value, (flux, 1000.0)) for (ex_rxn, flux) in medium_fluxes)

# ## Perform FBA on medium constrained model

medium_model_opt = optimized_values(
    medium_model_cst,
    objective = medium_model_cst.objective.value,
    optimizer = HiGHS.Optimizer,
)

medium_model_opt.objective

medium_model_fva_fluxes = constraints_variability(medium_model_cst, medium_model_cst.fluxes, optimizer = HiGHS.Optimizer)

# ## Optional : Save the uptakes and secretions fluxes of the model 

data_medium_model = DataFrame(
    Rxn = [String(key) for key in keys(medium_model_opt.fluxes)],
    Value = [medium_model_opt.fluxes[key] for key in keys(medium_model_opt.fluxes)]
)

data_model = DataFrame(
    Rxn = [String(key) for key in keys(model_opt.fluxes)],
    Value = [model_opt.fluxes[key] for key in keys(model_opt.fluxes)]
)

data_medium_model = filter(row -> row.Rxn in ex_rxns, data_medium_model)
data_model = filter(row -> row.Rxn in ex_rxns, data_model)

data_total = DataFrame(
    Rxn = [String(key) for key in keys(ec_variabilities.fluxes)],
    Lower = [ec_variabilities.fluxes[key][1] for key in keys(ec_variabilities.fluxes)],
    Upper = [ec_variabilities.fluxes[key][2] for key in keys(ec_variabilities.fluxes)],
)


# Write to a TSV file
CSV.write("medium_model.tsv", data_medium_model; delim='\t')
CSV.write("model.tsv", data_model; delim='\t')
CSV.write("medium_model_fva.tsv", data_total; delim='\t')

