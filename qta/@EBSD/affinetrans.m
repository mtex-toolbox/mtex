function ebsd = affinetrans(ebsd, A, b)
% perform an affine transformation on spatial ebsd data
%
%% Input
%  ebsd - @EBSD
%  A    - transformation matrix or homogeneous coordinates
%  b    - shift term
%
%% Output
%  transformed ebsd - @EBSD

if all(size(A) == [ 3 3])
  T = A;
elseif nargin < 3
  T(1:2,1:2) = A;
 	T(3,3) = 1;
else
  if ~isempty(A)
    T(1:2,1:2) = A;
  else 
     T(1:2,1:2) = eye(2);
  end
  T(1:2,3) = b;
  T(3,3) = 1;
end

for k = 1:length(ebsd)
  xy = [ebsd(k).xy ones(length(ebsd(k).xy),1)] * T';
  ebsd(k).xy = xy(:,1:2);
end