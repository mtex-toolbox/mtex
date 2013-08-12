function T = set(T,pName,pValue,varargin)
% set properties of a tensor variable
%
% Syntax
%   T = set(T,'mineral','mineral name')  
% 
% Input
%  T      - @tensor
%  pName  - property name
%  pValue - property value
%
% Output
%
% See also
% tensor/get


switch pName

  case 'CS'

    if ~check_option(varargin,'noTrafo')
      M = transformationMatrix(T.CS,pValue);
      T = rotate(T,M);
    end
    
    T.CS = pValue;
    
    if ~check_option(varargin,'noCheck') && ~checkSymmetry(T)
      T = symmetrise(T);
    end
  
  case fields(T)
    
    T.(pName) = pValue;
    
  otherwise
  
    T.properties.(pName) = pValue;
    
end

% check for change of reference frame
% cs1 = symmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||a*')
% cs2 = symmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||b','X||a*')
% T1 = tensor(rand(3),cs1)
% T2 = set(T1,'CS',cs2)
% o1 = orientation('Euler',30*degree,50*degree,120*degree,cs1)
% o2 = set(o1,'CS',cs2);
% %now the next should result in the same tensors
% rotate(T1,o1)
% rotate(T1,o2)
% 
% rotate(T2,o2)
% rotate(T2,o1)
