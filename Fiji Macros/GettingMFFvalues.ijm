par_dir_mito = ""
par_dir_ROI =""
out_dir=""
list1= getFileList(par_dir_mito)
list2 = getFileList (par_dir_ROI)
for (i=0; i<list1.length; i++)
{
open(par_dir_mito+list1[i]);
open(par_dir_ROI+list2[i]);

n = roiManager("count");  
  	do
{
	for (j=0; j<n; j++){
	roiManager("Select", j);
	run("2D Analysis", "perform count total mean total_0 mean_0 mean_1 mean_2 total_1 mean_3 branch branch_0 mean_4 if=Count area perimeter form aspect branches_0 total_2 mean_5 branch_1 branch_2 mean_6 longest mask=None mask_0=Mask second=None second_0=[Channel 2] third=None third_0=[Channel 3] =None to=None then=None");
}
}
while (j<n)
selectWindow("2D Analysis Data - per Cell");
saveAs("Measurements", out_dir+list1[i] +"Results.csv");
run ("Close");
selectWindow("ROI Manager");
run ("Close");
}
