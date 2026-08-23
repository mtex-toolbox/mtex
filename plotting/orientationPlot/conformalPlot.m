classdef conformalPlot < axisAnglePlot
% 3d plot of orientation space in conformal coordinates
%
% An orientation is drawn at its rotational axis scaled by
% 2*tan(angle/4), the stereographic projection of the quaternion ball.
% Unlike the other parametrisations this one preserves angles.
%
% Syntax
%   plot(ori,'conformal')
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
    
    function oP = conformalPlot(varargin)
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
      [x,y,z] = double(2 * q.axis .* tan(q.angle./4));
            
    end
    
    function ori = iproject(oP,x,y,z,varargin)
      ori = orientation.id;
    end
    
    function ori = makeGrid(oP,varargin)
      
      [ori,S2G,omega] = makeGrid@axisAnglePlot(oP,varargin{:});
      
      [oP.plotGrid.x,oP.plotGrid.y,oP.plotGrid.z] = ...
        double( 2 * S2G .* tan(omega./4));
      
    end
    
  end
end
