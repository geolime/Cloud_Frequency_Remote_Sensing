# Cloud Data Preparation: 

# 1. Download MOD13Q1 data at https://earthexplorer.usgs.gov/
# 2. Use the MODIS reprojection tool (https://lpdaac.usgs.gov/tools/modis_reprojection_tool) to convert MODIS hdf data into Geotiff.
# 3. Create a folder for the Pixel Reliability files,
# e.g. C:/Data_Pixel_Reliability.
# 4. In both folders for each day of the year (DOY) create one subfolder. The name of each folder must start with "DOY_", e.g. DOY_033.
# 5. Rename the files by addding a prefix following the pattern DOY_YYYY_, e.g. 033_2001 or 001_2005. 
# Total Commander is a useful tool to rename multiple files. (Download Link: http://www.ghisler.com/index.htm)
# Renaming the files is important to automatize the filenames and the titles of the resulting maps.
# 6. Store the shapefile with the country border in a seperate folder.


library(sp)
library(raster)
library(rgdal)

path <- "C:/Pixel_Reliability" # Enter link to the folder where you have stored the MODIS Pixel Reliability data.
dlist <- dir(path,pattern="DOY")

country <- shapefile("C:/Pixel_Reliability/GTM_adm0.shp") # Enter country shape path.

path_jpg <- "C:/Cloud_Frequency_jpg" # Enter the link to the folder where you want to store the resulting .jpg-images.
path_tif <- "C:/Cloud_Frequency_tif" # Enter the link to the folder where you want to store the resulting .tif-files.


for (i in 1:length(dlist)) {
  fold <- paste(path,dlist[i],sep="/")
  fls <- dir(fold,pattern=".tif")
  flsp <-paste(fold,fls,sep="/")

  cloudstack <- stack(flsp) 

  reclass <- reclassify(cloudstack, matrix(c(-Inf, 2, 0,  3, 3, 1,  4, Inf, 0), ncol=3, byrow=TRUE))
  sum_all <- sum(reclass)
  
  crop_sum <- crop(sum_all, country) 
  cloud_frequency <- mask(crop_sum, country)

  fold_jpg <- paste(path_jpg) 
  fold_tif <- paste(path_tif)

  for (k in 1:nlayers(cloud_frequency)) { 

    doy <- substr(fls[k],1,3) 
    
    jpeg(filename=paste(fold_jpg,"/","Cloud_Frequency_",doy,".jpg",sep=""), quality = 100)
    
    plot(cloud_frequency[[k]],zlim=c(0,100),main=paste("Cloud Frequency"," ","Country_Name"," ",doy,sep="")) # To Do: Change Country_Name to the Country or Area of Interest
    
    dev.off()
    
    writeRaster(cloud_frequency[[k]], filename=paste(fold_tif,"/","Cloud_Frequency_",doy,".tif",sep=""), format="GTiff", overwrite=TRUE)
  }
}