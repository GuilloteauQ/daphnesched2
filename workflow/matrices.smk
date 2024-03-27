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
}

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
    "matrices/{matrix}/{matrix}.mtx.meta"
  params:
    meta = lambda w: json.dumps(matrices[w.matrix]["meta"])
  shell:
    "echo '{params.meta}' > {output}"
