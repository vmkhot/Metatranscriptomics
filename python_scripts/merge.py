#!/usr/bin/python3

import pandas as pd
from pathlib import Path

pathlist = Path("./").glob("*.txt")

result_all=pd.read_csv("rpkm_AC1_S50.txt",sep='\t',header=4, usecols=[0,4] ,names=['gene','reads'],engine='python')
result_filt_50 = result_all.loc[result_all['reads'] >= 250] 

for path in pathlist:
    print(path.stem)
    df = pd.read_csv(path,sep='\t',header=4, usecols=[0,4] ,names=['gene','reads'],engine='python')
#   print(df)
    df_50 = df.loc[df['reads'] >= 250]
#   print(df_50)
    result_all = result_all.merge(df, how = 'outer', on = 'gene', suffixes=(None,f"_{path.stem[5:]}"))
    result_filt_50 = result_filt_50.merge(df_50, how = 'outer', on = 'gene', suffixes=(None,f"_{path.stem[5:]}"))
    

result_all.drop(labels=['reads'], axis=1, inplace = True) #remove extra reads column
result_all.fillna(0,inplace = True)

result_filt_50.drop(labels=['reads'], axis=1, inplace = True) #remove extra reads column
result_filt_50.fillna(0,inplace = True)



#result_all_1 = result_all.copy(deep=True)
#
#result_all_1[['genome','contig']]=result_all_1['gene'].str.split('.', n = 1, expand = True)
##result_all_1.drop(labels=['gene'], inplace = True)
#
#result_genome = result_all_1.groupby(['genome']).sum()
#
#
#result_cy = result_all.loc[result_all['gene'].str.contains('g0000')]
#
#print(result_all)
#print(result_genome)
#print(result_cy)

#result_all.to_csv('merged_all_genes.tsv',sep='\t',header=True,index=False)
result_filt_50.to_csv('merged_all_genes_min250.tsv',sep='\t',header=True,index=False)
#result_genome.to_csv('merged_genomes.tsv',sep='\t',header=True,index=True)
#result_cy.to_csv('merged_pha_only.tsv',sep='\t',header=True,index=False)


#
#
#
#for f in filelist:
#    df=pd.read_csv(f,sep='\t',header=None, names=['contig','length','mappedReads','unmappedReads'])
#    result=result.merge(df,how='outer',on='contig',suffixes=(None,f))
#
#result.reset_index(inplace=True)
#
##keep one length column
#result.rename(columns={"length":"contigLen"},inplace=True)
##remove all other columns starting with length
#
#
#result_1=result.loc[:,~result.columns.str.startswith('length')] #remove lengths
##print("error0")
#result_1=result_1.iloc[:-1, :]
##result_1.drop(result_1.tail(1).index,inplace=True) #remove garbage last row
##print("error1")
##result_1.to_csv('merged_readStats.tsv',sep='\t',header=True,index=False) #write read statistics to file
#
#
##remove unmapped reads, contig length and index columns in prep for future r_f use
#r_f=result_1.loc[:,~result_1.columns.str.startswith('unmapped')]
##print("error2")
#new_index=r_f.loc[:,'contig']
#print(new_index)
#
#r_f.set_index('contig',inplace=True)
#r_f=r_f.drop(labels=['contigLen','index'],axis=1)
##print("error3")
##print(r_f)
#
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##Reduce Depth.txt file down
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#depth_file="./depth.txt"
#
#depths=pd.read_csv(depth_file, sep='\t')
#
#depths_1=depths.loc[:,~depths.columns.str.endswith('var')]
#depths_1.rename(columns={"ContigName":"contig"},inplace=True)
#
##print(depths_1)
##depths_1.to_csv('./depths_wo_var.txt',sep='\t',header=True,index=False)
##print("error0")
#len_totalavgdepth=depths_1.loc[:,('contig','contigLen','totalAvgDepth')] #store these columns in another dataframe to add back in later
##print("error1")
##print(len_totalavgdepth.head())
#
#d_f=depths_1.drop(labels=['contigLen','totalAvgDepth'],axis=1)
##print("error2")
#d_f.set_index('contig',inplace=True) #remove from working depths dataframe
##print(d_f)






