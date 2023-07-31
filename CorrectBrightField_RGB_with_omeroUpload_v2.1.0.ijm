/*****************************************************************************
 *  Author Dr. Ioannis Alexopoulos
 * The author of the macro reserve the copyrights of the original macro.
 * However, you are welcome to distribute, modify and use the program under 
 * the terms of the GNU General Public License as stated here: 
 * (http://www.gnu.org/licenses/gpl.txt) as long as you attribute proper 
 * acknowledgement to the author as mentioned above.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *****************************************************************************
 * Short Help 
 */
 html = "<html><h1><u>Help page for RGB images correction and Calibration Macro</u></h1><font><br><b>Requirements / Dependencies</b><br>The macro requires the Omero macro extensions from the following address:<br>"
 	 +"<a href=\"https://github.com/GReD-Clermont/omero_macro-extensions\">https://github.com/GReD-Clermont/omero_macro-extensions</a><<br>"
     
     +"<br><b>Parameters</b><br><font color=red>Saving Folder:</font> The name of the folder where the corrected images will be saved. The location of this folder is inside the source folder. Even if the omero upload option is selected, the resulting images will be saved locally.<br>"
     +"<font color=red>Crop Images:</font> If the user wants to reduce the size of images, there is the option of cropping the images (manual)<br><font color=red>Remove Background:</font> The subtract background plugin is used (rolling ball of 250px expecting light background). "
     +"This can be a slow process depending on the image size<br><font color=red>Correct White Balance:</font> If this option is selected (default), then the macro will correct the white balance, based on the region of interest selected (see next parameter)<br>"
     +"<font color=red>Correction Region:</font> For the correction of RGB images a region of interest is required. The user can manually select this region (usually sample free), or the macro can select a region of 400x400 px from the corners or the center of the image<br>"
     +"<font color=red>OMERO Upload:</font> If selected, a new window will ask further questions for the login information. Resulted images will also be saved locally<br><font color=red>Omero Server Address:</font> The default address for the Omero of the Multiscale Imaging Platform. Change this for uploading on a different server<br>"
     +"<font color=red>Omero Server Port:</font> The default port for the Omero of the Multiscale Imaging Platform. Change this for uploading on a different server<br></font>";
html2 = "<html><h1><u>Help page for RGB images correction and Calibration Macro</u></h1><font><br><b>Requirements / Dependencies</b><br>The macro requires the Omero macro extensions from the following address:<br><a href=\"https://github.com/GReD-Clermont/omero_macro-extensions/releases/tag/1.3.2/\">https://github.com/GReD-Clermont/omero_macro-extensions/releases/tag/1.3.2/</a><<br>"
     +"<br><b>Parameters</b><br><font color=red>Username:</font> The username used for Omero login<br><font color=red>Password:</font> The password used for Omero login<br><font color=red>Change Default group:</font> For users belonging in more than one group. The <u>group ID number</u> on the omero server is required."
     +"In case this is not known, ask your Omero server administrator<br><font color=red>Work as:</font> ... a different user. This is possible only for admin accounts. The <u>accurate user name</u> is required. In case this is not known, ask your Omero server administrator<br>"
     +"<font color=red>Create new Project for upload:</font> This is the name of the new project on Omero, that will be used for the upload of the new data<br><font color=red>Create new Dataset for upload:</font> This is the name of the new Dataset on Omero, that will be used for the upload of the new data<br>"
     +"</font>";
     
run("OMERO Extensions");
// Create dialog, create save folders, and select file(s) to process
AreaSelection=newArray("Manual","Center", "Top Left Corner", "Middle Left Side");

Dialog.create("Correct and calibrate RGB Images");
Dialog.addMessage("Parameters");
Dialog.addString("Name of saving folder: ", "_Corrected", 40);
Dialog.addCheckbox("Crop Images?", false);
Dialog.addCheckbox("Remove Background? (Can take time)", false);
Dialog.addCheckbox("Correct White Balance?", true);
Dialog.addChoice("Correction Region", AreaSelection);
Dialog.addCheckbox("Upload to OMERO", false);
Dialog.addString("Omero Server Address: ", "wss://omero.innere.fb11.uni-giessen.de/omero-ws", 50);
Dialog.addNumber("Omero Server Port: ", 443);
Dialog.addHelp(html);
Dialog.show();

// Variables of Dialog
save_folder=Dialog.getString();
crop=Dialog.getCheckbox();
background=Dialog.getCheckbox();
white_balance=Dialog.getCheckbox();
area_Select=Dialog.getChoice();
omero_upload=Dialog.getCheckbox();
omero_adr=Dialog.getString();
omero_port=Dialog.getNumber();

if(omero_upload){
	Dialog.create("Omero Connection Information");
	Dialog.addString("Omero Username ", "", 10);
	Dialog.addString("Omero Password", "-", 1);
	Dialog.addString("Change Default group to (Group ID needed): ", "----");
	Dialog.addString("Work as (only for admin accounts)", "----");
	Dialog.addString("Create new Project for upload ", "");
	Dialog.addString("Create new Dataset for upload ", "");
	Dialog.addHelp(html2);
	Dialog.show();
	username=Dialog.getString();
	password=Dialog.getString();
	OME_group_key=Dialog.getString();
	work_as_user=Dialog.getString();
	newProject=Dialog.getString();
	newDataset=Dialog.getString();
	
	if(work_as_user == "" || work_as_user==" " || work_as_user=="  "){
		work_as_user="----";
	}
	succes_connection=Ext.connectToOMERO(omero_adr, omero_port, username, password);
	if (succes_connection){
		if(OME_group_key!="----"){
			chgrp=Ext.switchGroup(OME_group_key);
		}
		
		if(work_as_user!="----" && work_as_user != username){
			sudo=Ext.sudo(work_as_user);
		}
		FoundProject=FoundDataset=false;
		projectIds=split(Ext.list("Project"),",");
		for(m=0;m<projectIds.length;m++){
			projectName=Ext.getName("Project", projectIds[m]);
			if (projectName == newProject){
				FoundProject=true;
				FoundProjectId=projectIds[m];
			}
		}
		if(!FoundProject){
			newProjectID=Ext.createProject(newProject, "");
		}else{
			print ("Project named \""+newProject+"\" already exists and will be used.");
			newProjectID=FoundProjectId;
		}
		
		datasetIds=split(Ext.list("Dataset", "Project", newProjectID), ",");
		for(p=0;p<datasetIds.length;p++){
			datasetName=Ext.getName("Dataset", datasetIds[p]);
			if (datasetName == newDataset){
				FoundDataset=true;
				FoundDatasetId=datasetIds[p];
			}
		}
		if(!FoundDataset){
			newDatasetID=Ext.createDataset(newDataset, "", newProjectID);
		}else{
			print ("Dataset named \""+newDataset+"\" inside the project named \""+newProject+"\" already exists and cannot be used.");
			print ("A new dataset named \""+newDataset+"_new\" inside the project named \""+newProject+"\" will be generated.");
			newDataset=newDataset+"_new";
			newDatasetID=Ext.createDataset(newDataset, "", newProjectID);
		}
		
	}else{
		exit("Macro aborted. The connection to OMERO server was not successful.");
	}
}
sep = File.separator;
	SourceDir = getDirectory("Choose source directory");
	Filelist=getFileList(SourceDir);
	SAVE_DIR=SourceDir;
	save_folder_name_add=File.getName(SourceDir);
	SERIES_2_OPEN=newArray(1);
	SERIES_2_OPEN[0]=1;
	
save_folder=save_folder+"_"+save_folder_name_add;
tmp=newArray();
for(k=0;k<Filelist.length;k++)
{
	if (!File.isDirectory(SourceDir+"/"+Filelist[k]))
	{
		tmp = Array.concat(tmp,Filelist[k]); 
	}
}
Filelist=tmp;
new_folder=SAVE_DIR + sep + save_folder;
File.makeDirectory(new_folder);
run("Input/Output...", "jpeg=85 gif=-1 file=.xls copy_row save_column save_row");

if((area_Select != "Manual" && crop == false) || white_balance==false){
	setBatchMode(true);
}

for (k=0;k<Filelist.length;k++)
{
	if(!endsWith(Filelist[k], sep) && (endsWith(Filelist[k], ".tif")||endsWith(Filelist[k], ".tiff")||endsWith(Filelist[k], ".TIF")||endsWith(Filelist[k], ".TIFF")||endsWith(Filelist[k], ".jpg")||endsWith(Filelist[k], ".JPG")||endsWith(Filelist[k], ".jpeg")||endsWith(Filelist[k], ".JPEG")))
	{
		run("Bio-Formats Macro Extensions");
		Ext.setId(SourceDir+sep+Filelist[k]);
		Ext.getSeriesCount(SERIES_COUNT);
		FILE_PATH=SourceDir + sep + Filelist[k];
		for (i=0;i<SERIES_COUNT; i++) 
		{
		 if(SERIES_2_OPEN[i]==1){
			options="open=["+ FILE_PATH + "] " + "color_mode=Default view=Hyperstack stack_order=XYCZT " + "series_"+d2s(i+1,0) + "";
			run("Bio-Formats Importer", options);
			FILE_NAME=File.nameWithoutExtension;
			Ext.setSeries(i);
			Ext.getSeriesName(SERIES_NAMES2);
			SERIES_NAMES2=replace(SERIES_NAMES2, " ", "_");
			SERIES_NAMES2=replace(SERIES_NAMES2, "/", "_");
			SERIES_NAMES2=replace(SERIES_NAMES2, "\\(", "");
			SERIES_NAMES2=replace(SERIES_NAMES2, "\\)", "_");
			SERIES_NAMES2=replace(SERIES_NAMES2, "\\+", "-");
			SERIES_NAMES2=replace(SERIES_NAMES2, "\\#", "");
			
			FILE_NAME=replace(FILE_NAME, " ", "_");
			FILE_NAME=replace(FILE_NAME, "/", "_");
			FILE_NAME=replace(FILE_NAME, "\\(", "");
			FILE_NAME=replace(FILE_NAME, "\\)", "_");
			FILE_NAME=replace(FILE_NAME, "\\+", "-");
			FILE_NAME=replace(FILE_NAME, "\\#", "");
			rename(FILE_NAME);
			SAVE_NAME=SERIES_NAMES2;
			name=getTitle();
			if(crop){
				waitForUser("Select the cropping area and then press OK");
				run("Crop");
			}
			getDimensions(width, height, channels, slices, frames);
			if(white_balance)
			{
				if(area_Select == "Manual"){
					waitForUser("Draw a region over an empty area and then press OK");
				}else if(area_Select == "Center"){
					makeRectangle(width/4, height/4, 2*(width/5), 2*(height/5));
				}else if(area_Select == "Top Left Corner"){
					makeRectangle(50, 50, 450, 450);
				}else if(area_Select == "Middle Left Side"){
					makeRectangle(50, height/2, 450, 450);
				}
				roiManager("add");
				run("Make Composite");
				run("Split Channels");
				MeanColor=newArray(3);
				maxi = 0;
				for (u=1; u<4; u++) {
				selectWindow("C"+u+"-"+name);
				roiManager("select", 0);
				getStatistics(area, mean);
				MeanColor[u-1] = mean;
				if (mean>=maxi) maxi = mean;
				}
				
				for (u=1; u<4; u++) {
				selectWindow("C"+u+"-"+name);
				run("Select None");
				run("Multiply...", "value="+maxi/MeanColor[u-1]+" slice");
				}
				run("Merge Channels...", "c1=C1-"+name+" c2=C2-"+name+" c3=C3-"+name+" create");
				run("RGB Color");
			}
			if(background){
				run("Subtract Background...", "rolling=250 light");
			}
			rename(name);
			if(omero_upload){
				run("OMERO Extensions");
				succes_connection=Ext.connectToOMERO(omero_adr, omero_port, username, password);
				if(OME_group_key!="----"){
					chgrp=Ext.switchGroup(OME_group_key);
				}
		
				if(work_as_user!="----" && work_as_user != username){
					sudo=Ext.sudo(work_as_user);
				}
				newImageID=Ext.importImage(newDatasetID);
				if(work_as_user!="----" && work_as_user != username){
					Ext.endSudo();
				}
				Ext.disconnect();
				saveAs(".tif", new_folder+sep+name);
			}else{
				saveAs(".tif", new_folder+sep+name);
			}
			roiManager("reset");
			run("Close All");
		 }
		}
	}
}
setBatchMode(false);
showMessage("Macro Finished!\n\nYou can inspect your results either locally or on Omero.");
