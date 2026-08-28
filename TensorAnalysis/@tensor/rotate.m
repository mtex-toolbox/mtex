function T = rotate(T,R,varargin)
% rotate a tensor by a list of rotations
%
% Description
%
% $$T_{rst} = T_{ijk} R_{ri} R_{sj} R_{tk}$$
%
% Input
%  T - @tensor
%  R - @rotation or rotation matrix or a list of them
%
% Output
%  T - rotated @tensor
%

% the orientation has to act on the frame the tensor is expressed in -
% the symmetries need not agree, only the frames have to fit
if isa(R,'orientation') && nargin == 2
  R = fitFrame(R,T.CS);

  % the rotated tensor takes the specimen frame, but not the specimen
  % symmetry - the group-stripped sibling is that frame without the claim
  T.CS = stripSym(R.SS);

elseif ~inGroup(R,T.frame)

  % turned by anything but an element of its own group, the tensor is no
  % longer invariant under it - so the frame it is written in claims none
  T.frame = stripSym(T.frame);

end

% convert rotation to 3 × 3 matrix - (3 × 3 × N) for many rotation
if ~isnumeric(R), R = matrix(R); end

% mulitply the tensor with respect to every dimension with the rotation
% matrix
for d = 1:T.rank
  
  ind = 1:T.rank;
  ind(d) = -d;
  T = EinsteinSum(T,ind,R,[d -d],'keepClass');
  
end
