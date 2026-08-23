classdef cubochoricPlot < axisAnglePlot
% 3d plot of orientation space in cubochoric coordinates
%
% Like @homochoricPlot volume preserving, but mapped onto a cube rather
% than a ball, which is what makes a regular grid in these coordinates an
% equal volume grid in orientation space.
%
% Syntax
%   plot(ori,'cubochoric')
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
% orientationPlot homochoricPlot orientation/plot
%
  
  methods
    
    function oP = cubochoricPlot(varargin)
      % create a 3d plot of rotations in cubochoric coordinates
      
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
     
      [x,y,z] = double(cubochoric(ori));
      
    end
    
    function ori = iproject(oP,x,y,z,varargin)
      ori = orientation.id;
    end
    
    function ori = makeGrid(oP,varargin)
      
      [ori,S2G,omega] = makeGrid@axisAnglePlot(oP,varargin{:});
      
      [oP.plotGrid.x, oP.plotGrid.y, oP.plotGrid.z] = ...
        double( S2G .* (3./4 * (omega - sin(omega))).^(1/3));
      
    end
  end
end
