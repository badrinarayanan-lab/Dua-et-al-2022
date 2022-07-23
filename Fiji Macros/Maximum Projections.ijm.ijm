parent_dir = ""
out_dir_mNeon= ""
list= getFileList (parent_dir);
for (i=0; i<list.length; i++){
	open(parent_dir+list[i]);
	run("Z Project...", "projection=[Max Intensity]");
	saveAs("tiff", out_dir_mNeon + list[i]);
	run("Close All");
}

