classdef BungePlot < orientationPlot

  methods

    function oP = BungePlot(varargin)
      % create a 3d Euler angle plot

      oP = oP@orientationPlot(varargin{:});

      xlabel(oP.ax,'$\varphi_1$','Interpreter','LaTeX');
      ylabel(oP.ax,'$\Phi$','Interpreter','LaTeX');
      zlabel(oP.ax,'$\varphi_2$','Interpreter','LaTeX');

      if any(strcmpi(oP.fRMode,{'restrict2FundamentalRegion','project2FundamentalRegion'}))
        [maxphi1,maxPhi,maxphi2] = fundamentalRegionEuler(oP.CS1,oP.CS2);
        xlim(oP.ax,[0 maxphi1./degree]);
        ylim(oP.ax,[0 maxPhi./degree]);
        zlim(oP.ax,[0 maxphi2./degree]);
      else
        xlim(oP.ax,[0 360]);
        ylim(oP.ax,[0 180]);
        zlim(oP.ax,[0 360]);
      end
      set(oP.ax,'XTick',0:30:max(xlim))
      set(oP.ax,'YTick',0:30:max(ylim))
      set(oP.ax,'ZTick',0:30:max(zlim))
    end


    function [x,y,z] = project(oP,ori,varargin)

      switch oP.fRMode
        case 'project2FundamentalRegion'
          [x,y,z] = ori.project2EulerFR;
        otherwise
          [x,y,z] = Euler(ori);
      end

      x = x./degree;
      y = y./degree;
      z = z./degree;

    end

    function ori = iproject(oP,x,y,z,varargin)
      ori = orientation.id;
    end

    function ori = makeGrid(oP,varargin)
      res = get_option(varargin,'resolution',5*degree);
      [maxPhi1,maxPhi,maxPhi2] = fundamentalRegionEuler(oP.CS1,oP.CS2);
      phi1 = 0:res:maxPhi1;
      phi2 = 0:res:maxPhi2;
      Phi = 0:res:maxPhi;
      [oP.plotGrid.x,oP.plotGrid.y,oP.plotGrid.z] = meshgrid(phi1,Phi,phi2);

      ori = orientation.byEuler(oP.plotGrid.x,oP.plotGrid.y,oP.plotGrid.z,oP.CS1,oP.CS2);

      oP.plotGrid.x = oP.plotGrid.x ./ degree;
      oP.plotGrid.y = oP.plotGrid.y ./ degree;
      oP.plotGrid.z = oP.plotGrid.z ./ degree;

    end

  end

end
