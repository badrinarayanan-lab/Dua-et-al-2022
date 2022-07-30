parent_dir = ""
out_dir_1 = ""
out_dir_2 = ""
out_dir_3 = ""
all_dir = getFileList(parent_dir);
for(j=0;j<all_dir.length;j++){
	directory = parent_dir+all_dir[j];
	name = substring(all_dir[j],0,lengthOf(all_dir[j])-1);
	list=getFileList(directory);
	for(i=0;i<list.length;i++){
		open(directory+list[i]);
		}
	run("Images to Stack", "name= c1 title=c1 use");
	saveAs("tiff", out_dir_1 +"mNeon"+name);
	run("Images to Stack", "name= c2 title=c2 use");
	saveAs("tiff", out_dir_2 +name+"c2");
	run("Images to Stack", "name= c3 title=c3 use");
	saveAs("tiff", out_dir_3 +name+"c3");
	run("Close All");
	}
	
