function T = rotate(T,R)
% rotate a tensor by a list of rotations
%
%% Description
% Formula: T_rst = T_ijk R_ir R_js R_kt
%
%% Input
%  T - @tensor
%  R - @rotation or rotation matrix or a list of them
%
%% Output
%  T - rotated @tensor
%

% ensure that the rotations have the right reference frame
if isa(R,'orientation')
  R = ensureCS(T.CS,{R});
  T.CS = get(R,'SS');
end

% convert rotation to 3 x 3 matrix - (3 x 3 x N) for many rotation
if ~isnumeric(R), R = matrix(R); end


% mulitply the tensor with respect to every dimension with the rotation
% matrix
for d = 1:T.rank

  T = mtimesT(T,d,R); % tensor product
  
end

