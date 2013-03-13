function v = calcAxisVolume(odf,axis,radius,varargin)
% compute the axis distribution of an ODF or MDF
%
%
%% Input
%  odf  - @ODF
%  axis - @vector3d / @Miller
%  radius - double
%
%% Flags
%  smallesAngle - use axis corresponding to the smalles angle
%  largestAngle - use axis corresponding to the largest angle
%  allAngles    - use all axes
%
%% Output
%  v   - volumeportion of all axes within the specified radius around axis
%
%% See also
% ODF/plotAxisDistribution

% get resolution for quadrature
res = get_option(varargin,'resolution',radius/5);

% define a grid for quadrature
h = S2Grid('equispaced','resolution',res,varargin{:});

% restrict to fundamental region
sym = disjoint(odf.CS,odf.SS);
h = Miller(h,sym);
ind = checkFundamentalRegion(h,'antipodal');
h = h(ind);

% find those within the ball
ind = angle(h,vector3d(axis)) < radius;
h = h(ind);

% remember volume of the ball
vol = nnz(ind)/numel(ind);

% compute axis distrubtion

w = calcAxisDistribution(odf,h);

v = mean(w) * vol;
