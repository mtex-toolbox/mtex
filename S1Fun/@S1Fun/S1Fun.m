classdef S1Fun
% an abstract class representing functions on the 1-sphere
%
% See also
% S1FunHarmonic

  properties (Abstract = true)
    antipodal 
    bandwidth % 
  end 

  properties 
    how2plot = plottingConvention.default
  end
  
  methods (Abstract = true)
    
    f = eval(sF,v,varargin)
    
  end

end
