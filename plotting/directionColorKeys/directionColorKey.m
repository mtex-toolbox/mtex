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
      
      if nargin == 0, sym = specimenSymmetry.default; end
      
      if isa(sym,'symmetry')
        dM.sym = sym;
      else
        try
          dM.sym = sym.CS;
        catch
          dM.sym = specimenSymmetry.default;
          try %#ok<TRYNC>
            % fork first - specimenSymmetry.default is the shared session
            % symmetry, so assigning the caller's frame onto it would move
            % the whole session
            if ~isempty(sym.frame)
              dM.sym = copy(dM.sym);
              dM.sym.frame = sym.frame;
            end
          end
          %error('No symmetry specified!')
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
            
      setAllAppdata(caxes,'CS',dM.sym);
            
      % annotate crystal directions
      if check_option(varargin,'3d')
        if ~check_option(varargin,'noLabel')
          hG = holdOn(gca); %#ok<NASGU>
          
          if isa(dM.sym,'crystalSymmetry')
            axes = normalize(Miller({1,0,0},{0,1,0},{0,0,1},dM.sym,'uvw'));
            labels = {'$a$' '$b$' '$c$'};  
          else
            axes = [xvector,yvector,zvector];
            labels = {'$x$' '$y$' '$z$'};
          end
          
          arrow3d(axes,'facecolor','gray')
          
          text3(axes(1),labels{1},'horizontalAlignment','right')
          text3(axes(2),labels{2},'verticalAlignment','cap','horizontalAlignment','left')
          text3(axes(3),labels{3},'verticalAlignment','bottom')

          clear hG
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

    function display(dM,varargin)
      % standard output
      %
      % A direction key colors one reference system, so the header names
      % it, as @orientationColorKey names the pair. Below it the settings
      % that change the colors - above all the layout of the fundamental
      % sector, which is where the colors are laid out and which belongs
      % to the frame of the symmetry, not to the session.

      displayClass(dM(1),inputname(1),'moreInfo',char(dM(1).sym,'compact'),varargin{:});

      if ~isscalar(dM)
        disp(['  size: ' size2str(dM)]);
        disp(' ');
        return
      end

      if ~check_option(varargin,'skipHeader'), disp(' '); end

      props = {}; propV = {};

      % sphericalRegion/polarCoordinates measures the hue from
      % sR.how2plot.outOfScreen, so this line says which way round the
      % colors run - in the axes names of the frame, e.g. 'c↑→a'
      fr = dM.sR.frame;
      if isa(fr,'referenceFrame')
        c = conventionChar(fr,dM.sR.how2plot);
        if ~isempty(c)
          props{end+1} = 'color layout'; propV{end+1} = c; %#ok<AGROW>
        end
      end

      if angle(dM.colorPostRotation) > 1e-10
        props{end+1} = 'post rotation'; %#ok<AGROW>
        propV{end+1} = [xnum2str(angle(dM.colorPostRotation)/degree) '°']; %#ok<AGROW>
      end

      [p,v] = keyRows(dM);
      props = [props,p]; propV = [propV,v];

      % the discretized map is reused for a whole session, so whether it
      % is in place is worth seeing when colors are in question
      if ~isempty(dM.dir2color)
        props{end+1} = 'color grid'; propV{end+1} = 'precomputed';
      end

      if ~isempty(props)
        cprintf(propV(:),'-L','  ','-ic','L','-la','L','-Lr',props,'-d',': ');
        disp(' ');
      end

    end

    function [props,propV] = keyRows(~)
      % the rows a concrete direction key adds to its display

      props = {}; propV = {};
    end

  end

end
