#!/bin/bash

# Script to collect all coding productivity metrics with multimetric for the desired code.

# entries of the form benchmark-name:algo-name:short-form:type
entries=(
    "connected_components:connected_components:cc:seq" 
    "connected_components-mpi:connected_components:cc:mpi"
    "pagerank:pagerank:pr:seq" 
    "pagerank-mpi:pagerank:pr:mpi"    
)
langs=("cpp" "py" "jl" "daph")
indir="../../../benchmark_scripts"
outdir="../../metrics"

# clear output directory
rm "${outdir}"*.json 2>/dev/null

# activate conda env
source /opt/miniconda3/etc/profile.d/conda.sh # adapt this path for your local miniconda installation
conda activate code-metrics
# change to multimetric folder
cd ./multimetric/multimetric

for entry in "${entries[@]}"; 
do
    IFS=':' read -r name algo short type <<< "$entry"

    for lang in "${langs[@]}"; 
    do

        infile="${indir}/${name}/${lang}/${algo}.${lang}"
        outfile="${outdir}/${short}_${lang}_${type}.json"

        if [[ -f "$infile" ]]; then
            echo "Analyzing: $infile -> ${outdir}/outfile"
            multimetric "$infile" > "$outfile"
        else
            echo "Skipping missing file: $infile"
        fi

  done
done