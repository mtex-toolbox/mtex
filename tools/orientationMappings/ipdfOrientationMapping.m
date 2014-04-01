classdef ipdfOrientationMapping < orientationMapping
  % defines an orientation mapping based on a certain inverse pole figure
  %   Detailed explanation goes here
  
  properties
    r = zvector % direction of the inverse pole figure
  end
  
  methods
    
    function oM = ipdfOrientationMapping(varargin)
      oM = oM@orientationMapping(varargin{:});
      
      if isCS(oM.CS2), oM.r = Miller(oM.r,oM.CS2); end
      
    end
    
    function plot(oM,varargin)
      
      sR = oM.CS1.fundamentalSector(varargin{:});

      h = plotS2Grid(sR,'resolution',1*degree,varargin{:});
      
      d = oM.Miller2color(h);

      if numel(d) == 3*length(h)
        d = reshape(d,[size(h),3]);
        plotCMD = 'surf';
      else
        plotCMD = 'pcolor';
      end
      plot(h,d,'TR','',plotCMD,varargin{:});

      title([oM.CS1.mineral ' (' char(oM(1).r) ') inverse pole figure coloring'])
  
      % annotate crystal directions
      set(gcf,'tag','ipdf')
      setappdata(gcf,'CS',oM.CS1);
      h = Miller(unique(sR.vertices),oM.CS1);
      h.dispStyle = 'uvw';
      annotate(round(h),'MarkerFaceColor','k','labeled','symmetrised');

    end
        
    function rgb = orientation2color(oM,ori)
    
      % compute crystal directions
      h = inv(ori) .* oM.r;

      % colorize fundamental region
      rgb = Miller2color(oM,h);
      
    end
  end
  
  methods (Abstract = true)
    rgb = Miller2color(oM,h)
  end
end
