function q = idquaternion(varargin)
% the identical rotation - quaternion(1,0,0,0)

if nargin == 0

  q = quaternion(1,0,0,0);
  
else
  
  q = quaternion(ones(varargin{:}),zeros(varargin{:}),...
    zeros(varargin{:}),zeros(varargin{:}));
  
end
