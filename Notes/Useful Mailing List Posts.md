# Useful Posts to the Micro-Manager Mailing List

## Scripting

### [Program to capture an image from microscope using java (netbeans)](https://sourceforge.net/p/micro-manager/mailman/micro-manager-general/thread/12C646D192C30E43ADDFA7C6B4FD8A35EEE844E3%40ECS-EX10-MB2.ad.engr.uconn.edu/#msg34384917)

+ **Original Poster** : Bahareh Mahrou
+ **Date** : 2015-08-18

OP wanted help programmatically snapping and saving a single image to disk. C.
Weisiger provided the following script:

```java
// Location to save data to.
String path = "/Users/chriswei/AcquisitionData";

String acqName = gui.getUniqueAcquisitionName("snapTest");
// Create an acquisition to hold the snapped image.
// 1 frame/channel/slice/position, do show, do save to disk.
gui.openAcquisition(acqName, path, 1, 1, 1, 1, true, true);
// Collect an image from the camera and add it to the acquisition.
gui.snapAndAddImage(acqName, 0, 0, 0, 0);
// Save the acquisition to disk.
gui.closeAcquisition(acqName);
```

## High Speed Acquisitions

### [startSequenceAcquisition Circular Buffer MATLAB](https://sourceforge.net/p/micro-manager/mailman/micro-manager-general/thread/1425063070748-7584815.post@n2.nabble.com/)

+ **Original Poster** : Eugene Cai
+ **Date** : 2015-02-25

The OP asked how to programmatically initiate a high speed acquisition and
process the images as they arrived in the cache.


