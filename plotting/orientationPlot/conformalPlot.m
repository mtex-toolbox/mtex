classdef conformalPlot < axisAnglePlot
  
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
