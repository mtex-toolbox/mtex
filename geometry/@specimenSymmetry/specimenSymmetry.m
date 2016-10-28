classdef specimenSymmetry < symmetry
% defines a specimen symmetry
% 
% usually specimen symmetry is either 
% triclinic or orthorhombic
%

  methods
    
    function s = specimenSymmetry(varargin)
    % defines a specimen symmetry
    %
    % usually specimen symmetry is either triclinic or orthorhombic
    %
    
      s = s@symmetry(varargin{:});
      
      if nargin > 0, s = calcQuat(s); end
      
    end
    
    function display(s)
      disp(' ');
      disp([inputname(1) ' = ' s.lattice ' ' doclink('symmetry_index','specimenSymmetry') ' ' docmethods(inputname(1))]);
      disp(' ');
    end        
    
  end
  
end
