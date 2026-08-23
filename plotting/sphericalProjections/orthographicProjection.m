classdef orthographicProjection < sphericalProjection
  % orthographic projection
  %
  % Scales the radius by sin(theta), i.e. the sphere as seen from infinitely
  % far away.
  %
  % Syntax
  %   sP = orthographicProjection(sR)
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
        
    function [x,y] = project(sP,v,varargin)
      % compute polar angles
  
      [rho,theta] = project@sphericalProjection(sP,v,varargin{:});

      % formula for orthographic projection
      r =  sin(theta);
            
      % compute coordinates
      x = reshape(cos(rho) .* r,size(v));
      y = reshape(sin(rho) .* r,size(v));
      
    end
    
    function v = iproject(sP,x,y)
      v = vector3d.byPolar(x*degree,y*degree);
    end
    
  end
  
end
