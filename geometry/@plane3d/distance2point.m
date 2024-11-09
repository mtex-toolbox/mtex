function d = distance2point(plane, point)
% plot planes in 3d space clipped by current axis, modified after: 
% matGeom/linePosition3d and distancePointPlane , David Legland
%
% Sizes of inputs must match in at least one dimension. You can compare
% - one plane with multiple points
% - one point with multiple planes
% - multiple points with multiple planes !element wise!
%
% Syntax
%   d = pointDistance(plane,points)
%
% Input
%
% See also
% 

% =========================================================================
% LINEPOSITION3D Return the position of a 3D point projected on a 3D line.
%
% ------
% Author: David Legland 
% E-mail: david.legland@inrae.fr
% Created: 2005-02-17
% Copyright 2005-2023 INRA - TPV URPOI - BIA IMASTE


% size of input arguments
npts = length(point);
npl = length(plane);

% normalized plane normal
N = normalize(plane.N.xyz);

if npl == 1 || npts == 1 || npl == npts
    % standard case where result is either scalar or vector

    % Uses Hessian form, ie : N.p = d
    % I this case, d can be found as : -N.p0, when N is normalized
    d = -sum(bsxfun(@times, N, bsxfun(@minus, plane.origin.xyz, point.xyz)), 2);

else
    error('wrong size of inputs')
end