function T = transformReferenceFrame(T,cs,varargin)
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

M = transformationMatrix(T.CS,cs);
T = rotate(T,M);
T.CS = cs;

if ~check_option(varargin,'noCheck') && ~checkSymmetry(T)
  T = symmetrise(T);
end


% check for change of reference frame
% cs1 = crystalSymmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||a*')
% cs2 = crystalSymmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||b','X||a*')
% T1 = tensor(rand(3),cs1)
% T2 = T1.transformReferenceFrame(cs2)
% o1 = orientation.byEuler(30*degree,50*degree,120*degree,cs1)
% o2 = o1.transformReferenceFrame(cs2);
% %now the next should result in the same tensors
% rotate(T1,o1)
% rotate(T1,o2)
%
% rotate(T2,o2)
% rotate(T2,o1)
