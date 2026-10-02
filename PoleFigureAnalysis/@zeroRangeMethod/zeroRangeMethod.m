classdef zeroRangeMethod < handle
% calculate zero range
%
% Input
%  pf  - @PoleFigure
%  psi - @S2Kernel
%  maxAngle - largest distance to a measurement direction inside the measured area, default the grid resolution
%  delta - double
%  bg  - double
%  alpha - double
  
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