# Genetic Ancestry analysis workflow using Admixture

Software package requirements:
Plink v1.9 (https://www.cog-genomics.org/plink/)
Python 3 with below packages
	> openpyxl
	> pandas
	> numpy
	
Command to run:
bash run.sh input_dir(vcf files to be analyzed) cluster_number work_dir number_of_cores_to_use plink_dir

Example of command:
bash run.sh /home/ylcnhn/Desktop/Git_Projects/genetic_ancestry/analysis_vcf/new_one.vcf 10 /home/ylcnhn/Desktop/Git_Projects/genetic_ancestry/ 8 /home/ylcnhn/Desktop/programs/plink_linux_x86_64_20210606/

