classdef uniformComponent < ODFComponent
    
  properties
    CS = symmetry; % crystal symmetry
    SS = symmetry; % specimen symmetry
  end
  
  methods
    function odf = uniformComponent(cs,ss,varargin)      
      odf.CS = cs;
      odf.SS = ss;
    end
  end
    
end
