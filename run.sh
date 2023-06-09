#!/bin/bash
cd $3
file=$(basename $1|awk -F. '{print $1}')
echo "File Name= $file"
echo "Cluster Number= $2"

mkdir $file
cp $1 ./$file

python3<< END
import pandas as pd
import os
import gc
ped = pd.read_csv("newempty.ped",sep="\t",index_col=None)
print(ped)
mapfile = pd.read_csv("hgdp.map",sep="\t")
print(mapfile)
os.chdir("./$file/")
mapfile.to_csv("$file.map",sep="\t",header=None,index=None)

skipn = pd.read_csv("$file.vcf",sep='\t', error_bad_lines=False)
patient_vcf = pd.read_csv("$file.vcf",sep='\t', error_bad_lines=False, skiprows=len(skipn)+1)

##Remove ".strs id and indels and deletions
patient_vcf = patient_vcf.drop(patient_vcf[patient_vcf.ID == "."].index)
patient_vcf = patient_vcf[~patient_vcf.ID.str.contains(";")]
patient_vcf = patient_vcf[patient_vcf['REF'].str.len()<2]
patient_vcf = patient_vcf[patient_vcf['ALT'].str.len()<2]
patient_vcf = patient_vcf[patient_vcf["ID"].isin(list(ped.columns[6:]))]
 
##add rs alt,ref to NEW column
if "chrY" in patient_vcf['#CHROM'].values:
    ped.iloc[0,4] = "1"
else:
    ped.iloc[0,4] = "2"
    
for j in range(len(patient_vcf)):
    if patient_vcf.iloc[j,7][3] == "1":
        ped.loc[0,patient_vcf.iloc[j,2]] = patient_vcf.iloc[j,4]+" "+ patient_vcf.iloc[j,3]
    else:
        ped.loc[0,patient_vcf.iloc[j,2]] = patient_vcf.iloc[j,4]+" "+ patient_vcf.iloc[j,4]

ped.to_csv("$file.csv",index=None,header=None,sep="\t",float_format="%.0f")
END

cd ./$file/
cat ../hgdp.ped $file.csv > $file.ped

##plink
$5./plink --file $file --recode12 --out bin-$file

##admixture
for K in $2; do ../admixture --cv bin-$file.ped $K -j$4 | tee log${K}.out; done

python3<< END
import os 
import gc
import pandas as pd
import numpy as np
pd.set_option('display.max_rows', 50)

os.chdir("../")
pop = pd.read_csv("pops.csv",index_col=None)

os.chdir("./$file")
analysis = pd.read_csv("bin-$file."+"$2"+".Q",delimiter=" ",header=None)

n=len(analysis)-1
analysis_list = ["Pop7Groups","Geographic_origin","Population"]

for l in analysis_list:
    typeofpop = l
    pop_list = []
    if typeofpop == "Population":
        pop_indcol = 2
    elif typeofpop == "Geographic_origin":
        pop_indcol = 3
    elif typeofpop == "Pop7Groups":
        pop_indcol = 5

    df_mean = pd.DataFrame()
    for i in range(len(pop)):
        pops = pop.iloc[i,pop_indcol]
        
        if pops not in pop_list:
            pop_list.append(pops)
    
    for i in range(len(pop_list)):
        index = pop.index[pop[typeofpop] == pop_list[i]].tolist()
        df = pd.DataFrame([analysis.loc[index,:].mean().tolist()])
        df_mean = df_mean.append(df)
    df_mean.index = pop_list

    ##def
    sumpop = []
    find_index = n+1

    for i in range(len(df_mean)):
        df = analysis.iloc[find_index-1:find_index,:]*df_mean.iloc[i,:]
        sumpop.append(df.sum(axis=1).get(key = float(find_index-1)))
    scaler = sum(sumpop)
    allperce = sumpop/scaler
    df_mean["Percentage of New Person"] = allperce

    pd.set_option('display.max_rows', 500)
    df_sort = df_mean.sort_values(by=["Percentage of New Person"],ascending=False)
    df_sort["Percentage of New Person"].to_excel(str(l)+"$2"+".xlsx",sheet_name=str(l))
END

