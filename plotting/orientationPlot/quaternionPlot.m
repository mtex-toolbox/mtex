classdef quaternionPlot < axisAnglePlot
% 3d plot of orientation space in quaternion coordinates
%
% An orientation is drawn at its rotational axis scaled by sin(angle/2),
% i.e. at the imaginary part of its unit quaternion. Since sin is not
% monotone on the full range, rotations by more than 180 degree fold back.
%
% Syntax
%   plot(ori,'quaternion')
%
% Options
%  ignoreFundamentalRegion    - plot orientations as they are
%  project2FundamentalRegion  - project into the fundamental region, default
%  restrict2FundamentalRegion - drop orientations outside it
%  noBoundary                 - do not plot the boundary
%
% Class Properties
%  oR       - @orientationRegion drawn as the boundary
%  CS1, CS2 - the two @symmetry
%  ax       - the axes handle
%
% See also
% orientationPlot axisAnglePlot orientation/plot
%
  
  methods
    
    function oP = quaternionPlot(varargin)
      % create a 3d Euler angle plot
      
      oP = oP@axisAnglePlot(varargin{:});
      
     end
        
     function [x,y,z] = project(oP,ori,varargin)
      
      if ~check_option(varargin,'noBoundaryCheck')
        switch oP.fRMode
          case 'project2FundamentalRegion'
            ori = project2FundamentalRegion(ori);
          case 'restrict2FundamentalRegion'
            ori(~oP.oR.checkInside) = NaN;
        end
      end
      
      q = quaternion(ori);      
      [x,y,z] = double(q.axis .* sin(q.angle./2));
            
    end
    
    function ori = iproject(oP,x,y,z,varargin)
      ori = orientation.id;
    end
        
    function ori = makeGrid(oP,varargin)
      
      [ori,S2G,omega] = makeGrid@axisAnglePlot(oP,varargin{:});
      
      [oP.plotGrid.x,oP.plotGrid.y,oP.plotGrid.z] = ...
        double( S2G .* sin(omega./2));
      
    end
    
  end
end
