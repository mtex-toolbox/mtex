function v = transformReferenceFrame(v,fr,varargin)
% express a direction in another reference frame, keeping the indices
%
% This changes the numbers, not the thing: the direction stays where it is
% and is written out in the axes of |fr|.
%
% Syntax
%   m = transformReferenceFrame(m,cs)
%   m = transformReferenceFrame(m,cs,ori)
%   m = transformReferenceFrame(m,cs,'byScreenAlignment')
%
% Input
%  m   - @vector3d
%  cs  - @referenceFrame to express the direction in
%  ori - @orientation from the frame of m to cs, when it is known
%
% Options
%  byScreenAlignment - take the relation from the two frames being drawn alike
%  tolerance         - how far from a rotation reading the bases may come out
%
% Output
%  m - @vector3d in the frame cs
%
% See also
% frameTransition crystalFrame/transformationMatrix vector3d/frame

if v.frame ~= fr

  M = matrix(frameTransition(v.frame,fr,varargin{:}));
  v = rotate(v,rotation.byMatrix(M));

  v.framePrivate = fr;

end
