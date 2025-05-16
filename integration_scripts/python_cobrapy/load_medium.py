import cobra
import pandas as pd

# Load the Human-GEM model
model = cobra.io.read_sbml_model("integration_scripts/data/Human-GEM.xml") 
# model = cobra.io.read_sbml_model("integration_scripts/data/Recon3D_301.xml") 

# Load the medium file 
rpmi1640 = pd.read_csv("media/RPMI1640.tsv", index_col=0, sep="\t")
fbs = pd.read_csv("media/FBS.tsv", index_col=0, sep="\t")   
