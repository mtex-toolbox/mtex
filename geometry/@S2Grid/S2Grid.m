classdef S2Grid < vector3d
%
% Syntax
%   S2Grid(theta,rho)      % fills a Sphere with N--nodes
%   regularS2Grid('resolution',5*degree)     % construct regular polar and azimuthal spacing
%   equispacedS2Grid('resolution',5*degree)  % construct equispaced nodes
%
% Input
%  nodes      - @vector3d
%
% Options
%  POINTS     - [nrho,ntheta] number of points to be generated
%  RESOLUTION - resolution of a equispaced grid
%  HEMISPHERE - 'lower', 'uper', 'complete', 'sphere', 'identified'}
%  THETA      - theta angle
%  RHO        - rho angle
%  MINRHO     - starting rho angle (default 0)
%  MAXRHO     - maximum rho angle (default 2*pi)
%  MINTHETA   - starting theta angle (default 0)
%  MAXTHETA   - maximum theta angle (default pi)
%
% Flags
%  REGULAR    - generate a regular grid
%  EQUISPACED - generate equidistribution
%  ANTIPODAL  - include [[AxialDirectional.html,antipodal symmetry]]
%  PLOT       - generate plotting grid
%  NO_CENTER  - ommit point at center
%  RESTRICT2MINMAX - restrict margins to min / max
%
% Examples
%   regularS2Grid('points',[72 19])
%
%   regularS2Grid('resolution',[5*degree 2.5*degree])
%
%   equispacedS2Grid('resolution',5*degree,'maxrho',pi)
%   plot(ans)
%
% See also
% vector3d/vector3d

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
