function v = vector3d(x,y,z,varargin)
% Constructor
%% Input
%  x,y,z - cart. coordinates
%  v     - @vector3d
%  empty -> vector3d(0,0,0)

if nargin == 0 %null-vector
  v.x = [];
  v.y = [];
  v.z = [];
  v = class(v,'vector3d');
elseif nargin ==1 
  if isa(x,'vector3d') % copy-constructor
    v = x;
  elseif isa(x,'double')
    if all(size(x) == [1,3])
      x = x.';
    end
    v.x = x(1,:);
    v.y = x(2,:);
    v.z = x(3,:);
    v = class(v,'vector3d');
  else
    error('wrong type of argument');
  end
elseif nargin == 2 %
  error('for spherical koordinates use sph2vec');
else
  v.x = x;
  v.y = y;
  v.z = z;
    
  v = class(v,'vector3d');
end

% check for equal size
if numel(v.x) ~= numel(v.y) || (numel(v.x) ~= numel(v.z))
  
  % find non singular size
  if numel(v.x) > 1
    s = size(v.x);
  elseif numel(v.y) > 1
    s = size(v.y);
  else
    s = size(v.z);
  end
  
  % try to correct
  if numel(v.x) == 1, v.x = repmat(v.x,s);end
  if numel(v.y) == 1, v.y = repmat(v.y,s);end
  if numel(v.z) == 1, v.z = repmat(v.z,s);end

  % check again
  if numel(v.x) ~= numel(v.y) || (numel(v.x) ~= numel(v.z))
    error('MTEX:Vector3d','Coordinates have different size.');
  end
end
  
if check_option(varargin,'normalize')
  v = v ./ norm(v);
end



