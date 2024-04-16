# Phylo_2_genemap

Author: Murat Buyukyoruk

        Phylo_2_genemap help:

This script is developed to illustrate a phylogenetic tree (.newick) along side with a genemap that demonstrates 
the protein sequence alignment and domain prevelance.

![alt_txt](https://github.com/mbuyukyoruk/Phylo_2_genemap/blob/main/demo_tree_genemap%404x.png)

R is required to generate plots with various CRAN packages (i.e., ggtree, gggenes, tidyverse, tidytree and their 
depencencies). The R script is generated to install CRAN packages if they were not available in the system, 

Syntax:

        python Phylo_2_genemap.py -t demo.nexus -o demo_tree_genemap -g genemap_dataframe.txt -a ANK -c clade_info.txt -f y

Example Dataframe for the genemap_dataframe.txt file (tab separated excel file is required):

        molecule	        ORF                 genome	gene	start	end	orientation
        NC_002967.9_2504	NC_002967.9_2504    NC_002967.9 Length	1	934	1
        NC_002967.9_2504	NC_002967.9_2504    NC_002967.9 ANK_1	65	97	1
        NC_002967.9_2504	NC_002967.9_2504    NC_002967.9 ANK	247	312	1
        NC_002967.9_2504	NC_002967.9_2504    NC_002967.9 ANK	313	346	1
        NC_002967.9_2504	NC_002967.9_2504    NC_002967.9 ANK	347	380	1
        NC_002967.9_2504	NC_002967.9_2504    NC_002967.9 ANK	381	413	1
        NC_002967.9_2504	NC_002967.9_2504    NC_002967.9 ANK	543     575	1
        NC_002967.9_2504	NC_002967.9_2504    NC_002967.9 ANK	813     845	1

Example Dataframe for the clade_info.txt file (tab separated excel file is required):

        Clade1	              	Clade2
        NZ_OX366336.1_932	NZ_CP025544.1_57
        NZ_OX366337.1_584	
        NZ_OX366343.1_632	
        NZ_OX366401.1_611	
        NZ_CP076228.1_128	
        NZ_JAATLD010000001.1_206	
        NZ_CP069053.1_339	
        NZ_VCEF01000099.1_2	
        NZ_VCEG01000064.1_7	
        NC_012416.1_91	
        NZ_CP042904.1_88	
        NZ_JAGKTH010000088.1_15	
        NZ_OX366369.1_350	

Phylo_2_genemap dependencies:

	R                                       refer to https://rstudio-education.github.io/hopr/starting.html

Input Paramaters (REQUIRED):
----------------------------
	-t/--tree          	 NEWICK		Specify a phylogenetic tree in .newick format.

	-o/--output         	Output file	Specify a output file name for PNG and EPS files.

	-g/--genemap		Dataframe	Specify a genemap file that include the doamin name, start, stop, strand and orientation information for each domain occurs in protein accessions.

	-a/--anchor     	gene_name       Specify a gene name for aligning the proteins like an anchoring point.
	
	-c/--clade      	Dataframe       Specify a dataframe that includes the clades to color on phylogenetic tree. 

	-f/--flip		Y/N		Allows changing orientation of target gene to the same orientation.

	-i/--interactive	Y/N		Allows interactive plot select a clade and generate subplot.

Basic Options:
--------------
	-h/--help		HELP		Shows this help text and exits the run.
