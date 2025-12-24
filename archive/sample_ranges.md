## Superseded method: Run2split.sh using brace expansion
This document describes the old method of creating brace expansion expressions to obtain BOLD SampleID ranges.
For plate-level analyses, the run directory gets split into BGE plate folders using these SampleIDs (which are
part of the sequencing filenames).
This method still works (and arguably is more concise than its successor) but fails when SampleIDs are no
longer sequential, and/or when multiple institute codes are being used.

## Sample range
Download the [SampleForm](data/YB-4209_SampleForm.csv) (Ready-made-libraries), for submitting the plates to the sequence centre, as *.csv from [Google Drive](https://drive.google.com/drive/folders/1lxCPhEpvqq0meHPkXx-FaAgUgPk03dtY?usp=drive_link). Use [BGE_range_extract.sh](scripts/BGE_range_extract.sh) to split the data by plate (which facilitates traceability and uploading/retrieving data from S3 storage).
<pre><code>./scripts/BGE_range_extract.sh data/YB-4209_SampleForm.csv</code></pre>
The image below left shows the output for this example. Discrepancies in naming convention are not uncommon (e.g. plate 501) and the conversion of process IDs to brace expansion expressions may require some attention (e.g. plate 501, 502). These expressions (image below right; used by [run2split.sh](scripts/run2split.sh)) can be created manually and/or with the aid of [brace.sh](#Create-expression) Both filenames and the foldername of the negative control for 501 were corrected to prevent issues in the next steps. As a side note: plates never seem to be given in sorted order (keeping the provided order can aid troubleshooting, e.g. plate-swap detection). 
|  <img src="images/range_extract_output.png" width="400"> |  <img src="images/run2split_input.png" width="600"> |
|--------------------------------|--------------------------------|

## Create expression
Brace extension expressions can be generated using [brace.sh](scripts/brace.sh). Provide space-separated SampleIDs as string argument.
<pre><code>brace.sh "CUMNB151-14 CUMNB152-14 CUMNB153-14 CUMNB155-14 CUMNB157-14 CUMNB158-14 CUMNB159-14"</code></pre>

## Run2split.sh
Modify [run2split.sh](scripts/run2split.sh) by replacing the "add entry" section with the obtained brace expansion expressions (image above right) and run it on the same directory where the [checksums](#md5-checksums) were calculated.
<pre><code>./run2split.sh</code></pre>
Six output blocks will be written to sdout. The first block (image below left) shows the number of samples and file size per plate. Each plate should have 95 samples and a negative control and the total file size per plate is generally between ~50 and ~100 Gb. In this example one sequence pool (the last four plates) had higher adapter peaks and was therefore excluded from this run.
|  <img src="images/run2split_output1.png" width="670"> |
|--------------------------------|

The latter five output blocks write commands to stdout (allowing for a final check). Copy [the output](data/output_example.sh) and execute. These commands will:  
2. Create BGE plate directories.  
3. Select and move sequence data to the correct plate directories.  
4. Move the negative controls to the correct plate directories.  
5. Copy the checksums to each plate directory.  
6. Move the plate directories to the desired output location.
