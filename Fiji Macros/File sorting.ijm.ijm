parent_dir = "E:/20190331/Deconvolved/"
out_dir_mNeon = "C:/Users/LAB Admin/Desktop/mNeon/"
out_dir_DAPI = "C:/Users/LAB Admin/Desktop/DAPI/"
out_dir_Phase = "C:/Users/LAB Admin/Desktop/Phase/"
all_dir = getFileList(parent_dir);
for(j=0;j<all_dir.length;j++){
	directory = parent_dir+all_dir[j];
	name = substring(all_dir[j],0,lengthOf(all_dir[j])-1);
	list=getFileList(directory);
	for(i=0;i<list.length;i++){
		open(directory+list[i]);
		}
	run("Images to Stack", "name= c1 title=c1 use");
	saveAs("tiff", out_dir_mNeon+"mNeon"+name);
	run("Images to Stack", "name= c2 title=c2 use");
	saveAs("tiff", out_dir_DAPI +name+"c2");
	run("Images to Stack", "name= c3 title=c3 use");
	saveAs("tiff", out_dir_Phase +name+"c3");
	run("Close All");
	}
	