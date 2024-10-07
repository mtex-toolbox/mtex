classdef plainProjection < sphericalProjection
  %sphericalProjection
  
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
      v = vector3d('theta',y*degree,'rho',x*degree);
    end
    
  end
  
end
