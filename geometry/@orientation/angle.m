function omega = angle(o1,o2,varargin)
% calcualtes rotational angle between orientations
%
%% Syntax  
%  omega = angle(o)
%  omega = angle(o1,o2)
%
%% Input
%  o1, o2 - @orientation
% 
%% Output
% o1 x o2 - angle (double)

if nargin == 1
  
  [q,omega] = getFundamentalRegion(o1,varargin{:});

else
  
  omega = real(2*acos(dot(o1,o2,varargin{:})));
  
end
