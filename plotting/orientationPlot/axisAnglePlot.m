classdef axisAnglePlot < orientationPlot
  
  properties
    oR 
  end
  
  methods
    
    function oP = axisAnglePlot(varargin)
      % create a 3d Euler angle plot
      
      oP = oP@orientationPlot(varargin{:});
      
      oP.oR = fundamentalRegion(oP.CS1,oP.CS2,char(extract_option(varargin,{'antipodal','complete'})));
      
      xlabel(oP.ax,'$x$','Interpreter','LaTeX');
      ylabel(oP.ax,'$y$','Interpreter','LaTeX');
      zlabel(oP.ax,'$z$','Interpreter','LaTeX');
      
      if ~check_option(varargin,'noBoundary') && ~strcmpi(oP.fRMode,'ignoreFundamentalRegion')
        opt = delete_option(varargin,{'color','linewidth','linecolor','edgecolor'},1);
        plot(oP.oR,'parent',oP.ax,'noBoundaryCheck',opt{:});
      end
      
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
      
      [x,y,z] = double(q.axis .* q.angle ./ degree);
            
    end
    
    function ori = iproject(oP,x,y,z,varargin)
      ori = orientation.id;
    end
    
    function [ori,S2G,omega] = makeGrid(oP,varargin)
      
      res = get_option(varargin,'resolution',2.5*degree);
            
      % compute rotational axes
      S2G = plotS2Grid(oP.oR.axisSector,'resolution',res);
      
      % compute rotational angles
      omega = (0:res:oP.oR.maxAngle)./oP.oR.maxAngle;
      omega = repmat(omega(:),[1 size(S2G)]);
      omega = shiftdim(omega,1);
      
      maxOmega = oP.oR.maxAngle(S2G);
      omega = bsxfun(@times,omega,maxOmega);
      
      S2G = repmat(S2G,[1 1 size(omega,3)]);
      
      ori = orientation.byAxisAngle(S2G,omega,oP.CS1,oP.CS2);
      
      [oP.plotGrid.x,oP.plotGrid.y,oP.plotGrid.z] = ...
        double(omega ./ degree .* S2G);
            
    end
    
  end
  
end





