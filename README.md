# BGE genome skimming data processing
This document describes the preparation steps for analysing genome skims for [BGE](https://biodiversitygenomics.eu/).
Up to 16 plates (95 samples + 1 negative control per plate) are sent in a batch (4 index pools) to [SciLifeLab NGI](https://ngisweden.scilifelab.se/).
After sequencing, these data need to be downloaded, checksummed, and split per plate before analyses commence.

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
sed -i 's/Sample_YA/20250131_LH00179_0174_B22L552LT4\/Sample_YA/g' checksums.local.sorted.md5
  # check if checksums are identical:
diff checksums.sorted.md5 checksums.local.sorted.md5</code></pre>
If the checksums are identical only four files (.html .zip .md and .csv) will show.

## Sample range
To split the data per plate (which facilitates traceability and uploading/retrieving data from S3 storage), download the [SampleForm](data/YB-4209_SampleForm.csv) (Ready-made-libraries), for submitting the plates to the sequence centre, as *.csv from [Google Drive](https://drive.google.com/drive/folders/1lxCPhEpvqq0meHPkXx-FaAgUgPk03dtY?usp=drive_link).
<pre><code>./scripts/BGE_range_extract.sh data/YB-4209_SampleForm.csv</code></pre>
For the example data the output will look like this:
<div align="center">
  <img src="images/range_extract_output.png" width="400">
</div>

## Run2split.sh
## Backup to NDOR S3
