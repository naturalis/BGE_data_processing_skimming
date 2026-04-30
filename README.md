# BGE genome skimming data processing
This document describes the preparation steps for analysing genome skims for [BGE](https://biodiversitygenomics.eu/).
Up to 16 plates (95 samples + 1 negative control per plate) can be sent in a batch (4 index pools) to [SciLifeLab NGI](https://ngisweden.scilifelab.se/).
After sequencing, these data need to be downloaded, checksummed, and split by plate before analyses commence.

## DDS data download
To download data from DDS you need an account and have the [DDS client](https://scilifelabdatacentre.github.io/dds_cli/installation/) installed on your system. You will get an email notification when new data
is available on the DDS server.
Login to the designated MaaS-node and cd to the destination directory. Start a screen session and download the data.
<pre><code>screen -DR getdata_dds -L -Logfile snpseq01159.log
time dds data get --get-all --project snpseq01159</code></pre>

## MD5 Checksums
Run checksums to verify data integrity. Downloaded data can be found in the files folder in the DataDelivery directory, e.g. DataDelivery_2025-03-20_11-26-11_snpseq01159_download/files/YB-4209/20250314_LH00179_0205_A22MGTLLT4 this folder will contain ***checksums.md5*** provided by the sequence centre and is the same location for calculating md5 checksums on our side:
<pre><code>screen -DR checksum
time md5sum $(ls */* | sort -n) > checksums.local.sorted.md5
  # sort the provided checksum file on filename:
cat checksums.md5 | awk '{print $0 | "sort -k2"}' > checksums.sorted.md5
  # make name equal (i.e. name of the parent directory needs to be added):
sed -i 's/Sample_YB/20250314_LH00179_0205_A22MGTLLT4\/Sample_YB/g' checksums.local.sorted.md5
  # check if checksums are identical:
diff checksums.sorted.md5 checksums.local.sorted.md5</code></pre>
If the checksums are identical only four files (.html .zip .md and .csv) will show.

## MultiQC
Backup the MultiQC report (html/zip) to [Google Drive](https://drive.google.com/drive/u/0/folders/17MvTBKfd92oqNXTxKr-5WwJUwwDGFyPE)  

## Split by plate
After sequencing, all fastq files will end up in a single output folder, while both BGE and lab workflows are plate-oriented. 
There are some advantages to splitting the data per plate, like: efficiency (data can processed in parallel),
robustness (errors don't affect other plates), transfer speed (faster to and from S3 shared storage) and traceability (detection of plate swaps).

## Data issues (non-BGE, non-sequential, missing negative controls)
Early on in the project it was decided to switch from samplenames that reflected platenumber and well position (used for labwork) to BOLD_process_IDs. Though this clarified the relation between the sample and BOLD, it obscured the relation between sample and plate. Expected for this workflow are BGE plates consisting of 95 samples in sequential order and a negative control (containing the platenumber) in the last well (H12). For the majority of plates this was the case and we could follow the [run2split method using brace expansion](archive/sample_ranges.md/#superseded-method-run2splitsh-using-brace-expansion). Until it didn't and we started receiving plates not having 95 samples, samplenames not being sequential (or with multiple institute codes), not having a negative control or having it in a different position (not H12) or with a different name (ie. not -NC-), etc. This made it much harder to keep using the brace expansion method to define [sample ranges](archive/sample_ranges.md#). A last issue needing attention is the presence of samples requiring different markers (COI,RBCL,ITS) or different translation tables (e.g. arthropods and chordates) in the same plate.

## run2split
Because of these [data issues](#data-issues-non-bge-non-sequential-missing-negative-controls) the last incarnation of run2split no longer relies on brace expansion, but gets its data directly from sampleform.csv (=form containing all sampleIDs for all plates in a run) instead. First use [generate_run2split.sh](scripts/generate_run2split.sh) to create a run2split.sh tailored to your run
<pre><code>generate_run2split.sh sampleform.csv</code></pre>
The output will be a file called run2split.sh (this file will differ for each run, so you might rename it to keep track). Execute run2split.sh from the same directory where the [checksums](#md5-checksums) are located. Without the -execute flag, commands will only be written to sdout (to inspect or save as log file). Check the output and when satisfied execute run2split.sh:
<pre><code>run2split.sh -execute</code></pre>

## multiple translation tables 
Omit samples (when multiple translation tables would be required for the same plate) --> work out scripts/omit_samples.sh

## Backup to NDOR S3
_Note: 
As of 2025-07-31 skimming data for BGE is stored on AWS S3 instead of NDOR S3.  
Instructions for AWS S3 still need to be added._  

To store data on [Naturalis Digital Object Repository (NDOR)](https://console.ndor.naturalis.io/), the Minio S3 client and [rclone](https://docs.google.com/document/d/1Khsvrmg8hW6EfW8MWnXIXLseChUqcx--Ro9hByhGjVc/edit?tab=t.0#heading=h.6bla1bvhmnq3) need to be installed on the MaaS-node where the data is located.
<pre><code>  # check the total size of the data to be copied
du -hcs $(ls | egrep "^BGE00(417|418|431|501|414|300|193|432|194|316|320|502|105|104|188|191)$") | egrep "total"
  # check availability and contents of destination location
mc ls minio3/dickgroenenberg/skimming/input
  # start a screen session
screen -DR backup -L 
  # copy the data (use rclone, not mc cp !!) 
time (
  for dir in BGE00{417,418,431,501,414,300,193,432,194,316,320,502,105,104,188,191}; do
    rclone copy -v -P "$dir" "minio3:/dickgroenenberg/skimming/input/$dir"
  done
)</code></pre>

## Specimen Data
Received sample sheets from partner institutes (in [Checklists_Naturalis](https://drive.google.com/drive/folders/1O-CqkrjJJw19K2u4X3Q6rb40WqJ8vLvv?usp=drive_link)) occasionally differ from how they are registered at BOLD. Because a number of scripts in the MGE pipeline (e.g. go_fetch) require properly formatted tsv files it is advised to download them directly from BOLD. The [output](data/output_example.sh) of run2split.sh can be used for the creation of plate folders and the retrieval of required Process IDs from BOLD. Cd to the directory where you want to create the plate folders, copy and execute the mkdir command. To generate a list of Process IDs to search on BOLD (on per line) use Sample_range. In case of the first plate (BGE00417) this will be: 
<pre><code>echo BGLIB{1521..1615}-24 | tr " " "\n"</code></pre>
Copy the Process IDs, log in to BOLD. On the main console go to "Record Search" and paste the ProcessIDs in the List of Identifiers tab ("Process IDs" and "include public records" should be selected). Press "Search Records". The record list should return 95 specimens. Click "select al" and "Downloads -> Data Spreadsheets". Select all checkboxes under "Specimen Data". Unfortunately, there's no option to download both xlsx and tsv files. Downstream processing requires tsv files, but select "Multi-Page" (xlsx) if a spreadsheet is desired. The latter can easily be converted with [xlsxbold2tsv](scripts/xlsxbold2tsv_multiple.py):
<pre><code>xlsxbold2tsv_multiple.py BGE00417.xlsx </code></pre>
This will create a tsv folder with a tsv file for each tab of the xlsx file. To get a quick impression of the higher taxonomy per plate:
<pre><code># Phylum:
awk -F"\t" '{print $2}' tsv/*_Taxonomy.tsv | sort -n | egrep -v "Phylum" | uniq -c
# Class
awk -F"\t" '{print $3}' tsv/*_Taxonomy.tsv | sort -n | egrep -v "Class" | uniq -c</code></pre>

