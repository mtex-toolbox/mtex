classdef spectralTransmissionOrientationMapping < orientationMapping

  properties
    rI                      % refractiveIndexTensor
    thickness               % thickness of the sample
    vprop = vector3d.Z;     % propagation direction in specimen coordinates
    polarizer = vector3d.X; % direction of the polarizer in specimen coordinates
    tau = 45*degree;        % angle between polarizer and analyzer
  end

  
  methods
    function oM = spectralTransmissionOrientationMapping(rI,thickness)

      oM.rI = rI;
      oM.CS1 = rI.CS;
      oM.thickness = thickness;

    end
    
    function rgb = orientation2color(oM,ori)
      
      % compute propagation sdirection in crystal coordinates
      propCS = inv(ori) .* oM.vprop;
      
      % compute polarization direction in crystal coordinates
      pCS = inv(ori) .* oM.polarizer;
      
      % compute spectral transmission
      rgb = spectralTransmission(oM.rI,propCS,oM.thickness,'polarizationDirection',pCS,'tau',oM.tau);
      
    end
    
  end
  
end
