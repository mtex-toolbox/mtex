function dist = angle(oR,q,varargin)
% angle to the boundary of the OR
%
% Syntax
%
%   dist = angle(oR,ori)
%
% Input
%  oR  - @orientationRegion
%  ori - @orientation
%
% Output
%  dist - distance to boundary, negative is inside, positive is outside
%

% verify all conditions are satisfies
d = dot_outer(oR.N,quaternion(q));

% either q or -q needs to satisfy the condition
dist = -2*asin(reshape(max(min(-d,[],1),min(d,[],1)),size(q)));

end
 