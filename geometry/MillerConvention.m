classdef MillerConvention < int32
% class representing the different Miller conventions  
  
  enumeration
    hkil         (-2)
    hkl          (-1)
    xyz          (0)
    uvw          (1) 
    UVTW         (2)
  end
  
  methods
    
    function out = isReciprocal(this)
      
      out = this < 0;
      
    end
    
    function [left,right] = brackets(this)
      
      if this > 0

        left= '['; right = ']';

      elseif this < 0

        left= '('; right= ')';

      else
        
        left = ''; right= '';
      
      end
    end
  end  
end