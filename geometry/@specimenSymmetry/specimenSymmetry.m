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
     
      if nargin > 0      
        id = symmetry.extractPointId(varargin{:});
      
        % compute symmetry operations
        rot = getClass(varargin,'quaternion');
        if isempty(rot), rot = symmetry.calcQuat(id,[xvector,yvector,zvector]); end
      else
        id = 1;
        rot = [];        
      end  
             
      s = s@symmetry(id,rot);
             
    end
    
    function display(s)
      disp(' ');
      disp([inputname(1) ' = ' s.lattice ' ' doclink(s) ' ' docmethods(inputname(1))]);
      disp(' ');
    end        
    
  end
  
end
