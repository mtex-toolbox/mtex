classdef spectralTransmissionColorKey < orientationColorKey
  % computes the thin section color of an anisotropic crystal
  %
  % Simulates a polarization microscope: light of the given propagation
  % direction passes polarizer, crystal and analyzer, and the transmitted
  % spectrum is converted to RGB. That makes the color a function of the
  % orientation, the sample thickness and the optical setup.
  %
  % Syntax
  %   oM = spectralTransmissionColorKey(rI,thickness)
  %   oM.propagationDirection = vector3d.Z;
  %   rgb = oM.orientation2color(ori)
  %
  % Input
  %  rI        - @refractiveIndexTensor
  %  thickness - thickness of the sample in nm
  %  ori       - @orientation
  %
  % Output
  %  oM  - @spectralTransmissionColorKey
  %  rgb - list of RGB triplets
  %
  % Class Properties
  %  rI                   - @refractiveIndexTensor
  %  thickness            - thickness of the sample
  %  propagationDirection - @vector3d, direction of the light
  %  polarizer            - @vector3d, direction of the polarizer
  %  phi                  - angle between polarizer and analyzer
  %
  % Example
  %
  %   rI = refractiveIndexTensor.calcite;
  %   oM = spectralTransmissionColorKey(rI,30000)
  %
  % See also
  % orientationColorKey refractiveIndexTensor tensor/spectralTransmission
  %

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
    
    function [props,propV] = keyRows(oM)
      % the optical setup the transmission color is computed for

      props = {'thickness'}; propV = {xnum2str(oM.thickness)};

      props{end+1} = 'propagation';
      propV{end+1} = ['(' strtrim(char(oM.propagationDirection)) ')'];

      props{end+1} = 'polarizer';
      propV{end+1} = ['(' strtrim(char(oM.polarizer)) ')'];

      props{end+1} = 'polarizer to analyzer';
      propV{end+1} = [xnum2str(oM.phi/degree) '°'];

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
