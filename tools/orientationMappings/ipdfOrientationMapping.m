classdef ipdfOrientationMapping < orientationMapping
  % defines an orientation mapping based on a certain inverse pole figure
  %   Detailed explanation goes here
  
  properties
    inversePoleFigureDirection
  end
  
  methods
    
    function oM = ipdfOrientationMapping(varargin)
      oM = oM@orientationMapping(varargin{:});
      
      if isa(oM.CS2,'crystalSymmetry')
        oM.inversePoleFigureDirection = Miller(oM.inversePoleFigureDirection,oM.CS2);
      else
        oM.inversePoleFigureDirection = zvector;
      end
      
    end
    
    function plot(oM,varargin)
      
      
      [mtexFig,isNew] = newMtexFigure(varargin);

      % init plotting grid
      sR = oM.CS1.fundamentalSector(varargin{:});
      h = plotS2Grid(sR,'resolution',1*degree,varargin{:});
      
      % compute colors
      d = oM.Miller2color(h);

      % plot the colored sector
      if numel(d) == 3*length(h)
        d = reshape(d,[size(h),3]);
        defaultPlotCMD = 'surf';
      else
        defaultPlotCMD = 'pcolor';
      end
      plot(h,d,defaultPlotCMD,varargin{:});
      if ~check_option(varargin,'noTitle')
        tt = mtexTitle(mtexFig.gca,char(oM(1).inversePoleFigureDirection));
        set(tt,'string',['IPF ' get(tt,'string')]);
      end
      
      if isempty(oM.CS1.mineral)
        name = ['"' oM.CS1.pointGroup '"'];
      else
        name = oM.CS1.mineral;
      end
      set(mtexFig.parent,'name',['Inverse pole figure coloring for ' name])      
      set(mtexFig.parent,'tag','ipdf')
      setappdata(mtexFig.parent,'CS',oM.CS1);
      setappdata(mtexFig.parent,'inversePoleFigureDirection',oM.inversePoleFigureDirection);
      
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
      elseif ~check_option(varargin,'noLabel')
        h = sR.vertices;
        if length(unique(h,'antipodal')) <=2, h = [h,xvector,yvector,zvector]; end
        h = Miller(unique(h),oM.CS1);
        switch oM.CS1.lattice
          case {'hexagonal','trigonal'}
            h.dispStyle = 'UVTW';
          otherwise
            h.dispStyle = 'uvw';
        end
        annotate(unique(round(h)),'MarkerFaceColor','k','labeled','symmetrised');
        mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
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
