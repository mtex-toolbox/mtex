function ebsd = mtimes(x,y)
% rotating the ebsd data by a certain rotation 
%
% overloads the * operator
%
% Syntax
%   ebsd = g * ebsd % rotates the EBSD data by orientation g
%   ebsd = ebsd * v % rotate a vector3d v by EBSD data
%
% See also
% EBSD_index EBSD/rotate

if isa(x,'EBSD') && isa(y,'vector3d')
        
  ebsd = [x.rotations] * y;
  
elseif isa(x,'EBSD') && isa(y,'quaternion')
  ebsd = x;
  for i = 1:length(ebsd)
    ebsd(i).rotations = ebsd(i).rotations * y;
  end
elseif isa(y,'EBSD') && isa(x,'quaternion')
  ebsd = y;
  for i = 1:length(ebsd)
    ebsd(i).rotations = x * ebsd(i).rotations;
  end
end
