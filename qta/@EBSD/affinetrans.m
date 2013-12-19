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


%% set up transformation matrix
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

%% rotate the spatial data
if isfield(ebsd.options,'x') && isfield(ebsd.options,'x')
  xy = [ebsd.options.x, ebsd.options.y, ones(numel(ebsd),1)] * T';
  ebsd.options.x = xy(:,1);
  ebsd.options.y = xy(:,2);
end

% rotate the unit cells
T(1:2,3) = 0; % no shift!
if ~isempty(ebsd.unitCell)
  xy = [ebsd.unitCell ones(length(ebsd.unitCell),1)] * T';
  ebsd.unitCell = xy(:,1:2);
end
