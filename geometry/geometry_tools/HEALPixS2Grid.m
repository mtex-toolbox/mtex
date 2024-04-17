function S2G = HEALPixS2Grid(varargin)
% defines an equispaced spherical grid
%
% Syntax
%
%   S2G = HEALPixS2Grid('resolution',5*degree)
%
% Options
%  resolution - resolution of the grid
%
% See also
% regularS2Grid plotS2Grid

res = get_option(varargin,'resolution',2.5*degree);

n = round(log(1/res)/log(2));

polar = HealpixGenerateSampling(2^n,"scoord");

S2G = vector3d.byPolar(polar(:,1),polar(:,2));

end

