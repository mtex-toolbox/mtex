classdef BungePlot < orientationPlot
% 3d plot of orientation space in Bunge Euler angles
%
% The Euler angle box, with phi1, Phi and phi2 as the three axes. Note
% that this parametrisation is heavily distorted near Phi = 0, where a
% whole line of the box is one single orientation.
%
% Syntax
%   plot(ori,'Bunge')
%
% Options
%  ignoreFundamentalRegion    - plot the full 360 × 180 × 360 box
%  project2FundamentalRegion  - project into the fundamental region, default
%  restrict2FundamentalRegion - drop orientations outside it
%
% Class Properties
%  CS1, CS2 - the two @symmetry
%  ax       - the axes handle
%
% See also
% orientationPlot axisAnglePlot phi2Sections orientation/plot
%

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
      if max([xlim ylim zlim]) >= 180
        delta = 60;
      else
        delta = 30;
      end
      set(oP.ax,'XTick',0:delta:max(xlim))
      set(oP.ax,'YTick',0:delta:max(ylim))
      set(oP.ax,'ZTick',0:delta:max(zlim))
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

    function ori = quiverGrid(oP,varargin)
      
      ori = makeGrid(oP,varargin{:},'noBoundary');
      
    end
    
    function ori = makeGrid(oP,varargin)
      res = get_option(varargin,'resolution',5*degree);
      [maxPhi1,maxPhi,maxPhi2] = fundamentalRegionEuler(oP.CS1,oP.CS2);
      if check_option(varargin,'noBoundary'), delta = res/2; else delta = 0; end
      phi1 = delta:res:maxPhi1-delta;
      phi2 = delta:res:maxPhi2-delta;
      Phi =  delta:res:maxPhi-delta;
      
      [oP.plotGrid.x,oP.plotGrid.y,oP.plotGrid.z] = meshgrid(phi1,Phi,phi2);

      ori = orientation.byEuler(oP.plotGrid.x,oP.plotGrid.y,oP.plotGrid.z,oP.CS1,oP.CS2);

      oP.plotGrid.x = oP.plotGrid.x ./ degree;
      oP.plotGrid.y = oP.plotGrid.y ./ degree;
      oP.plotGrid.z = oP.plotGrid.z ./ degree;

    end

  end

end
