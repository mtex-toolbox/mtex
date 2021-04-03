function v = calcAxisVolume(odf,axis,radius,varargin)
% amount of orientations with a specific misorientation axis 
%
% Syntax
%   vol = calcAxisVolume(odf,axis,radius)
%
% Input
%  odf  - @ODF
%  axis - @vector3d / @Miller
%  radius - double
%
% Output
%  vol - volumeportion of all axes within the specified radius around axis
%
% See also
% plotAxisDistribution

% get resolution for quadrature
res = get_option(varargin,'resolution',min(radius/5,2.5*degree));

% find fundamental region
sym = properGroup(disjoint(odf.CS,odf.SS));
if odf.antipodal || check_option(varargin,'antipodal')
  sym = sym.Laue;
end

% define a grid for quadrature
h = equispacedS2Grid(sym.fundamentalSector,'resolution',res,varargin{:});

% find those within the ball
ind = angle(Miller(axis,sym),Miller(h,sym)) < radius+1e-5;
h = h(ind);

% remember volume of the ball
vol = nnz(ind)/numel(ind);

% compute axis distrubtion
w = calcAxisDistribution(odf,h,varargin{:});

v = min(mean(w) * vol,1);
