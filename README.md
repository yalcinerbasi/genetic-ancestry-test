# Genetic Ancestry analysis workflow using Admixture

**Software package requirements:**

Plink v1.9 (https://www.cog-genomics.org/plink/)

Python 3.7 with below packages
> openpyxl, pandas, numpy
	
Command to run:

~~~shell
bash run.sh input_dir(vcf files to be analyzed) cluster_number work_dir number_of_cores_to_use plink_dir
~~~

Example of command:

~~~shell
bash run.sh $PATH/genetic_ancestry_test/analysis_vcf/new_one.vcf 10 $PATH/genetic_ancestry_test/ 8 $PATH/programs/plink_linux_x86_64_20210606/
~~~
