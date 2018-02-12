classdef directionColorKey < handle
  % converts directions to rgb values
    
  properties
    colorPostRotation = rotation.id
    sR = sphericalRegion
    sym % 
  end

  properties %(Access = hidden)
    dir2color % function handle
  end
  
  methods
    
    function dM = directionColorKey(sym,varargin)
      dM.sym = sym;
      dM.sR = sym.fundamentalSector;
      
      dM.dir2color = get_option(varargin,'dir2color');

    end
    
    function [h,caxes] = plot(dM,varargin)
      
      
      [mtexFig,isNew] = newMtexFigure(varargin{:});

      % init plotting grid
      v = plotS2Grid(dM.sym.fundamentalSector,'resolution',1*degree,varargin{:});
      
      % make it Miller for crystal symmetry
      if isa(dM.sym,'crystalSymmetry'), v = Miller(v,dM.sym); end
            
      % compute colors
      d = dM.direction2color(v);

      % plot the colored sector
      if numel(d) == 3*length(v)
        d = reshape(d,[size(v),3]);
        defaultPlotCMD = 'surf';
      else
        defaultPlotCMD = 'pcolor';
      end
      
      [h,caxes] = plot(v,d,defaultPlotCMD,varargin{:});
            
      setappdata(caxes,'CS',dM.sym);
            
      % annotate crystal directions
      if check_option(varargin,'3d')
        if ~check_option(varargin,'noLabel')
          hold on
          gray = [0.4 0.4 0.4];
          arrow3d(dM.sym.axes(1),'facecolor',gray)
          text3(Miller(1,0,0,'uvw',dM.sym),'a_1','horizontalAlignment','right')
          
          arrow3d(dM.sym.axes(2),'facecolor',gray)
          text3(Miller(0,1,0,'uvw',dM.sym),'a_2','verticalAlignment','cap','horizontalAlignment','left')
          
          arrow3d(dM.sym.axes(3),'facecolor',gray)
          text3(Miller(0,0,1,'uvw',dM.sym),'c','verticalAlignment','bottom')
          hold off
        end
        if isNew, fcw; end                
      end
      
      try
        mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
      end
      
      if nargout == 0, clear h caxes; end
    end        
   
    function rgb = direction2color(oM,h,varargin)
      rgb = oM.dir2color(h,varargin{:});
    end
  
  end

end
