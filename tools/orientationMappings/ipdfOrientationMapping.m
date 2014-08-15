classdef ipdfOrientationMapping < orientationMapping
  % defines an orientation mapping based on a certain inverse pole figure
  %   Detailed explanation goes here
  
  properties
    inversePoleFigureDirection = zvector  
  end
  
  methods
    
    function oM = ipdfOrientationMapping(varargin)
      oM = oM@orientationMapping(varargin{:});
      
      if isa(oM.CS2,'crystalSymmetry')
        oM.inversePoleFigureDirection = Miller(oM.inversePoleFigureDirection,oM.CS2);
      end
      
    end
    
    function plot(oM,varargin)
      
      sR = oM.CS1.fundamentalSector(varargin{:});

      h = plotS2Grid(sR,'resolution',1*degree,varargin{:});
      
      d = oM.Miller2color(h);

      if numel(d) == 3*length(h)
        d = reshape(d,[size(h),3]);
        defaultPlotCMD = 'surf';
      else
        defaultPlotCMD = 'pcolor';
      end
      h = plot(h,d,defaultPlotCMD,varargin{:});

      
      if isempty(oM.CS1.mineral)
        name = ['"' oM.CS1.pointGroup '"'];
      else
        name = oM.CS1.mineral;
      end
      
      ax = get(h(1),'parent'); 
      fig = get(ax,'parent');
      set(fig,'name',['Inverse pole figure coloring for ' name])
      title(ax,char(oM(1).inversePoleFigureDirection));
      set(fig,'tag','ipdf')
      setappdata(fig,'CS',oM.CS1);
      setappdata(fig,'inversePoleFigureDirection',oM.inversePoleFigureDirection);
      
      % annotate crystal directions
      if check_option(varargin,'3d')
        hold on
        gray = [0.4 0.4 0.4];
        arrow3d(oM.CS1.axes(1),'facecolor',gray)
        text3(Miller(1,0,0,'uvw',oM.CS1),'a_1','horizontalAlignment','right')

        arrow3d(oM.CS1.axes(2),'facecolor',gray)
        text3(Miller(0,1,0,'uvw',oM.CS1),'a_2','verticalAlignment','cap','horizontalAlignment','left')

        arrow3d(oM.CS1.axes(3),'facecolor',gray)
        text3(Miller(0,0,1,'uvw',oM.CS1),'c','verticalAlignment','bottom')
        hold off
      else
        h = Miller(unique(sR.vertices),oM.CS1);
        h.dispStyle = 'uvw';
        annotate(unique(round(h)),'MarkerFaceColor','k','labeled','symmetrised');
      end

    end
        
    function rgb = orientation2color(oM,ori)
    
      % compute crystal directions
      h = inv(ori) .* oM.inversePoleFigureDirection;

      % colorize fundamental region
      rgb = Miller2color(oM,h);
      
    end
  end
  
  methods (Abstract = true)
    rgb = Miller2color(oM,h)
  end
end
