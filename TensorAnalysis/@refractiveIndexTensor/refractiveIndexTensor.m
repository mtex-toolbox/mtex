classdef refractiveIndexTensor < tensor
% class representing the optical refractive index tensor
%
% The rank 2 refractive index tensor describes how light of a given
% propagation direction is slowed down by the crystal. Its anisotropy is
% what makes a crystal birefringent, and is the basis of the simulated
% thin section colours computed by spectralTransmission.
%
% Syntax
%   rI = refractiveIndexTensor(M,cs)
%
% Input
%  M  - 3x3 matrix
%  cs - crystal @symmetry
%
% Output
%  rI - @refractiveIndexTensor
%
% Class Properties
%  M    - the tensor coefficients
%  rank - always 2
%  CS   - @symmetry the coefficients refer to
%
% Example
%
%   rI = refractiveIndexTensor.calcite
%
% See also
% tensor
%


  methods
    
    
    function rI = refractiveIndexTensor(varargin)
      rI = rI@tensor(varargin{:},'rank',2);
      
      % TODO: set up the unit correctly !!!
      
    end
    
    
  end
  
  
  methods (Static = true)
    function rI = calcite
      cs = crystalSymmetry('-3m1',[5,5,17],'mineral','Calcite','X||a');
      rI = refractiveIndexTensor(diag([1.66 1.66 1.486]),cs);
    end
    
    function rI = olivin
      cs = loadCIF('olivin.cif');
      rI = refractiveIndexTensor(diag([1.640 1.660 1.680]),cs);
    end
    
    function test
      rI = refractiveIndexTensor.calcite;
      
      vprop = plotS2Grid;
      
      figure(1)
      n = rI.birefringence(vprop);
      
      plot3d(vprop,n)
      
      figure(2)
      thickness = 10000;
      rgb = spectralTransmission(rI,vprop,thickness);
      plot3d(vprop,rgb./100)
      
    end
    
    function test2
      mtexdata fo
      
      rI = refractiveIndexTensor.olivin;
      
      oM = spectralTransmissionColorKey(rI,1000);
      oM.polarizer = vector3d.Y;
      
      plot(ebsd('fo'),oM.orientation2color(ebsd('fo').orientations)./100)
      
    end
    
    
  end

end