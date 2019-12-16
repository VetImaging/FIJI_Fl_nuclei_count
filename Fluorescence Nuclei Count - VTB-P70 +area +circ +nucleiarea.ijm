/* Macro for counting nuclei on 8bit-TIFs  - SK 2019-09 VTB
 *  3D-Histech scans, converted with caseconverter to 1:2 tiled Tifs / jpg compression 85 / grayscale
 */

setForegroundColor(0, 0, 255);

//clear the log
print("\\Clear");

// clear previous results
run("Clear Results");

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
     }}



//define array-variables
plain_title=newArray(tif_list_length+1);
total_area=newArray(tif_list_length+1);

nuclei_count=newArray(tif_list_length+1);
nuclei_area=newArray(tif_list_length+1);
nuclei_avsize=newArray(tif_list_length+1);
nuclei_circularity=newArray(tif_list_length+1);
nuclei_solidity=newArray(tif_list_length+1);



imagenumber=0;
//take one after another image and process
for (filenumber=0; filenumber<list.length; filenumber++) {
     if (endsWith(list[filenumber], ".tif")){
        run("Bio-Formats Windowless Importer", "open=["+dir+list[filenumber]+"]");


//get title of image and rename for results list
plain_title[imagenumber] = getTitle();
plain_title[imagenumber] = replace(plain_title[imagenumber], "\\-ZERO_Extended.tif", "");
rename(plain_title[imagenumber]);
//rename(replace(getTitle(), "\\-ZERO_Extended.tif", "")); //short rename
imageTitle = getTitle();



//set known scale for image
run("Set Scale...", "distance=2.5 known=1 pixel=1 unit=µm global");

run("Subtract Background...", "rolling=30 disable");

//duplicate image for Overlay
run("Duplicate...", " ");
Selection_Overlay = getImageID();
selectImage(Selection_Overlay);
rename(plain_title[imagenumber] + "-Selection_Overlay");

/* Total Area Calculation
 * duplicate image & Measure Total Area by extremely increasing contrast of extremely blurred image
 */
run("Duplicate...", " ");
Image_for_totalarea = getImageID();
selectImage(Image_for_totalarea);
rename(plain_title[imagenumber] + "-total-area");

run("Enhance Contrast...", "saturated=80 normalize");
run("Gaussian Blur...", "sigma=5 scaled");
run("Enhance Contrast...", "saturated=60 normalize");
run("Gaussian Blur...", "sigma=5 scaled");
setAutoThreshold("Minimum dark");
run("Clear Results");
run("Measure");

total_area[imagenumber]=getResult("Area",0);
run("Create Selection");

//smooth selection and add to ROI manager
run("Enlarge...", "enlarge=-20");
wait(300);
run("Enlarge...", "enlarge=60");
wait(300);
run("Enlarge...", "enlarge=-40");
wait(300);
run("Add Selection...");
wait(300);
run("To ROI Manager");
wait(300);
//close Image for Total area measurement
selectImage(Image_for_totalarea);
run("Close");

// save overlay image and reset ROI manager
selectWindow(plain_title[imagenumber]+"-Selection_Overlay");
roiManager("Show All without labels");
run("Flatten");
saveAs("Jpeg", nucleiDir + plain_title[imagenumber] + "-Overlay.jpg");
roiManager("Delete");

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
      nuclei_area[imagenumber]=getResult("Total Area",0);
      nuclei_avsize[imagenumber]=getResult("Average Size",0);
      nuclei_circularity[imagenumber]=getResult("Circ.",0);
      nuclei_solidity[imagenumber]=getResult("Solidity",0);


// close unused images

if (isOpen(plain_title[imagenumber] + ".tif")) { 
selectWindow(plain_title[imagenumber]+ ".tif");
run("Close"); }

if (isOpen(plain_title[imagenumber] + "-Overlay.jpg")) { 
selectWindow(plain_title[imagenumber] + "-Overlay.jpg");
run("Close"); }


imagenumber= imagenumber + 1;
} //end process for the active image
run("Close All");
} //end process of all images

run("Clear Results");

//Read out values of arrays into Results-Table
for (result_output=0; result_output<tif_list_length; result_output++) {

setResult("Image", result_output, plain_title[result_output]); 
setResult("Nuclei count", result_output, nuclei_count[result_output]); 
setResult("Nuclei average size (µm²)", result_output, nuclei_avsize[result_output]); 
setResult("Total Area (µm²)", result_output, total_area[result_output]); 
setResult("Nuclei area (µm²)", result_output, nuclei_area[result_output]); 
setResult("Nuclei circularity", result_output, nuclei_circularity[result_output]);
setResult("Nuclei solidity", result_output, nuclei_solidity[result_output]);

}

//save Summary table
selectWindow("Results");
saveAs("Text", nucleiDir + "Summary.xls");

// close all windows & check for "special" windows
run("Close All");

if (isOpen("Results")) { 
       selectWindow("Results"); 
       run("Close"); 
   }
    
if (isOpen("Threshold")) { 
       selectWindow("Threshold"); 
       run("Close"); 
   } 
 
if (isOpen("ROI Manager")) { 
       selectWindow("ROI Manager"); 
       run("Close"); 
   }    

// indicate end of macro processing in the log file by a text   
print("Macro is finished");