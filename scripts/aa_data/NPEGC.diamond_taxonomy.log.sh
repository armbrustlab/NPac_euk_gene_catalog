

# AUTHOR: Ryan Groussman, PhD


#### NPEGC assemblies vs MarFERReT.MARMICRODB.v1.1.combined.dmnd ####

ssh guppy
screen -r diamond

# Point to local installation of NPEGC data:
METAT_DIR="/mnt/nfs/projects/armbrust-metat"

# Local directory of MarFERReT library installation, data, and containers
MARFERRET_DIR="/mnt/nfs/projects/marferret/v1"
DATA_DIR="${MARFERRET_DIR}/data"
CONTAINER_DIR="${MARFERRET_DIR}/containers"

# Define directory paths for the output files:
DIEL_OUT="${METAT_DIR}/scope_diel/diel_pa_metat/assemblies/annotations/diamond/marferret_v1.1"
G1_OUT="${METAT_DIR}/gradients1/g1_station_pa_metat/assemblies/annotations/diamond/marferret_v1.1"
G2_OUT="${METAT_DIR}/gradients2/g2_station_pa_metat/assemblies/annotations/diamond/marferret_v1.1"
G3UW_OUT="${METAT_DIR}/gradients3/g3_uw_pa_metat/assemblies/annotations/diamond/marferret_v1.1"
G3DIEL_OUT="${METAT_DIR}/gradients3/g3_uw_pa_metat/assemblies/annotations/diamond/marferret_v1.1"

# Path to combined MarFERReT v1.1 + MARMICRODB v1.0 diamond database
# Previously constructed with DIAMOND makedb as described in this script:
        # https://github.com/armbrustlab/marferret/blob/main/scripts/marferret_marmicrodb/merge_marferret_marmicrodb.sh
# Zenodo record for MarFERReT v1.1 + MARMICRODB v1.0 database:
        # https://zenodo.org/records/10586950
MFT_MMDB_DMND_DB="${MARFERRET_DIR}/data/marmicrodb/dmnd/MarFERReT.MARMICRODB.v1.1.combined.dmnd"


EVALUE="1e-5"

N_THREADS=4 # Adjust this value for your specific system

cd ${MARFERRET_DIR}/data/marmicrodb/dmnd/

# Define function for running DIAMOND blastp against
# the MarFERReT v1.1 + MARMICRODB v1.0 taxonomic database
# and generating an estimate of Lowest Common Ancestor identity

function NPEGC_diamond {
# FASTA filename for $STUDY
FASTER_FASTA="NPac.${STUDY}.bf100.id99.aa.fasta"
# Output filename for LCA results in lca.tab file:
LCA_TAB="NPac.${STUDY}.MarFERReT_v1.1_MMDB.lca.tab"
echo "Beginning ${STUDY}"
singularity exec --no-home --bind ${DATA_DIR} \
        "${CONTAINER_DIR}/diamond.sif" diamond blastp \
        -c 4 --threads $N_THREADS \
        --db $MFT_MMDB_DMND_DB -e $EVALUE --top 10 -f 102 \
        --memory-limit 110 \
        --query ${FASTER_FASTA} -o ${LCA_TAB} >> "${STUDY}.MarFERReT_v1.1_MMDB.log" 2>&1
}


# Iterate through the 5 studies with the DIAMOND function
for STUDY in G1PA D1PA G2PA G3PA G3PA_diel; do
echo $STUDY
NPEGC_diamond
done


