function v = transformReferenceFrame(v,fr)
% express a direction in another reference frame, keeping the indices
%
% Syntax
%   m = transformReferenceFrame(m,cs)
%
% Input
%  m  - @vector3d
%  cs - @referenceFrame to express the direction in
%
% Output
%  m - @vector3d in the frame cs
%
% See also
% crystalFrame/transformationMatrix vector3d/frame

if v.frame ~= fr

  M = transformationMatrix(v.frame,fr);
  v = rotate(v,rotation.byMatrix(M));

  v.framePrivate = fr;

end
