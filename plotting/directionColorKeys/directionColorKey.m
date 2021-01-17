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
      
      if nargin == 0, sym = specimenSymmetry; end
      
      if isa(sym,'symmetry')
        dM.sym = sym;
      else
        try
          dM.sym = sym.CS;
        catch
          error('No symmetry specified!')
        end
      end
      
      
      if check_option(varargin,'antipodal'), dM.sym = dM.sym.Laue; end
      
      dM.sR = dM.sym.fundamentalSector;
      
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
          
          axes = normalize(Miller({1,0,0},{0,1,0},{0,0,1},dM.sym,'uvw'));
          
          arrow3d(axes,'facecolor','gray')
          
          text3(axes(1),'$a$','horizontalAlignment','right')
          text3(axes(2),'$b$','verticalAlignment','cap','horizontalAlignment','left')
          text3(axes(3),'$c$','verticalAlignment','bottom')
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
