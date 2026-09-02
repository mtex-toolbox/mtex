classdef sphericalProjection
  % an abstract class representing projections of the sphere to the plane
  %  
  % Every pole figure or inverse pole figure needs one - it turns a
  % @vector3d into the x and y of the axes, and back. Which one is used is
  % picked by a flag of the plotting command, see makeSphericalProjection.
  %
  % Syntax
  %   sP = eareaProjection(sR)
  %   [x,y] = sP.project(v)
  %   v = sP.iproject(x,y)
  %
  % Input
  %  sR   - @sphericalRegion the projection is restricted to
  %  v    - @vector3d
  %  x, y - plane coordinates
  %
  % Class Properties
  %  sR        - @sphericalRegion the projection is restricted to
  %  pC        - @plottingConvention, which direction points east
  %  antipodal - identify v and -v
  %
  % Derived Classes
  %  @eareaProjection        - equal area, Schmidt, the MTEX default
  %  @eangleProjection       - equal angle, stereographic, conformal
  %  @edistProjection        - equal distance
  %  @gnonomicProjection     - gnomonic, great circles become lines
  %  @orthographicProjection - orthographic, the sphere as seen from far away
  %  @squareProjection       - equal area onto a square
  %  @plainProjection        - plain polar angles, no projection at all
  %  @full3dProjection       - no projection, the sphere is drawn in 3d
  %
  % See also
  % makeSphericalProjection sphericalPlot vector3d/plot
  %
  
  properties    
    sR = sphericalRegion
    pC = plottingConvention
  end

  properties (Dependent = true)
    antipodal
  end
    
  methods
    
    
    function sP = sphericalProjection(sR,pC)
      
      if nargin > 0, sP.sR = sR; end
      if nargin > 1, sP.pC = pC; end

    end
    
    function [rho,theta] = project(sP,v,varargin)
      % compute polar angles

      % compute polar angle without any respect to the region
      if check_option(varargin,'ignoreFRBoundaries')
        v = v.rmOption('theta','rho');
        [theta,rho] = polar(inv(sP.pC.rot) * v);
        return
      end
      
      % map such that projection is towards xy plane
      % and compute there spherical coordinates
      v(~sP.sR.checkInside(v,varargin{:})) = NaN;
      v = v.rmOption('theta','rho');
      [theta,rho] = polar(inv(sP.pC.rot) * v); %#ok<MINV,POLAR>
      
      % map to upper hemisphere
      ind = theta > pi/2+10^(-10);
      theta(ind)  = pi - theta(ind);

      % turn around antipodal vectors
      sP.sR.antipodal = false; v.antipodal = false;
      ind = ~sP.sR.checkInside(v);
      rho(ind) = rho(ind) + pi;

    end
    
    function a = get.antipodal(sP)
      a = sP.sR.antipodal;
    end
    
    function sP = set.antipodal(sP,a)
      sP.sR.antipodal = a;
    end
    
    function out = isUpper(sP)
      out = sP.sR.isUpper(sP.pC);
    end

    function out = isLower(sP)
      out = sP.sR.isLower(sP.pC);
    end

    function S2G = makeGrid(sP, varargin)
      % the grid a plot is evaluated on, one per projection

      res = get_option(varargin,'resolution',1*degree);

      S2G = cell(1,numel(sP));
      for iP = 1:numel(sP)

        % regular in the polar angles the projection uses
        sR = inv(sP(iP).pC.rot) * sP(iP).sR; %#ok<MINV,*PROPLC>
        v = plotS2Grid(sR,'plain','resolution',res);

        S2G{iP} = sP(iP).pC.rot .* v.setOption('region',sP(iP).sR);
      end
    end

  end
    
end
