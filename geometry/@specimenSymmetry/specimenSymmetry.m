classdef specimenSymmetry < symmetry
% defines a specimen symmetry
% 
% usually specimen symmetry is either 
% triclinic or orthorhombic
%

properties
  plotOptions = {}
end

  methods
    
    function s = specimenSymmetry(varargin)
    % defines a specimen symmetry
    %
    % usually specimen symmetry is either triclinic or orthorhombic
    %
    
      s = s@symmetry(varargin{:});
      
      calcQuat(s);
      
    end
    
    function display(s)
      disp(' ');
      disp([inputname(1) ' = ' s.lattice ' ' doclink(s) ' ' docmethods(inputname(1))]);
      disp(' ');
    end        
    
  end
  
end
