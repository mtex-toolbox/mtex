function ebsd = mtimes(x,y)
% rotating the ebsd data by a certain rotation 
%
% overload the * operator, i.e. one can now write g*@EBSD or @EBSD*v in
% order to rotate EBSD data or the rotate a vector by EBSD data
%
%% See also
% EBSD_index EBSD/rotate

if isa(x,'EBSD') && isa(y,'vector3d')
        
  ebsd = getgrid(x) * y;
  
elseif isa(x,'EBSD') && isa(y,'quaternion')
  ebsd = x;
  for i = 1:length(ebsd)
    ebsd(i).grid = ebsd(i).grid * y;
  end
elseif isa(y,'EBSD') && isa(x,'quaternion')
  ebsd = y;
  for i = 1:length(ebsd)
    ebsd(i).grid = x * ebsd(i).grid;
  end
end



