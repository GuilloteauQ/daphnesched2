import json

matrices = {
  "amazon0601" : {
   "url": "https://suitesparse-collection-website.herokuapp.com/MM/SNAP/amazon0601.tar.gz",
   "meta" : {
     "numRows": 403394,
     "numCols": 403394,
     "numNonZeros": 3387388,
     "valueType": "f64"
    }
  },
  "wikipedia-20070206" : {
   "url": "https://suitesparse-collection-website.herokuapp.com/MM/Gleich/wikipedia-20070206.tar.gz",
   "meta" : {
     "numRows": 3566907,
     "numCols": 3566907,
     "numNonZeros": 45030389,
     "valueType": "f64"
    }
  },
}

rule all_matrices:
  input:
    expand("matrices/{matrix}/{matrix}_ones.mtx", matrix=matrices.keys()),
    expand("matrices/{matrix}/{matrix}_ones.mtx.meta", matrix=matrices.keys())
    

rule untar_matrix:
  input:
    "matrices/{matrix}.tar.gz"
  output:
    "matrices/{matrix}/{matrix}.mtx"
  shell:
    "tar -xzf {input} -C matrices"

rule download_matrix:
  output:
    "matrices/{matrix}.tar.gz"
  params:
    url = lambda w: matrices[w.matrix]["url"]
  shell:
    "wget {params.url} -O {output}"

rule setup_metadata:
  output:
    "matrices/{matrix}/{matrix}_ones.mtx.meta"
  wildcard_constraints:
    matrix="[a-zA-Z0-9-]+"
  params:
    meta = lambda w: json.dumps(matrices[w.matrix]["meta"])
  shell:
    "echo '{params.meta}' > {output}"

rule add_ones:
  input:
    mat="matrices/{matrix}/{matrix}.mtx",
    script="workflow/scripts/python/fix_matrices.py"
  wildcard_constraints:
    matrix="[a-zA-Z0-9-]+"
  output:
    "matrices/{matrix}/{matrix}_ones.mtx"
  shell:
    "python3 {input.script} --input {input.mat} --output {output}"

