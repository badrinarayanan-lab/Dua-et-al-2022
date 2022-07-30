parent_dir = ""
out_dir= ""
list= getFileList (parent_dir);
for (i=0; i<list.length; i++){
	open(parent_dir+list[i]);
	run("Z Project...", "projection=[Max Intensity]");
	saveAs("tiff", out_dir + list[i]);
	run("Close All");
}

