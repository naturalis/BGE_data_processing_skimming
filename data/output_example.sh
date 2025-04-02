# output run2split.sh

BGE_plate    Sample_range                           Sample_count   Total_size
----------   ----------                             ------------   ----------
BGE00417     BGLIB{1521..1615}-24                   95             51G       
BGE00418     BGLIB{1616..1710}-24                   95             245G      
BGE00431     UNIFI{951..1045}-24                    95             45G       
BGE00501     BSCRO00{1..9}-24 BSCRO0{10..95}-24     95             66G       
BGE00414     BGLIB{1331..1425}-24                   95             94G       
BGE00300     BGSNL{856..950}-24                     95             95G       
BGE00193     BGENL{2471..2565}-24                   95             103G      
BGE00432     UNIFI{1046..1140}-24                   95             99G       
BGE00194     BGENL{2566..2660}-24                   95             66G       
BGE00316     BGSNL{2186..2280}-24                   95             66G       
BGE00320     BGSNH{381..475}-24                     95             175G      
BGE00502     BSCRO0{96..99}-24 BSCRO{100..190}-24   95             88G       
BGE00105     BBIOP{2376..2470}-24                   0              0         
BGE00104     BBIOP{2281..2375}-24                   0              0         
BGE00188     BGENL{2851..2945}-24                   0              0         
BGE00191     BGENL{2281..2375}-24                   0              0         

# Directory creation command (not executed, for reference only)
# ----------------------------------------
mkdir -p BGE00417 BGE00418 BGE00431 BGE00501 BGE00414 BGE00300 BGE00193 BGE00432 BGE00194 BGE00316 BGE00320 BGE00502 BGE00105 BGE00104 BGE00188 BGE00191

# Move commands (not executed, for reference only)
# ----------------------------------------
mv $(ls | egrep $(echo BGLIB{1521..1615}-24 | tr " " "|") | tr "\n" " ") BGE00417
mv $(ls | egrep $(echo BGLIB{1616..1710}-24 | tr " " "|") | tr "\n" " ") BGE00418
mv $(ls | egrep $(echo UNIFI{951..1045}-24 | tr " " "|") | tr "\n" " ") BGE00431
mv $(ls | egrep $(echo BSCRO00{1..9}-24 BSCRO0{10..95}-24 | tr " " "|") | tr "\n" " ") BGE00501
mv $(ls | egrep $(echo BGLIB{1331..1425}-24 | tr " " "|") | tr "\n" " ") BGE00414
mv $(ls | egrep $(echo BGSNL{856..950}-24 | tr " " "|") | tr "\n" " ") BGE00300
mv $(ls | egrep $(echo BGENL{2471..2565}-24 | tr " " "|") | tr "\n" " ") BGE00193
mv $(ls | egrep $(echo UNIFI{1046..1140}-24 | tr " " "|") | tr "\n" " ") BGE00432
mv $(ls | egrep $(echo BGENL{2566..2660}-24 | tr " " "|") | tr "\n" " ") BGE00194
mv $(ls | egrep $(echo BGSNL{2186..2280}-24 | tr " " "|") | tr "\n" " ") BGE00316
mv $(ls | egrep $(echo BGSNH{381..475}-24 | tr " " "|") | tr "\n" " ") BGE00320
mv $(ls | egrep $(echo BSCRO0{96..99}-24 BSCRO{100..190}-24 | tr " " "|") | tr "\n" " ") BGE00502
mv $(ls | egrep $(echo BBIOP{2376..2470}-24 | tr " " "|") | tr "\n" " ") BGE00105
mv $(ls | egrep $(echo BBIOP{2281..2375}-24 | tr " " "|") | tr "\n" " ") BGE00104
mv $(ls | egrep $(echo BGENL{2851..2945}-24 | tr " " "|") | tr "\n" " ") BGE00188
mv $(ls | egrep $(echo BGENL{2281..2375}-24 | tr " " "|") | tr "\n" " ") BGE00191

# NC prefix move commands (not executed, for reference only)
# ----------------------------------------
mv *NC-BGE00417 BGE00417
mv *NC-BGE00418 BGE00418
mv *NC-BGE00431 BGE00431
mv *NC-BGE00501 BGE00501
mv *NC-BGE00414 BGE00414
mv *NC-BGE00300 BGE00300
mv *NC-BGE00193 BGE00193
mv *NC-BGE00432 BGE00432
mv *NC-BGE00194 BGE00194
mv *NC-BGE00316 BGE00316
mv *NC-BGE00320 BGE00320
mv *NC-BGE00502 BGE00502
mv *NC-BGE00105 BGE00105
mv *NC-BGE00104 BGE00104
mv *NC-BGE00188 BGE00188
mv *NC-BGE00191 BGE00191

# Copy checksums to the BGE subdirs (not executed, for reference only)
# ----------------------------------------
cp checksums* BGE00417/
cp checksums* BGE00418/
cp checksums* BGE00431/
cp checksums* BGE00501/
cp checksums* BGE00414/
cp checksums* BGE00300/
cp checksums* BGE00193/
cp checksums* BGE00432/
cp checksums* BGE00194/
cp checksums* BGE00316/
cp checksums* BGE00320/
cp checksums* BGE00502/
cp checksums* BGE00105/
cp checksums* BGE00104/
cp checksums* BGE00188/
cp checksums* BGE00191/

# Move BGE folder to top folder of BGE-input (not executed, for reference only)
# ----------------------------------------
mv BGE* /data/dick.groenenberg/BGE-input