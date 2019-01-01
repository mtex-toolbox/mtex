classdef S2Fun
% a class represeneting a function on the sphere
   
  methods

  end    

  
  methods (Abstract = true)
    
    f = eval(sF,v,varargin)
    
  end
  
  methods (Static = true)
  
    S2F = smiley(varargin)
    
  end

end
