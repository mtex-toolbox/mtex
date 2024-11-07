function h = circle(normals,varargin)
% annotated a circle
%
% Syntax
%
%   circle(n)
%   circle(n,omega)
%
% Input
%  n     - a normal @vector3d
%  omega - opening angle around n (default pi/2)  great circle
%
% Options
%

% extract radius
if numel(varargin) >= 1 && isnumeric(varargin{1})
  omega = varargin{1};
  varargin(1) = [];
else
  omega  = 90*degree; 
end

if isscalar(normals), normals = repmat(normals,size(omega)); end
if isscalar(omega), omega = repmat(omega,size(normals)); end

h = gobjects;

for i = 1:length(normals)

  n = normals.subSet(i);
  
  % generate circles
  c = axis2quat(n,(0:1:360)*degree) * axis2quat(orth(n),omega(i))*n;
  
  % plot circles
  h = [h,line(c,varargin{:},'hold','doNotDraw')]; %#ok<AGROW>
  
end

if nargout == 0, clear h; end
