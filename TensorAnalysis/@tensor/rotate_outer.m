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

% ensure that the rotations have the right reference frame
if isa(R,'orientation') && nargin == 2
  R = T.CS.ensureCS(R);
  T.CS = R.SS;
end

% convert rotation to 3 x 3 matrix - (3 x 3 x N) for many rotation
if ~isnumeric(R), R = matrix(R); end

T = reshape(T,1,[]);
R = reshape(R,3,3,[]);

% mulitply the tensor with respect to every dimension with the rotation
% matrix
for d = 1:T.rank
  
  ind = 1:T.rank;
  ind(d) = -d;
  T = EinsteinSum(T,ind,R,[d -d],'keepClass');
        
end
