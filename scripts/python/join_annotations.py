import pandas as pd
import os

%% %% %% %%  %% %% %% %%
%% define functions %% %%
%% %% %% %%  %% %% %% %%

# join function:
def prep_kallisto(kallisto_counts_path):
	# load kallisto est_counts:
	kallisto_counts = pd.read_csv(kallisto_counts_path)
	# drop all but nt_id and len
	joined_table = kallisto_counts.iloc[:, :2]
	# rename nt_id:
	joined_table.rename(columns={"target_id": "nt_id"}, inplace=True)
	# drop counts table:
	del kallisto_counts
	return joined_table

def prep_diamond(diamond_path): 
	# Load and process DIAMOND data
	dmnd_dat = pd.read_csv(diamond_path, sep="\t", header=None)
	dmnd_dat.columns = ["aa_id", "tax_id", "eval"]
	# Filter out 0 values (no annotation)
	dmnd_dat = dmnd_dat[dmnd_dat['tax_id'] != 0]
	# Get nt_id from aa_id
	dmnd_dat['nt_id'] = dmnd_dat['aa_id'].str[:-2]
	# sort df
	sorted_dmnd_dat = dmnd_dat.sort_values(by=['nt_id', 'eval'])
	# group by nt and select first:
	sorted_dmnd_dat = sorted_dmnd_dat.groupby('nt_id').first().reset_index()
	# drop extra cols and extra tables
	sorted_dmnd_dat = sorted_dmnd_dat.drop(columns=['aa_id', 'eval'])
	del dmnd_dat
	return sorted_dmnd_dat

def prep_pfam(pfam_path):
	### bring in pfam
	pfam_dat = pd.read_csv(pfam_path)
	# pfam_dat.columns : ['aa_id', 'knum', 'knum_eval', 'knum_score']
	# aa_id to nt_id
	pfam_dat['nt_id'] = pfam_dat['aa_id'].str[:-2]
	# knum rename to pfam (these are the IDs we use)
	pfam_dat.rename(columns={"knum": "pfam"}, inplace=True)
	# sort df
	sorted_pfam_dat = pfam_dat.sort_values(by=['nt_id', 'knum_eval'])
	# group by nt 
	sorted_pfam_dat = sorted_pfam_dat.groupby('nt_id').first().reset_index()
	sorted_pfam_dat.shape # (9241929, 5)
	# drop extra columns, tables and return:
	sorted_pfam_dat = sorted_pfam_dat.drop(columns=['aa_id', 'knum_eval', 'knum_score'])
	del pfam_dat
	return sorted_pfam_dat

def merge_tables(joined_table, sorted_dmnd_dat, sorted_pfam_dat):
	# merge dmnd with joined table:
	joined_table_merged = pd.merge(joined_table, sorted_dmnd_dat, on='nt_id', how='left')
	# merge pfam:
	joined_table_merged = pd.merge(joined_table_merged, sorted_pfam_dat, on='nt_id', how='left')
	return joined_table_merged

def final_joined_stats(joined_table_merged):
	joined_table_merged.shape
	joined_table_merged.columns
	# ['nt_id', 'length', 'tax_id', 'pfam']
	# function for final stats:
	# clustered nt
	total_nt_contigs = joined_table_merged.shape[0]
	print("Total contig nt_ids: ", str(total_nt_contigs) )
	# number w tax
	total_w_tax = joined_table_merged['tax_id'].notna().sum()
	print("Total contig w/ tax: ", str(total_w_tax) )	
	# percent w tax
	total_w_tax/total_nt_contigs 
	print("Total contig w/ tax %: ", str(total_w_tax/total_nt_contigs) )
	# number w pfam
	total_w_pfam = joined_table_merged['pfam'].notna().sum()
	print("Total contig w/ pfam: ", str(total_w_pfam)) 
	# percent w pfam
	print("Total contig w/ pfam %: ", str(total_w_pfam/total_nt_contigs))



%% %% %% %%  %% %% %% %% %%  
%% project data paths  %% %%
%% %% %% %%  %% %% %% %% %%  


# define local project path and ID
os.chdir("/mnt/nfs/projects/armbrust-metat/gradients1/g1_station_pa_metat/assemblies/annotations")
project_id = "G1PA" 

# paths to project annotations with project_id:
# kallisto counts_path
kallisto_counts_path = f"kallisto/{project_id}.raw.est_counts.csv.gz"
# taxonomy path
diamond_path = f"diamond/marferret_v1.1/NPac.{project_id}.MarFERReT_v1.1_MMDB.lca.tab.gz"
# pfam path:
pfam_path = f"pfam/{project_id}.Pfam35.hmm_out.csv.gz"
# output path:
joined_output_path = f"{project_id}.joined_tax_funct.csv.gz"


# check if paths exist for all three:
check_paths = [kallisto_counts_path, diamond_path, pfam_path]
for path in check_paths:
    os.path.exists(path)

%% %% %% %%  %% %% %% %%
%% run functions %% %%
%% %% %% %%  %% %% %% %%

joined_table = prep_kallisto(kallisto_counts_path)
joined_table.shape
sorted_dmnd_dat = prep_diamond(diamond_path)
sorted_dmnd_dat.shape
sorted_pfam_dat = prep_pfam(pfam_path)
sorted_pfam_dat.shape

# join tables:
joined_table_merged = merge_tables(joined_table, sorted_dmnd_dat, sorted_pfam_dat)
# run final stats:
final_joined_stats(joined_table_merged)

