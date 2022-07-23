parent_dir = ""
list = getFileList(parent_dir)
for (i=0; i<list.length; i++){
	open(parent_dir+list[i]);
run("Subtract Background...", "rolling=10");
run("Save");
close();
}
