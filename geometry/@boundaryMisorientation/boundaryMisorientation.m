classdef (InferiorClasses = {?rotation,?quaternion,?orientation}) boundaryMisorientation
% class representing 5d boundary misorientation
%
% A 5d boundary misorientation consists of
%
% * the misorientation describing the orientation relationship between two grains
% * the boundary normal 
%
% Syntax
%
%   boundaryMisorientation(ori1,ori2,N_specimen)
%   boundaryMisorientation(mori,N1)
%
% Input
%  mori - @orienation misorientation from grain 1 to grain 2
%  N1 - @Miller boundary normales with respect to grain 1
%  ori1, ori2 - crystal orientations of grain 1 and grain 2
%  N_specimen - @vector3d boundary normal in specimen coordinates
%

properties
  
  mori % misorientation from grain 1 to grain 2
  N1    % boundary normal with respect to grain 1
  
end

properties (Dependent = true)
  CS1 % crystal symmetry of grain 1
  CS2 % crystal symmetry of grain 2
  N2   % boundary normal with respect to grain 2
  antipodal % grain exchange symmetry
end

methods
  
  function bM = boundaryMisorientation(mori,N1,N_specimen)
    
    if nargin == 3
      bM.mori = inv(N1) .* mori;
      bM.N1 = inv(mori) .* N_specimen;
    else
      bM.mori = mori;
      bM.N1 = N1;
    end
  end
  
  function CS1 = get.CS1(bM)
    CS1 = bM.mori.CS1;
  end
  
  function CS2 = get.CS2(bM)
    CS2 = bM.mori.CS2;
  end
  
  function antipodal = get.antipodal(bM)
    antipodal = bM.mori.antipodal;
  end

  function N2 = get.N2(bM)
    N2 = -bM.mori .* bM.N1;
  end
  
  function bM = set.N2(bM,N2)
    bM.N1 = - inv(bM.mori) .* N2;
  end
end

end