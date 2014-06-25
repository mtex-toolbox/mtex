classdef ipdfOrientationMapping < orientationMapping
  % defines an orientation mapping based on a certain inverse pole figure
  %   Detailed explanation goes here
  
  properties
    inversePoleFigureDirection = zvector 
  end
  
  methods
    
    function oM = ipdfOrientationMapping(varargin)
      oM = oM@orientationMapping(varargin{:});
      
      if isCS(oM.CS2)
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
      h = plot(h,d,'TR','',defaultPlotCMD,varargin{:});

      
      if isempty(oM.CS1.mineral)
        name = oM.CS1.pointGroup;
      else
        name = oM.CS1.mineral;
      end
      
      ax = get(h(1),'parent'); 
      fig = get(ax,'parent');
      title(ax,[name ' (' char(oM(1).inversePoleFigureDirection) ') inverse pole figure coloring'])
   
      set(fig,'tag','ipdf')
      setappdata(fig,'CS',oM.CS1);
      setappdata(fig,'inversePoleFigureDirection',oM.inversePoleFigureDirection);
      
      % annotate crystal directions
      h = Miller(unique(sR.vertices),oM.CS1);
      h.dispStyle = 'uvw';
      annotate(round(h),'MarkerFaceColor','k','labeled','symmetrised');

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
