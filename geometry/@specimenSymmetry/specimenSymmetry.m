classdef specimenSymmetry < symmetry
% defines a specimen symmetry
% 
% usually specimen symmetry is either 
% triclinic or orthorhombic
%

  methods
    
    function s = specimenSymmetry(varargin)
      s = s@symmetry(varargin{:});
      s = calcQuat(s);
    end
    
    function display(s)
      disp(' ');
      disp([inputname(1) ' = ' s.lattice ' ' doclink('symmetry_index','specimenSymmetry') ' ' docmethods(inputname(1))]);
      disp(' ');
    end        
    
  end
  
end
