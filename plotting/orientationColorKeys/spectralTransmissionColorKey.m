classdef spectralTransmissionColorKey < orientationColorKey

  properties
    rI                      % refractiveIndexTensor
    thickness               % thickness of the sample
    propagationDirection = vector3d.Z;     % propagation direction in specimen coordinates
    polarizer = vector3d.X; % direction of the polarizer in specimen coordinates
    phi = 90*degree;        % angle between polarizer and analyzer
  end

  
  methods
    function oM = spectralTransmissionColorKey(rI,thickness,varargin)

      oM.rI = rI;
      oM.CS1 = rI.CS;
      oM.thickness = thickness;

    end
    
    function rgb = orientation2color(oM,ori,varargin)
      
      % compute propagation direction in crystal coordinates
      propCS = inv(ori) .* oM.propagationDirection;

      % compute spectral transmission
      if isempty(oM.polarizer) %  circular polarisation
        
        rgb = spectralTransmission(oM.rI,propCS,oM.thickness,'phi',oM.phi);
      
      else
        
        % compute polarization direction in crystal coordinates
        pCS = (inv(ori) .* oM.polarizer);
        
        rgb = spectralTransmission(oM.rI,propCS,oM.thickness,'polarizationDirection',pCS,'phi',oM.phi);
      
      end
    end
    
  end
  
end
