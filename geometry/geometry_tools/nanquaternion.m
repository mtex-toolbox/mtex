function q = nanquaternion(varargin)
% the identical rotation - quaternion(1,0,0,0)

if nargin == 0

  q = quaternion(nan,nan,nan,nan);
  
else
  
  q = quaternion(nan(varargin{:}),nan(varargin{:}),...
    nan(varargin{:}),nan(varargin{:}));
  
end
