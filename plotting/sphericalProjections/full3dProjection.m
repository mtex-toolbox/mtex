classdef full3dProjection < sphericalProjection
  % no projection, the sphere is drawn in three dimensions
  %
  % Selected by the 3d flag of a spherical plot. Note that such a plot builds
  % no @sphericalPlot, so anything that annotates the axes has to go through
  % annotateFrame.
  %
  % Syntax
  %   sP = full3dProjection(sR)
  %   [x,y,z] = sP.project(v)
  %
  % Input
  %  sR - @sphericalRegion the projection is restricted to
  %  v  - @vector3d
  %
  % Class Properties
  %  sR        - @sphericalRegion the projection is restricted to
  %  pC        - @plottingConvention, which direction points east
  %  antipodal - identify v and -v
  %
  % See also
  % sphericalProjection sphericalPlot vector3d/plot
  %
  
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
