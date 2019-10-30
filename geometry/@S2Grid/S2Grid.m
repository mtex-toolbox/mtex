classdef S2Grid < vector3d
%
% The class S2Grid represent spherical grids. The central difference to a
% simple list of @vector3d is that S2Grid provides more efficient methods
% for finding the closes points in the grid with respect to a given
% direction.
%
% Syntax
%
%   % regular grid with fixed polar and azimuthal spacing
%   S2G = regularS2Grid('resolution',5*degree)
%   S2G = regularS2Grid('theta',(0:5:80)*degree,'rho',(0:5:355)*degree)
%
%   % regular grid optimized for plotting
%   S2G = plotS2Grid('resolution',1.5*degree,'upper')
%
%   % equispaced nodes  with given resolution
%   S2G = equispacedS2Grid('resolution',5*degree)
%
% Options
%  points     - [nrho,ntheta] number of points
%  resolution - resolution of a equispaced grid
%  theta      - polar angle
%  rho        - azimuthal angle
%  minRho     - starting rho angle (default 0)
%  maxRho     - maximum rho angle (default 2*pi)
%  minTheta   - starting theta angle (default 0)
%  maxTheta   - maximum theta angle (default pi)
%
% Flags
%  lower, uper, complete - restrict hemisphere
%  antipodal  - include <VectorsAxes.html antipodal symmetry>
%  no_center  - ommit point at center
%  restrict2minmax - restrict margins to min / max
%
% Examples
%
%   S2G = equispacedS2Grid('resolution',5*degree,'maxTheta',70*degree)
%   plot(S2G)
%
% See also
% vector3d.vector3d plotS2Grid regularS2Grid equispaceS2Grid

properties

  thetaGrid = S1Grid([],0,pi);
  rhoGrid = S1Grid([],0,2*pi);
  res = 2*pi;

end

methods

  function S2G = S2Grid(thetaGrid,rhoGrid,varargin)

    % call superclass method
    v = calcGrid(thetaGrid,rhoGrid);
    [S2G.x,S2G.y,S2G.z] = double(v);
    S2G.thetaGrid = thetaGrid;
    S2G.rhoGrid = rhoGrid;
    S2G.res = get_option(varargin,'resolution',2*pi);
    S2G.antipodal = check_option(varargin,'antipodal');
  end

  function v = vector3d(S2G)
    v = vector3d(S2G.x,S2G.y,S2G.z);
    v.opt = S2G.opt;
    v.antipodal = S2G.antipodal;
  end

end

end
