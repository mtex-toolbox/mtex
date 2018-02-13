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
      
      
      [mtexFig,isNew] = newMtexFigure(varargin{:});

      % init plotting grid
      sR = getClass(varargin,'sphericalRegion',oM.CS1.fundamentalSector(varargin{:}));
      h = Miller(plotS2Grid(sR,'resolution',1*degree,varargin{:}),oM.CS1);
      
      % compute colors
      d = oM.Miller2color(h);

      % plot the colored sector
      if numel(d) == 3*length(h)
        d = reshape(d,[size(h),3]);
        defaultPlotCMD = 'surf';
      else
        defaultPlotCMD = 'pcolor';
      end
      mtexTitle(mtexFig.gca,char(oM.inversePoleFigureDirection,'LaTeX'),varargin{:});
      [~,caxes] = plot(h,d,defaultPlotCMD,varargin{:});
            
      name = oM.CS1.pointGroup;
      if ~isempty(oM.CS1.mineral), name = [oM.CS1.mineral ' (' name ')']; end
        
      set(mtexFig.parent,'name',['IPF key for ' name])      
      set(caxes,'tag','ipdf')
      setappdata(caxes,'CS',oM.CS1);
      setappdata(caxes,'inversePoleFigureDirection',oM.inversePoleFigureDirection);
      
      % annotate crystal directions
      if check_option(varargin,'3d')
        if ~check_option(varargin,'noLabel')
          hold on
          gray = [0.4 0.4 0.4];
          arrow3d(oM.CS1.axes(1),'facecolor',gray)
          text3(Miller(1,0,0,'uvw',oM.CS1),'a_1','horizontalAlignment','right')
          
          arrow3d(oM.CS1.axes(2),'facecolor',gray)
          text3(Miller(0,1,0,'uvw',oM.CS1),'a_2','verticalAlignment','cap','horizontalAlignment','left')
          
          arrow3d(oM.CS1.axes(3),'facecolor',gray)
          text3(Miller(0,0,1,'uvw',oM.CS1),'c','verticalAlignment','bottom')
          hold off
        end
        if isNew, fcw; end                
      end
      
      try
        mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
      end

    end
        
    function rgb = orientation2color(oM,ori)
    
      if ~(ori.CS.properSubGroup <= oM.CS1)
        warning('The symmetry of the ipf key and the orientations does not fit.')
      end
      
      % compute crystal directions
      ori.CS = oM.CS1;
      h = inv(ori) .* oM.inversePoleFigureDirection;
      
      % colorize fundamental region
      rgb = Miller2color(oM,h);
      
    end
  end
  
  methods (Abstract = true)
    rgb = Miller2color(oM,h)
  end
end
