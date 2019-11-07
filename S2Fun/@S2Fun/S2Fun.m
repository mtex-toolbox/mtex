classdef S2Fun
% an abstract class representing functions on the sphere
%
% 
   
  methods

  end    

  
  methods (Abstract = true)
    
    f = eval(sF,v,varargin)
    
  end
  
  methods (Static = true)
  
    s2F = smiley(varargin)
    s2F = unimodal(v,varargin)
    
  end

end
