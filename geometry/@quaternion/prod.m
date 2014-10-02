function q = prod(varargin)
% overloads q1 * q2 * q3

if nargin == 0
  
  q = quaternion;
  
else

  q = varargin{1};
  for i = 2:length(varargin)
    q = q * varargin{i};
  end
  
end