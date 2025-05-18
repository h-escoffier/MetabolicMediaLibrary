import cobra
import pandas as pd

# Load the Human-GEM model
model = cobra.io.read_sbml_model("integration_scripts/data/Human-GEM.xml") 
# model = cobra.io.read_sbml_model("integration_scripts/data/Recon3D_301.xml") 

# Visualize the model 
# Metabolites
# for met in model.metabolites:
#     print(f"{met.id}: {met.name}")

# Exchange reactions
rxn_data = []

for rxn in model.exchanges:
    rxn_data.append({"rxn_id": rxn.id, "rxn_name": rxn.name})

rxn_df = pd.DataFrame(rxn_data)
rxn_df.to_csv("templates/ex_rxns_human_gem.tsv", sep="\t", index=False)
# rxn_df.to_csv("templates/ex_rxns_recon.tsv", sep="\t", index=False)

# Load the medium file 
# rpmi1640 = pd.read_csv("media/RPMI1640.tsv", index_col=0, sep="\t")
# fbs = pd.read_csv("media/FBS.tsv", index_col=0, sep="\t")   

# Conc2Rate 

# Set the objective

# Apply medium constraints to the model 

# Perform FBA on meduim constrained model 

# Performe FBA on the model 

# Perform FBA on medium constrained model + all exchange closed 

# Put output into csv