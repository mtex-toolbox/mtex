classdef homochoricPlot < axisAnglePlot
  
  methods
    
    function oP = homochoricPlot(varargin)
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
      [x,y,z] = double(q.axis .* (3./4 * (q.angle - sin(q.angle))).^(1/3));
            
    end
    
    function ori = iproject(oP,x,y,z,varargin)
      ori = orientation.id;
    end
    
    function ori = makeGrid(oP,varargin)
      
      [ori,S2G,omega] = makeGrid@axisAnglePlot(oP,varargin{:});
      
      [oP.plotGrid.x,oP.plotGrid.y,oP.plotGrid.z] = ...
        double( S2G .* (3./4 * (omega - sin(omega))).^(1/3));
      
    end
  end
end
