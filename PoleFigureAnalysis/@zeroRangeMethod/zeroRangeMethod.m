classdef zeroRangeMethod < handle
% calculate zero range
%
% Input
%  pf  - @PoleFigure
%  psi - @kernel
%  threshold  - double
%  delta - double
%  bg  - double
%  alpha - double
  
  properties
    pf
    psi 
    threshold
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