function dist = angle(oR,q,varargin)
% angle to the boundary of the OR
% 
% Description
%
% Computes the misorientation angle of orientations to the boundary of an
% @orientationRegion. A negative angle indicates that the orientation is
% inside the OR and a positive angle that it is outside the OR.
%
% Syntax
%   omega = angle(oR,ori)
%
% Input
%  oR - @orientationRegion
%  ori - @orientation
%
% Output
%  omega - misorientation angle to the boundary of oR
%

% verify all conditions are satisfies
d = dot_outer(oR.N,quaternion(q));

% either q or -q needs to satisfy the condition
dist = -2*asin(reshape(max(min(-d,[],1),min(d,[],1)),size(q)));

end
 