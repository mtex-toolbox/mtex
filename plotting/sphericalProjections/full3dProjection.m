classdef full3dProjection < sphericalProjection
  %equal area projection
  
  methods 
        
    function proj = full3dProjection(varargin)
      proj = proj@sphericalProjection(varargin{:});
    end
    
    function [x,y,z] = project(sP,v,varargin)
      [x,y,z] = double(v);
    end
    
    function v = iproject(sP,x,y)
    end
    
    function S2G = makeGrid(sP, varargin)
      S2G = plotS2Grid(varargin{:});      
    end

  end
  
end
