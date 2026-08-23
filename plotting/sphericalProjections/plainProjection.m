classdef plainProjection < sphericalProjection
  % no projection, the polar angles are the plane coordinates
  %
  % Plots rho over theta in degree, i.e. the sphere as a rectangle. Distorted
  % everywhere, but the only projection in which a full sphere fits into one
  % axes without splitting hemispheres.
  %
  % Syntax
  %   sP = plainProjection(sR)
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
  % See also
  % sphericalProjection eareaProjection makeSphericalProjection
  %
  
  methods 
    
    function proj = plainProjection(varargin)
      proj = proj@sphericalProjection(varargin{:});
    end
    
    function [rho,theta] = project(sP,v,varargin)
      % compute polar angles
  
      [theta,rho] = polar(v); %#ok<POLAR>

      % restrict to plot able domain
      if ~check_option(varargin,'complete')
        ind = ~sP.sR.checkInside(v,varargin{:});
        rho(ind) = NaN; theta(ind) = NaN;
      end

      rho = reshape(rho,size(v))./ degree;
      theta = reshape(theta,size(v))./ degree;
      
    end
    
    function v = iproject(sP,x,y)
      v = vector3d.byPolar(y*degree, x*degree);
    end
    
  end
  
end
