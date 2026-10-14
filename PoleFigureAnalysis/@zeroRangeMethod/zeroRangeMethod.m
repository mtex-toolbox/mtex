classdef zeroRangeMethod < handle
% calculate zero range
%
% The zero range method finds the regions of the orientation space where the
% measured pole figures vanish, so that the pole figure inversion can set the
% ODF to zero there.
%
% Syntax
%
%   zrm = zeroRangeMethod(pf)          % the zero range of the pole figures pf
%   zrm = zeroRangeMethod(pf,psi)      % smooth the pole figures with the kernel psi
%   zrm = zeroRangeMethod(pf,'delta',0.01,'alpha',10)
%
%   % orientations in the zero range
%   isZero = checkZeroRange(zrm,ori)
%
% Input
%  pf  - @PoleFigure
%  psi - @S2Kernel, default a de la Vallee Poussin kernel of halfwidth twice the grid resolution
%
% Output
%  zrm - @zeroRangeMethod
%
% Options
%  halfwidth - halfwidth of the default kernel
%  maxAngle  - largest distance to a measurement direction inside the measured area, default the grid resolution
%  delta     - relative threshold, default 0.001
%  bg        - background intensity per pole figure, default delta times the maximum intensity
%  alpha     - weight of the intensities above the background, default 10
%
% See also
% zeroRangeMethod/checkZeroRange PoleFigure/calcODF
  
  properties
    pf
    psi 
    maxAngle
    delta = 0.001;
    bg
    alpha = 10;
  end

  properties (Access=private)
    density
    pdf
  end
  
methods
 
  function zrm = zeroRangeMethod(varargin)
    init(zrm,varargin{:});
  end
  
end

end