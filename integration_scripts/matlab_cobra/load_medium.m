clear
clc
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
cd(filePath)
initCobraToolbox
changeCobraSolver("ibm_cplex")

%%

medium_file = './../../media/RPMI1640.tsv';
model_path = './../data/Recon3D_301.xml';
fbs_file = './../../media/FBS.tsv';

% reading in the rpmi medium file 
rpmi1640 = readtable(medium_file, 'FileType', 'text', 'Delimiter', '\t');
% reading in the fbs medium file 
fbs = readtable(fbs_file, 'FileType', 'text', 'Delimiter', '\t');
%%
% reading in the model
model = readCbModel(model_path);

%%
%Create a DataFrame with the medium composition (RPMI-1640 and FBS)
fbs.Properties.VariableNames(string(fbs.Properties.VariableNames) == 'Concentration_M') = "Concentration_M_fbs";
rpmi1640.Properties.VariableNames(string(rpmi1640.Properties.VariableNames) == 'Concentration_M') = "Concentration_M_rpmi";
medium = outerjoin(rpmi1640,fbs,...
              'MergeKeys',true,'Keys',["Mets_Recon3D","ExRxns_Recon3D","ExRxns_HumanGEM","Mets_HumanGEM"] );
medium{find(isnan(medium{:, ["Concentration_M_fbs"]})),"Concentration_M_fbs"} = 0;
medium{find(isnan(medium{:, ["Concentration_M_rpmi"]})),"Concentration_M_rpmi"} = 0;

% adding up the metabolites, in case they are in both media components
medium{:, ["Concentration_M"]} = medium{:, ["Concentration_M_fbs"]} + medium{:, ["Concentration_M_rpmi"]};
medium.Concentration_M_rpmi = [];
medium.Concentration_M_fbs = [];    
     
%% conc2Rate

% # Convert concentration (in M) to fluxes (in mmol/gDW/h) based on the function Conc2Rate developed by Ines Thiele
% # and Loic Marx

% # Cell concentration in cell/mL : 1e6 based on : 
% # > For a typical screening experiment, cells are inoculated into 96 well 
% # > microtiter plates in 100 μL at plating densities ranging from 5,000 to 40,000 
% # > cells/well depending on the doubling time of individual cell lines.
% 
% # and 
% 
% # > Inoculation Density for MCF7 cells in 96-well plates: 10,000 cells/well
% 
medium.Flux_mmol_gDW_h = - conc2Rate(medium.Concentration_M,1e5,24,400e-12);

%% define mandatory fluxes 
% # We also add some metabolites that are **always** included in the media definitions, as they represent essential environmental conditions or atmospheric gases (e.g., oxygen). 

mandatory_ex_rxns = table({'EX_o2[e]'; 'EX_h2o[e]';'EX_co2[e]';'EX_h[e]'}, ...
                          {'o2[e]'; 'h2o[e]';'co2[e]';'h[e]';}, ...
                          {'MAR09048';'MAR09047';'MAR09058';'MAR09079';},...
                          repmat(-1000, 4,1),...
                          'VariableNames', ["ExRxns_Recon3D","Mets_Recon3D","ExRxns_HumanGEM" ,"Flux_mmol_gDW_h"]);
                      
medium_fluxes = outerjoin(medium,mandatory_ex_rxns,...
                          'MergeKeys',true,'Keys',["ExRxns_Recon3D","Mets_Recon3D","ExRxns_HumanGEM","Flux_mmol_gDW_h"]);

%% set objective 
model = changeObjective(model,'biomass_reaction');

%% # ## Apply medium constraints to the model
model_medium_constrained = model;
model_med_const_close_exc = model;

medium_fluxes.rxns_idx_model = findRxnIDs(model, medium_fluxes.ExRxns_Recon3D);
medium_fluxes.rxns = model.rxns(medium_fluxes.rxns_idx_model);
if sum(string(medium_fluxes.ExRxns_Recon3D) ~= string(medium_fluxes.rxns))
    error("The rxns do not fit the rxn order in the medium! Check the medium_fluxes table!")
end

model_medium_constrained.lb(medium_fluxes.rxns_idx_model) = medium_fluxes{:,"Flux_mmol_gDW_h"};

%% # ## Perform FBA on medium constrained model

medium_const_sol = optimizeCbModel(model_medium_constrained,'max','zero');


%% # ## Perform FBA on model

sol = optimizeCbModel(model,'max','zero');


%% # ## Perform FBA on medium constrained model + all exchange closed 
model_med_const_close_exc = model_medium_constrained;             
% close allexchange rxns
Ex_to_close = setdiff(model_med_const_close_exc.rxns(findExcRxns(model_med_const_close_exc)),...
                      medium_fluxes.ExRxns_Recon3D);
model_med_const_close_exc.lb(findRxnIDs(model_med_const_close_exc, Ex_to_close))=0; 

% perform FBA 
sol_med_const_close_exc = optimizeCbModel(model_med_const_close_exc,'max','zero');

%% put output into csv

fba_res = table(model.rxns,[1:numel(model.rxns)]',sol.v,medium_const_sol.v,sol_med_const_close_exc.v,...
                'VariableNames',["rxn_abbr_Recon3D","rxn_idx_Recon3D","non_constrained_fba","medium_const_fba", "medium_const_and_exc_close_fba"]);
            
fba_res_exc = fba_res(find(findExcRxns(model_med_const_close_exc)),:);
           
writetable(fba_res_exc,"exc_reaction_fba_biomass.csv");




