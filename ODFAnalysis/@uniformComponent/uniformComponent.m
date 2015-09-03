classdef uniformComponent < ODFComponent
    
  properties
    CS = crystalSymmetry;  % crystal symmetry
    SS = specimenSymmetry; % specimen symmetry
    antipodal    
  end
    
  methods
    function odf = uniformComponent(cs,ss,varargin)      
      odf.CS = cs;
      odf.SS = ss;
      odf.antipodal = check_option(varargin,'antipodal');
    end
  end
    
end
