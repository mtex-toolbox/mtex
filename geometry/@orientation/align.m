function ori = align(frA,frB,varargin)
% the orientation two frames stand in by their axes
%
% A point sitting at |v| in |frA| sits at |ori*v| in |frB|. Unlike
% <orientation.byScreenAlignment.html |byScreenAlignment|>, which infers the
% rotation from an assertion about how the two were drawn, this reads the
% two bases and is a geometric fact about them.
%
% It is the rotation <referenceFrame.transformationMatrix.html
% |transformationMatrix|> returns, given a name and both its frames - which
% is what <vector3d.transformReferenceFrame.html |transformReferenceFrame|>
% applies to move data from one frame into the other.
%
% Syntax
%
%   ori = orientation.align(cF1,cF2)
%   ori = orientation.align(cF1,cF2,'tolerance',1*degree)
%
%   ori.frameA       % the source
%   ori.frameB       % the target
%
% Input
%  frA - @referenceFrame, the source
%  frB - @referenceFrame, the target
%
% Options
%  tolerance - how far from a rotation the transition may be; the same
%              referenceFrame.tolCompatible that decides whether two frames
%              are transformable at all
%
% Output
%  ori - @orientation taking coordinates in frA to coordinates in frB
%
% See also
% orientation/byScreenAlignment referenceFrame/transformationMatrix
% vector3d/transformReferenceFrame

argin_check(frA,'referenceFrame');
argin_check(frB,'referenceFrame');

M = transformationMatrix(frA,frB);

% two frames of different cell shape are not related by a rotation at all,
% and applying the matrix anyway would deform the data it is applied to
tol = get_option(varargin,'tolerance',referenceFrame.tolCompatible);
dev = norm(eye(3) - M*M.');
if dev > tol
  error('MTEX:orientation:noRotation',...
    ['These two frames are not related by a rotation - the transition ' ...
    'deviates from one by %g, more than the tolerance %g. Their cell ' ...
    'shapes have to agree for one to be a setting of the other.'],dev,tol);
end

% the transition is one specific rotation, not a coset, so neither side
% claims a group - the frames go in through their group free siblings
ori = orientation(rotation.byMatrix(M),stripSym(frA),stripSym(frB));

end
