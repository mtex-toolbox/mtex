classdef uniformComponent < ODFComponent
    
  properties
    CS = crystalSymmetry;  % crystal symmetry
    SS = specimenSymmetry; % specimen symmetry
    antipodal    
    bandwidth              % harmonic degree - always 0
  end
    
  methods
    function odf = uniformComponent(cs,ss,varargin)      
      odf.CS = cs;
      odf.SS = ss;
      odf.antipodal = check_option(varargin,'antipodal');
    end
    
    function L = get.bandwidth(component) %#ok<MANU>
      L = 0;
    end
    
    function component = set.bandwidth(component,~)      
    end
  end
    
end
