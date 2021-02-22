--[[----------------------------------------------------------------------------

  Application Name: 
  ParticleFilter
    
  Summary:
  Applying particle filter on scans read from a file                                                                                                                    
                                                                                             
  Description: 
  Scan data from file in resources is retrieved and filtered with the particle
  filter. The filtered scan is transformed into a point cloud and sent to the
  viewer. Additionally the original scan and the filtered scan are compared and
  changes between both scans are printed to illustrate the operation of the 
  particle filter.
      
  How to run:
  Starting this sample is possible either by running the app (F5) or 
  debugging (F7+F10). Output is printed to the console and the transformed 
  point cloud can be seen on the viewer in the web page. The playback stops 
  after the last scan in the file. To replay, the sample must be restarted.
  To run this sample, a device with AppEngine >= 2.5.0 is required.
  
  Implementation: 
  To run with real device data, the file provider has to be exchanged with the 
  appropriate scan provider.
------------------------------------------------------------------------------]]

-- Variables global for all functions
local counter = 0

local SCAN_FILE_PATH = "resources/TestScenario.xml"
print("Input File: ", SCAN_FILE_PATH)

local currentScan = nil
local previousScan = nil

-- Check device capabilities
assert(View,"View not available, check capability of connected device")
assert(Scan,"Scan not available, check capability of connected device")
assert(Scan.ParticleFilter,"ParticleFilter not available, check capability of connected device")
assert(Scan.Transform,"Transform not available, check capability of connected device")

-- Create the filter
particleFilter = Scan.ParticleFilter.create()
assert(particleFilter, "ParticleFiler could not be created")
Scan.ParticleFilter.setThreshold(particleFilter,100.0) -- If the distance difference in distsances 
                                                       -- between of a point and its neighbours exceeds 
                                                       -- this threshold it is discarded as a particle
Scan.ParticleFilter.setEnabled(particleFilter,true)
  
-- Create a viewer instance
viewer = View.create()
assert(viewer, "View could not be created.")
viewer:setID("viewer3D")

-- Create a transform instance to convert the Scan to a PointCloud
transform = Scan.Transform.create()
assert(transform, "Transform could not be created.")

-- Create provider. Providing starts automatically with the register call
-- which is found below the callback function
provider = Scan.Provider.File.create()
assert(provider, "Scan file provider could not be created.")
-- Set the path
Scan.Provider.File.setFile(provider, SCAN_FILE_PATH)
-- Set the DataSet of the recorded data which should be used.
Scan.Provider.File.setDataSetID(provider, 1)

--End of Global Scope----------------------------------------------------------- 

--Start of Function and Event Scope---------------------------------------------

-------------------------------------------------------------------------------------------------------
-- Compares the distances of two scans of the specified echo
-------------------------------------------------------------------------------------------------------
local function compareScans(inputScan, filteredScan, iEcho, printDetails)
  
  -- get the beam and echo counts
  local beamCountInput = Scan.getBeamCount(inputScan)
  local echoCountInput = Scan.getEchoCount(inputScan)
  local beamCountFiltered = Scan.getBeamCount(filteredScan)
  local echoCountFiltered = Scan.getEchoCount(filteredScan)
  
  local particleCount = 0
  
  -- Checks
  if ( iEcho <= echoCountInput and iEcho <= echoCountFiltered ) then
    if ( beamCountInput == beamCountFiltered ) then
      -- Print beams with different distances
      if ( printDetails ) then
        print("Different beams after filtering of particles:")
      end
      -- Copy distance channel to Lua table. Note: Scan API indexes start with 0!
      local vDistance1 = Scan.toVector(inputScan, "DISTANCE", iEcho-1)
      local vDistance2 = Scan.toVector(filteredScan, "DISTANCE", iEcho-1)
      for iBeam=1, beamCountInput do
        -- Note: Lua index starts with 1.
        local d1 = vDistance1[iBeam]
        local d2 = vDistance2[iBeam]
        if ( math.abs(d1-d2) > 0.01 ) then
          if ( printDetails ) then
            print(string.format("  beam %4d:  %10.2f -->  %10.2f", iBeam, d1, d2))
          end
          particleCount = particleCount + 1
        end
      end
    end
  end
  return particleCount
end

-- Callback function to process new scans
function handleNewScan(scan)
  counter = counter+1
  print("Scan: ", counter, "  beams: ", Scan.getBeamCount(scan));
  
  -- Save current scan and
  previousScan = currentScan
  -- clone input scan
  currentScan = Scan.clone(scan)

  -- Filter scan
  local filteredScan = Scan.ParticleFilter.filter(particleFilter, scan)
  
  -- Note: Scan 1 and 2 are never returned since the filter needs a history of 2 scans.
  if ( nil ~= filteredScan ) then
    -- Transform to PointCloud to view in the PointCloud viewer on the webpage
    local pointCloud = Scan.Transform.transformToPointCloud(transform, filteredScan)
    View.add(viewer, pointCloud)
    View.present(viewer)
    -- Compare the filtered scan with the previous scan
    if ( nil ~= previousScan  ) then
      local particleCount = compareScans(previousScan, filteredScan, 1, true)
      if ( 0 == particleCount) then
        print("  All distances are equal. No particles found.")
      else
        print("  Particles found: ", particleCount)
      end
    end
  end
end
-- Register callback function to "OnNewScan" event. 
-- This call also starts the playback of scans
Scan.Provider.File.register(provider, "OnNewScan", "handleNewScan")