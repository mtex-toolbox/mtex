classdef uniformComponent < ODFComponent
    
  properties
    CS = crystalSymmetry;  % crystal symmetry
    SS = specimenSymmetry; % specimen symmetry
  end
  
  methods
    function odf = uniformComponent(cs,ss,varargin)      
      odf.CS = cs;
      odf.SS = ss;
    end
  end
    
end
