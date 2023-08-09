classdef SO3FunSBF < SO3Fun
% Deformation texture specified by strain and slipsystems
%
% References
%
% * <https://doi.org/10.1093/gji/ggy442 An analytical finite-strain
% parametrization for texture evolution in deforming olivine polycrystals>,
% Geoph. J. Intern. 216, 2019.
% 
% See also
%

  properties
    sS = slipSystem  % slip system
    E  = tensor      % strain tensor
    antipodal = false
    SLeft = specimenSymmetry
  end
  
  properties (Dependent = true)
    SRight    % crystal symmetry
    bandwidth % harmonic degree (always inf)
  end
 
  methods
    
    function SO3F = SO3FunSBF(sS,E)
                      
      if nargin == 0, return;end
      
      % get slip system
      SO3F.sS = sS;
      SO3F.E = E;
            
    end
    
    function SO3F = set.SRight(SO3F,CS)
      SO3F.sS.CS = CS;
    end
    
    function CS = get.SRight(SO3F)
      CS = SO3F.sS.CS;      
    end

  end

  methods (Static = true)
  
    [SO3F1,SO3F2,SO3F3] = example(varargin)
    
  end

end

% Testing Code
% cs = crystalSymmetry('222');
% sS = slipSystem(Miller(1,0,0,cs,'uvw'),Miller(0,1,0,cs,'hkl'))
% sS1 = slipSystem(Miller(0,1,0,cs,'uvw'),Miller(1,0,0,cs,'hkl'))
% sS2 = slipSystem(Miller(0,0,1,cs,'uvw'),Miller(1,0,0,cs,'hkl'))
% sS3 = slipSystem(Miller(0,1,0,cs,'uvw'),Miller(0,0,1,cs,'hkl'))
% odf1 = ODF(strainComponent(sS1),1)
% odf2 = ODF(strainComponent(sS2),1)
% odf3 = ODF(strainComponent(sS3),1)