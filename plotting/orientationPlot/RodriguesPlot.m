classdef RodriguesPlot < axisAnglePlot
% 3d plot of orientation space in Rodrigues Frank coordinates
%
% An orientation is drawn at its rotational axis scaled by tan(angle/2).
% In these coordinates the fundamental region is a convex polyhedron, but
% a rotation by 180 degree runs off to infinity.
%
% Syntax
%   plot(ori,'Rodrigues')
%   plot(ori,'Rodrigues','antipodal')
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
% orientationPlot axisAnglePlot orientation/plot quaternion.Rodrigues
%
  
  methods
    
     function oP = RodriguesPlot(varargin)
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
      [x,y,z] = double(q.axis .* tan(q.angle./2));
            
    end
    
    function ori = iproject(oP,x,y,z,varargin)
      ori = orientation.id;
    end

    function ori = makeGrid(oP,varargin)
      
      [ori,S2G,omega] = makeGrid@axisAnglePlot(oP,varargin{:});
      
      [oP.plotGrid.x,oP.plotGrid.y,oP.plotGrid.z] = ...
        double(S2G .* tan(omega./2));
      
    end
        
  end
  
end





