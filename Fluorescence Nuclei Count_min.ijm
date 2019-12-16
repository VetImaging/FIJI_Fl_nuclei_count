/* Macro for counting nuclei on 8bit-TIFs  - SK 2019-09 VTB
 * Input: stained dapi or other nuclei-staining (e.g. Ki67); scanned with 3D-Histech Scan II slidescanner; converted with 3DHISTECH SlideConverter to 1:2 tiled Tifs / jpg compression 85 / grayscale
 * Output: excel-list with counted nuclei between 10 and 200µm²
 */

// set measurement parameters
run("Set Measurements...", "area shape limit display redirect=None decimal=1");

dir=getDirectory("Choose a Directory");
nucleiDir=dir + "\\Nuclei\\";
File.makeDirectory(nucleiDir);

//get data list and read out number of images for arrays
list = getFileList(dir);

tif_list_length=0;
for (filenumber=0; filenumber<list.length; filenumber++) {
     if (endsWith(list[filenumber], ".tif")){
	   tif_list_length ++;
     }
    }

//define array-variables
plain_title=newArray(tif_list_length+1);
nuclei_count=newArray(tif_list_length+1);

imagenumber=0;
//take one after another image and process
for (filenumber=0; filenumber<list.length; filenumber++) {
     if (endsWith(list[filenumber], ".tif")){
        run("Bio-Formats Windowless Importer", "open=["+dir+list[filenumber]+"]");

//get title of image and rename for results list
plain_title[imagenumber] = getTitle();
plain_title[imagenumber] = replace(plain_title[imagenumber], "\\-ZERO_Extended.tif", "");
rename(plain_title[imagenumber]);
imageTitle = getTitle();

//set known scale for image
run("Set Scale...", "distance=2.5 known=1 pixel=1 unit=µm global");

run("Subtract Background...", "rolling=30 disable");

//duplicate image for Overlay
run("Duplicate...", " ");
Selection_Overlay = getImageID();
selectImage(Selection_Overlay);
rename(plain_title[imagenumber] + "-Selection_Overlay");

selectWindow(plain_title[imagenumber]);

/* count nuclei
 * background subtraction, contrast enhancement 
 */
run("Enhance Contrast...", "saturated=0.3 normalize");
run("Gaussian Blur...", "sigma=0.5 scaled");

setAutoThreshold("Yen dark");

//create selection & seperate nuclei
run("Convert to Mask");
run("Watershed");

// analyze particles, limited by size, added to roi manager
run("Analyze Particles...", "size=10-200 display clear include summarize add in_situ");

// add nuclei to overlay image
selectWindow(plain_title[imagenumber]+"-Selection_Overlay");
roiManager("Show All without labels");
run("Flatten");
saveAs("Jpeg", nucleiDir + plain_title[imagenumber] + "-Overlay.jpg");
roiManager("Delete");
selectWindow(plain_title[imagenumber]+"-Selection_Overlay");
run("Close");

//save detailed results of nuclei
selectWindow("Results");
saveAs("Text", nucleiDir + plain_title[imagenumber] + "_nuclei details.xls");

//save results in arrays for later export
selectWindow("Summary");
IJ.renameResults("Results");
      nuclei_count[imagenumber] = getResult("Count",0);

imagenumber= imagenumber + 1;
} //end process for the active image
run("Close All");
} //end process of all images

run("Clear Results");

//Read out values of arrays into Results-Table
for (result_output=0; result_output<tif_list_length; result_output++) {

setResult("Image", result_output, plain_title[result_output]); 
setResult("Nuclei count", result_output, nuclei_count[result_output]); 
}

//save Summary table
selectWindow("Results");
saveAs("Text", nucleiDir + "Summary.xls");

// close all windows & check for "special" windows
run("Close All");

// indicate end of macro processing in the log file by a text   
print("Macro is finished");
