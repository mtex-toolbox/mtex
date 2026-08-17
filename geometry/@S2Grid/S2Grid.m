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
%   plot(S2G,'y↑→x','upper')
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

methods (Static = true)

  function S2G = loadobj(S2G)
    % called by MATLAB when an S2Grid is loaded from an .mat file
    %
    % Needed because an S2Grid cannot be default constructed - the
    % constructor requires the two S1Grid arguments. MATLAB therefore has
    % no object to fill when the saved property set does not match the
    % current class definition, and hands over the raw struct instead.
    % Without this method the inherited vector3d/loadobj would rebuild a
    % plain @vector3d from it, and every grid method would be gone: an ODF
    % saved by an earlier MTEX then fails on evaluation with "Undefined
    % function 'getdata' for input arguments of type 'vector3d'", raised
    % from SO3Grid/dot_outer by way of the grid its center holds.

    if ~isa(S2G,'S2Grid')
      s = S2G;
      S2G = S2Grid(S1Grid([],0,pi),S1Grid([],0,2*pi));
      S2G = vector3d.fromStruct(S2G,s);
      for p = {'thetaGrid','rhoGrid','res'}
        if isfield(s,p{1}), S2G.(p{1}) = s.(p{1}); end
      end
    end

    S2G = vector3d.loadobj(S2G);

  end

end

end
