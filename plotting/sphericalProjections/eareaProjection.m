classdef eareaProjection < sphericalProjection
  % equal area or Schmidt projection
  %
  % Scales the radius by sqrt(2*(1-cos(theta))), which preserves area and
  % makes it the right projection for judging densities. The MTEX default.
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
  % See also
  % sphericalProjection eangleProjection makeSphericalProjection
  %
  
  methods 
        
    function proj = eareaProjection(varargin)
      proj = proj@sphericalProjection(varargin{:});
    end
    
    function [x,y] = project(sP,v,varargin)

      % compute polar angles
      [rho,theta] = project@sphericalProjection(sP,v,varargin{:});
      
      % formula for equal area projection
      r =  sqrt(2*(1-cos(theta)));
            
      % compute coordinates
      x = reshape(cos(rho) .* r,size(v));
      y = reshape(sin(rho) .* r,size(v));

    end
    
    function v = iproject(sP,x,y)
      rho = atan2(y,x);
      r = x.^2 + y.^2;
      theta = acos(1-r./2);
      v = vector3d.byPolar(theta,rho);
      if sP.isLower, v.z = -v.z; end
      v = sP.pC.rot * v;
    end
    
  end
  
end
