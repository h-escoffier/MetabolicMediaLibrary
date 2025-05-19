import cobra
import pandas as pd

# Load the Human-GEM model
model = cobra.io.read_sbml_model("integration_scripts/data/Human-GEM.xml") 
# model = cobra.io.read_sbml_model("integration_scripts/data/Recon3D_301.xml") 

# Visualize the model 
# Metabolites
# for met in model.metabolites:
#     print(f"{met.id}: {met.name}")

# Load the medium file 
rpmi1640 = pd.read_csv("media/RPMI1640.tsv", sep="\t")
fbs = pd.read_csv("media/FBS.tsv", sep="\t")   
combined = pd.concat([rpmi1640, fbs], ignore_index=True)

group_cols = ['Mets_Recon3D', 'Mets_HumanGEM', 'ExRxns_Recon3D', 'ExRxns_HumanGEM']
medium = combined.groupby(group_cols, as_index=False)['Concentration_M'].sum()

# print(medium.head())

# Conc2Rate 
def conc_to_flux(conc_M, cell_conc, cell_weight_g=400e-12, doubling_time_h=24):
    return conc_M / (cell_conc * cell_weight_g * doubling_time_h * 1000)

medium["Flux_mmol_gDW_h"] = conc_to_flux(medium["Concentration_M"], 1e5)

# Create a dictionary for medium fluxes
medium_fluxes = {
    row["ExRxns_HumanGEM"]: -row["Flux_mmol_gDW_h"]
    for _, row in medium.iterrows()
}

# Add mandatory exchange reactions
mandatory_ex_rxns = {
    "MAR09048": -1000.0,  # O2
    "MAR09047": -1000.0,  # H2O
    "MAR09058": -1000.0,  # CO2
    "MAR09079": -1000.0,  # H+
    "MAR09386": -1000.0   # OH-
}
medium_fluxes.update(mandatory_ex_rxns)

# print(medium_fluxes)

# Id exchange reactions 
ex_rxns = model.exchanges # Warning find only exchange (not demand or sink)

solution_full = model.optimize()

exchange_fluxes_full = pd.DataFrame([
    {"Rxn": rxn.name, "Value": solution_full.fluxes.get(rxn.id, 0.0)}
    for rxn in model.reactions
    if rxn.id in ex_rxns
])

print(solution_full.objective_value)

# Apply medium constraints to the model 
for rxn in ex_rxns:
    reaction = model.reactions.get_by_id(rxn.id)
    if rxn.id in medium_fluxes:
        reaction.lower_bound = medium_fluxes[rxn.id]
        # reaction.lower_bound = -1000.0
    else:
        reaction.lower_bound = 0.0
    # reaction.upper_bound = 1000.0

# Perform FBA on medium constrained model + all exchange closed 
solution_medium = model.optimize()

print(solution_medium.objective_value)

exchange_fluxes_medium = pd.DataFrame([
    {"Rxn": rxn.name, "Value": solution_medium.fluxes.get(rxn.id, 0.0)}
    for rxn in model.reactions
    if rxn.id in ex_rxns
])

# Put output into csv
# exchange_fluxes_medium.to_csv("medium_model.tsv", sep="\t", index=False)
# exchange_fluxes_full.to_csv("model.tsv", sep="\t", index=False)