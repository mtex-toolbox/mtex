function T = transformReferenceFrame(T,cs,varargin)
% express a tensor in another reference frame
%
% The tensor stays what it is and its coefficients are written out in the
% axes of |cs| - the counterpart of <vector3d.transformReferenceFrame.html
% the method of the same name on a direction>.
%
% Syntax
%   T = transformReferenceFrame(T,cs)
%   T = transformReferenceFrame(T,cs,ori)
%   T = transformReferenceFrame(T,cs,'byScreenAlignment')
%
% Input
%  T   - @tensor
%  cs  - @referenceFrame to express the tensor in
%  ori - @orientation from the frame of T to cs, when it is known
%
% Options
%  byScreenAlignment - take the relation from the two frames being drawn alike
%  tolerance         - how far from a rotation reading the bases may come out
%  noCheck           - do not symmetrise the result under the new group
%
% Output
%  T - @tensor in the frame cs
%
% See also
% frameTransition vector3d/transformReferenceFrame tensor/rotate

M = matrix(frameTransition(T.frame,cs,varargin{:}));
T = rotate(T,M);
T.frame = cs;

if ~check_option(varargin,'noCheck') && ~checkSymmetry(T)
  T = symmetrise(T);
end

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
