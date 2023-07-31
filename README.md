# CorrectRGB_BrightFieldImages
ImageJ macro for the correction of RGB bright field images. Extra options for background subtraction and upload to an Omero server

<html>
  <h1><u>Help page for RGB images correction and Calibration Macro</u></h1>
  <font>
  <br>
    <b>Requirements / Dependencies</b><br>The macro requires the Omero macro extensions from the following address:<br>
    <a href="https://github.com/GReD-Clermont/omero_macro-extensions">https://github.com/GReD-Clermont/omero_macro-extensions</a>
<br><br><br>
<b>Parameters</b>
<br><br>
<b>Saving Folder:</b> The name of the folder where the corrected images will be saved. The location of this folder is inside the source folder. Even if the omero upload option is selected, the resulting images will be saved locally.<br>
<b>Crop Images:</b> If the user wants to reduce the size of images, there is the option of cropping the images (manual)<br
<b>Remove Background:</b> The subtract background plugin is used (rolling ball of 250px expecting light background). This can be a slow process depending on the image size<br>
<b>Correct White Balance:</b> If this option is selected (default), then the macro will correct the white balance, based on the region of interest selected (see next parameter)<br>
<b>Correction Region:</b> For the correction of RGB images a region of interest is required. The user can manually select this region (usually sample free), or the macro can select a region of 400x400 px from the corners or the center of the image<br>
<b>OMERO Upload:</b> If selected, a new window will ask further questions for the login information. Resulted images will also be saved locally<br>
<b>Omero Server Address:</b> The default address for the Omero of the Multiscale Imaging Platform. Change this for uploading on a different server<br>
<b>Omero Server Port:</b> The default port for the Omero of the Multiscale Imaging Platform. Change this for uploading on a different server<br>

<br>
<b>Username:</b> The username used for Omero login<br>
<b>Password:</b> The password used for Omero login<br>
<b>Change Default group:</b> For users belonging in more than one group. The <u>group ID number</u> on the omero server is required. In case this is not known, ask your Omero server administrator<br>
<b>Work as:</b> ... a different user. This is possible only for admin accounts. The <u>accurate user name</u> is required. In case this is not known, ask your Omero server administrator<br>
<b>Create new Project for upload:</b> This is the name of the new project on Omero, that will be used for the upload of the new data<br>
<b>Create new Dataset for upload:</b> This is the name of the new Dataset on Omero, that will be used for the upload of the new data<br>
</font>
