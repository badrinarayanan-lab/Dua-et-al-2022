parent_dir = ""
out_dir= ""
list= getFileList (parent_dir);
for (i=0; i<list.length; i++){
	open(parent_dir+list[i]);
    run("Subtract Background...", "rolling=10");
    run("Sigma Filter Plus", "radius=1 use=2 minimum=0.2 outlier");
    run("Enhance Local Contrast (CLAHE)", "blocksize=64 histogram=256 maximum=2 mask=*None*");
	run("Tubeness", "sigma=1.0000 use");
	run("8-bit");
    setAutoThreshold("Default dark no-reset");
    setThreshold(10, 255);
    run("Convert to Mask");
    run("Despeckle");
    run("Remove Outliers...", "radius=2 threshold=50 which=Dark");
	saveAs("tiff", out_dir + list[i]);
	run("Close All");
}

