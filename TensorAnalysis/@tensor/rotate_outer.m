function T = rotate_outer(T,R,varargin)
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
  R = fitFrame(R,T.CS.frame);

  % the rotated tensor lives in the specimen frame of the orientation,
  % but it does not possess the specimen SYMMETRY - only the reference
  % frame is taken over
  if R.SS.id == 1
    T.CS = R.SS;
  else
    ss = specimenSymmetry;
    ss.frame = R.SS.frame;
    T.CS = ss;
  end
end

% convert rotation to 3 x 3 matrix - (3 x 3 x N) for many rotation
if ~isnumeric(R), R = matrix(R); end

T = reshape(T,1,[]);
R = reshape(R,3,3,[]);

% multiply the tensor with respect to every dimension with the rotation
% matrix
for d = 1:T.rank
  
  ind = 1:T.rank;
  ind(d) = -d;
  T = EinsteinSum(T,ind,R,[d -d],'keepClass');
        
end
