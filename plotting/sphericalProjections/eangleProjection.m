classdef eangleProjection < sphericalProjection
  % stereographic, conformal or equal angle projection
  %
  % Scales the radius by tan(theta/2). Preserves angles and maps circles to
  % circles, which is what makes it the usual choice for crystallography.
  %
  % Syntax
  %   sP = eangleProjection(sR)
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
        
    function proj = eangleProjection(varargin)
      proj = proj@sphericalProjection(varargin{:});
    end
    
    function [x,y] = project(sP,v,varargin)
      % compute polar angles
  
      [rho,theta] = project@sphericalProjection(sP,v,varargin{:});
      
      % formula for stereographic projection
      r =  tan(theta/2);
            
      % compute coordinates
      x = reshape(cos(rho) .* r,size(v));
      y = reshape(sin(rho) .* r,size(v));
      
    end
    
    function v = iproject(sP,x,y)
      rho = atan2(y,x);
      theta = 2*atan(sqrt(x.^2 + y.^2));
      v = vector3d.byPolar(theta,rho);
      if sP.isLower, v.z = -v.z; end
      v = sP.pC.rot * v;
    end
    
  end
  
end
