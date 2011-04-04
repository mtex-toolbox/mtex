function ebsd = affinetrans(ebsd, A, b)
% perform an affine transformation on spatial ebsd data
%
%% Input
%  ebsd - @EBSD
%  A    - transformation matrix or homogeneous coordinates, e.g. 
%
%        [1 0;0 1]  or  [1 0 dy; 0 1 dx; 0 0 1 ]
%   
%  b    - shift term
%
%% Output
%  transformed ebsd - @EBSD

% set up transformation matrix
if all(size(A) == [3 3])
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
  T(1:2,3) = b(:);
  T(3,3) = 1;
end

for k = 1:length(ebsd)
  
  % rotate the spatial data
  xy = [ebsd(k).X ones(length(ebsd(k).X),1)] * T';
  ebsd(k).X = xy(:,1:2);
  
  % rotate the unit cell
  T(1:2,3) = 0; % no shift!
  xy = [ebsd(k).unitCell ones(length(ebsd(k).unitCell),1)] * T';
  ebsd(k).unitCell = xy(:,1:2);
end
