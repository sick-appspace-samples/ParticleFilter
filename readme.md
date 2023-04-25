## ParticleFilter

Applying particle filter on scans read from a file

### Description

This sample acquires scans and searches a segment of that scan for a minimum
vertical distance assuming the scanner looks downwards vertically.
The minimum distance found is printed to the console and sent via TCP/IP.
The scan viewer will also show the scans to verify the result.
Scan data from file in resources is retrieved and filtered with the particle filter. The original scan and the filtered scan are compared and
changes between both scans are printed to illustrate the operation of the
particle filter. The resulting filtered version of the scan is then transformed into a point cloud and sent to the
viewer.

### How To Run

Starting this sample is possible either by running the app (F5) or
debugging (F7+F10). Output is printed to the console and the transformed
point cloud can be seen on the viewer in the web page. The playback stops
after the last scan in the file. To replay, the sample must be restarted.
To run this sample, a device with AppEngine >= 2.5.0 is required.

### Implementation

To run with real device data, the file provider has to be exchanged with the
appropriate scan provider.

### Topics

algorithm, scan, filtering, sample, sick-appspace
