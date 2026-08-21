classdef sphericalPlot < handle
  % sphericalPlot is responsible for visualizing spherical data  
  
  properties
    proj = sphericalProjection
    boundary %
    bounds   %
    grid     %
    ticks    %
    labels     % Miller indices at the vertices of the spherical region
    axesLabels % X / Y / Z of the reference frame
    ax       % axis
    parent   % the figure that contains the spherical plot
    hemispheres % the halves this plot consists of, see allHemispheres
    TL       %
    TR       %
    BL       %
    BR       %
    minData = NaN
    maxData = NaN
    dispMinMax = false
  end
  
  properties (Dependent = true)
    sphericalRegion % spherical region
    antipodal       % antipodal symmetry
  end
  
  methods
    
    function sP = sphericalPlot(ax,proj,varargin)
  
      if nargin == 0, return;end
      
      % maybe there is already a spherical plot
      if isappdata(ax,'sphericalPlot') && ~ishold(ax)
        sP = getappdata(ax,'sphericalPlot');
        return
      end
      
      sP.ax = ax;    
      sP.parent = ax.Parent;
      sP.proj = proj;
      sP.hemispheres = sP;
      sP.dispMinMax = check_option(varargin,'minmax');
      setAllAppdata(ax,'sphericalPlot',sP);
      
      % the boundary, the grid and all the labels have to accumulate into ax
      hG = holdOn(ax); %#ok<NASGU>

      CS = getClass(varargin,'crystalSymmetry',[]);
      
      if isa(sP.proj,'plainProjection')
        
        % boundary
        sP.updateBounds;
        axis(ax,'on');
        set(ax,'box','on','FontSize',getMTEXpref('FontSize'));
        
        % grid
        sP.plotPlainGrid(varargin{:});

        % set view point
        %setCamera(sP.ax,'default',varargin{:});

      else

        %axis(ax,'on');
        %xlabel(ax,[],'visible','on','color','k');
        %ylabel(ax,[],'visible','on','color','k');
        
        % plot boundary
        sP.boundary = sP.sphericalRegion.plot('parent',sP.ax,varargin{:});

        sP.updateBounds;

        % plot grid, labels, ..
        try sP.plotPolarGrid(varargin{:});end
        sP.doBoundaryInFront;
        sP.plotLabels(CS,varargin{:});
        sP.plotAxesLabels(CS,varargin{:});

        %sP.updateBounds;

        ax.XTick = []; ax.YTick = [];
        try
          set(ax,'XColor','none','YColor','none');
          xlabel(ax,[],'visible','on','color','k');
          ylabel(ax,[],'visible','on','color','k');
        end
        
        if ~check_option(varargin,'grid')
          set(sP.grid,'visible','off');
        end

      end

      plotAnnotate(sP,varargin{:});

      clear hG

    end

    function sPall = allHemispheres(sP)
      % all halves of the plot sP belongs to, sP included
      %
      % A region that covers the upper as well as the lower hemisphere is
      % drawn into two axes - but it remains a single plot. Data added to
      % it later belongs to both halves, each of which then shows the part
      % of it that falls into its hemisphere. newSphericalPlot registers
      % the halves with each other when it creates them, everybody else
      % asks here.

      sPall = sP(1).hemispheres;

      % drop halves whose axis has been deleted in the meantime
      if ~isempty(sPall), sPall = sPall(isgraphics([sPall.ax],'axes')); end

      % a plot restored from a figure saved before the halves were
      % registered has none - it is then a plot on its own
      if isempty(sPall), sPall = sP(1); end

    end

    function updateMinMax(sP,data)
      if nargin == 2
        sP.minData = min([sP.minData, min(data(:))]);
        sP.maxData = max([sP.maxData, max(data(:))]);
      end
      
      if sP.dispMinMax
        sP.TL.String = {'Max:',xnum2str(sP.maxData)};
        sP.BL.String = {'Min:',xnum2str(sP.minData)};
        sP.TL.Visible = 'on'; sP.BL.Visible = 'on';
      else
        sP.TL.Visible = 'off'; sP.BL.Visible = 'off';
      end
    end
    
    function plotAnnotate(sP,varargin)
      % tl tr bl br
    
      t.TL = get_option(varargin,{'TopLeft','TL'},'');
      t.TR = get_option(varargin,{'TopRight','TR'},'');
      t.BL = get_option(varargin,{'BottomLeft','BL'},'');
      t.BR = get_option(varargin,{'BottomRight','BR'},'');
      
      t = structfun(@(x) st2char(x), t,'UniformOutput',false);

      m = 0.005;
      if strcmpi(getMTEXpref('textInterpreter'),'LaTex')
        b = 0.015;
      else
        b = 0;
      end

      if isempty(sP.TL)
        options = {'parent',sP.ax,'units','normalized',...
          'FontName','times','FontSize',getMTEXpref('FontSize'),...
          'interpreter',getMTEXpref('textInterpreter','latex')};
        sP.TL = text(0+m,1-b,t.TL,options{:});
        sP.TR = text(1-m,1-b,t.TR,options{:});
        sP.BL = text(0+m,0+b,t.BL,options{:});
        sP.BR = text(1-m,0+b,t.BR,options{:});
        
        set([sP.TL sP.TR],'VerticalAlignment','top');
        set([sP.BL sP.BR],'VerticalAlignment','bottom');
        set([sP.TL sP.BL],'HorizontalAlignment','left');
        set([sP.TR sP.BR],'HorizontalAlignment','right');

      else
        if ~isempty(t.TL), sP.TL.String = t.TL; sP.TL.Visible = "on"; end
        if ~isempty(t.BL), sP.BL.String = t.BL; sP.BL.Visible = "on"; end
        if ~isempty(t.TR), sP.TR.String = t.TR; sP.TR.Visible = "on"; end
        if ~isempty(t.BR), sP.BR.String = t.BR; sP.BR.Visible = "on"; end        
      end
      

      function s = st2char(t)

        if isa(t,'cell') && isscalar(t), t = t{1};end
        if isa(t,'vector3d')
          for i = 1:length(t)

            s{i} = char(t(i),getMTEXpref('textInterpreter')); %#ok<AGROW>

          end
        else
          if iscell(t)
            s = t;
          elseif ~ischar(t)
            s = char(t);
          else
            s = t;
          end
          if strcmpi(getMTEXpref('textInterpreter'),'LaTex')
            if ~iscell(s) && ~isempty(regexp(s,'[\\\^_]','ONCE')) && s(1)~='$'
              s = ['$' s '$'];
            end
          end
        end
      end
    end
    
    function sR = get.sphericalRegion(sP)
      sR = sP.proj.sR;
    end   
    
    function doLabelsInFront(sP)
      % the labels are created together with the axis, i.e. before any
      % data, and would hence be covered by it - move them back to the
      % front. Data that is drawn as a filled area brings the entire grid
      % in front instead, see doGridInFront

      h = [sP.axesLabels(:); sP.labels(:)];
      h = h(isgraphics(h));
      if isempty(h), return; end

      childs = allchild(sP.ax);
      sP.ax.Children = [h; childs(~ismember(childs,h))];

    end

    function doBoundaryInFront(sP)
      % the grid is drawn after the boundary and hence covers it. Since
      % the small circle at the border of the plotted region coincides
      % with the boundary exactly - and so do the meridians along the
      % edges of a fundamental sector - the light grey grid line paints
      % out the middle of the much thicker boundary line, leaving only
      % its two antialiased flanks: the boundary then reads as two very
      % thin circles instead of one thick one.

      if isempty(sP.boundary), return; end

      childs = allchild(sP.ax);
      isBoundary = ismember(childs,sP.boundary(:));
      sP.ax.Children = [childs(isBoundary); childs(~isBoundary)];

    end

    function doGridInFront(sP)

      if ~isempty(sP.grid)
        childs = allchild(sP.ax);
  
        isgrid = ismember(childs,[sP.grid(:);sP.boundary(:)]);
        istext = isgraphics(childs,'text');
        isLine = isgraphics(childs,'line');
  
        sP.ax.Children = [childs(istext); sP.boundary(:); sP.grid(:);...
          childs(isLine & ~isgrid & ~istext);childs(~isLine & ~isgrid & ~istext)];
      end
    end
    
    
    function updateBounds(sP,delta)
      % compute bounding box

      if nargin == 1, delta = 0.02; end
      
      if isa(sP.proj,'plainProjection')
      
        sP.bounds = sP.sphericalRegion.polarRange / degree;
        sP.bounds(3:4) = fliplr(sP.bounds(3:4));
        
      else
      
        x = [sP.boundary.XData];
        y = [sP.boundary.YData];
        sP.bounds = [min(x(:)),min(y(:)),max(x(:)),max(y(:))];
      
      end
        
      % set bounds to axes
      delta = min(sP.bounds(3:4) - sP.bounds(1:2))*delta ;
      sP.bounds = sP.bounds + [-1 -1 1 1] * delta;
            
      set(sP.ax,'DataAspectRatio',[1 1 1],'XLim',...
        sP.bounds([1,3]),'YLim',sP.bounds([2,4]));

    end
    
  end
  
  methods (Access = private)
  
    function plotPlainGrid(sP,varargin)
      
      % the ticks
      polarRange = sP.sphericalRegion.polarRange;
      theta = round(linspace(polarRange(1),polarRange(3),4)/degree);
      rho = round(linspace(polarRange(2),polarRange(4),4)/degree);            
      
      sP.ax.XTick = rho; sP.ax.YTick = theta;
      if strcmpi(get_option(varargin,'coordinates','on'),'off')
        sP.ax.XTickLabel = {};
        sP.ax.YTickLabel = {};
        sP.ax.TickLength = [0,0];
      end

      % the labels
      interpreter = getMTEXpref('textInterpreter');
      fs = getMTEXpref('FontSize');
      
      onoff = get_option(varargin,'labels','on');
      xlabel(sP.ax,get_option(varargin,'xlabel','rho'),...
        'interpreter',interpreter,'FontSize',fs,'visible',onoff);
      ylabel(sP.ax,get_option(varargin,'ylabel','theta'),...
        'interpreter',interpreter,'FontSize',fs,'visible',onoff);
      
    end

    function plotPolarGrid(sP,varargin)
      
      % stepsize
      dgrid = get_option(varargin,'grid_res',30*degree);
      dgrid = pi/round((pi)/dgrid);
      
      % draw small circles
      theta = dgrid:dgrid:pi-dgrid;
      
      for i = 1:length(theta), circ(sP,theta(i)); end
      
      % draw meridians
      plotMeridians(sP,0:dgrid:pi-dgrid);

    end

    
    function plotMeridians(sP,rho,varargin)

      % the points
      theta = linspace(-pi,pi,361);
      
      [theta,rho] = meshgrid(theta,rho);
      v =  vector3d.byPolar(theta,rho);
      [x,y] = project(sP.proj,v.','noAntipodal');

      % grid
      sP.grid = [sP.grid(:);line(x,y,'parent',sP.ax,...
        'handlevisibility','off','color',[.8 .8 .8])];
      
    end
    
    function circ(sP,theta,varargin)

      % the points to plot      
      v = vector3d.byPolar(theta,linspace(0,2*pi,721));
            
      % project
      [x,y] = sP.proj.project(v,'noAntipodal');

      %d = sqrt(diff(x([1:end,1])).^2 + diff(y([1:end,1])).^2);
      %ind = find(d > diff(sP(i).bounds([1,3])) / 20);

      % plot
      sP.grid(end+1) = line(x,y,'parent',sP.ax,...
        'handlevisibility','off','color',[.8 .8 .8]);

    end    
    
    function plotLabels(sP,CS,varargin)

      if check_option(varargin,'noLabel') || isempty(CS), return; end

      sR = sP.sphericalRegion;
      h = Miller(unique(sR.vertices),CS);

      % a full sphere has no sector vertices, so take the fundamental sector's,
      % in all their symmetrically equivalent positions inside the region
      hasVertices = ~isempty(h);
      if ~hasVertices
        h = fundamentalSector(CS).vertices;
        if isempty(h), return; end
        h = Miller(unique(h),CS);
        h.antipodal = false;
        h = unique(symmetrise(h),'noSymmetry');
        h = h(sR.checkInside(h,'noAntipodal'));
        h = h(ismembertol(h.theta,[0,pi/2,pi],1*degree));
        if isempty(h), return; end
      end

      % try direct coordinates
      h.dispStyle = MillerConvention(abs(MillerConvention(h.dispStyle)));

      % if this gives no integer values - go to reciprocal coordinates
      if any(angle(round(h),h)>1e-5)
        h.dispStyle = MillerConvention(-MillerConvention(h.dispStyle));
      end
      h = round(h);
      
      if hasVertices
        sP.labels = [sP.labels,scatter(h,'MarkerFaceColor','k',...
        'labeled','Marker','none',...
        'backgroundcolor','w','autoAlignText','parent',sP.ax,'doNotDraw')];
      else
        sP.labels = [sP.labels,text(h,'labeled','backgroundcolor','w',...
        'parent',sP.ax,'doNotDraw')];
      end

    end

    function plotAxesLabels(sP,CS,varargin)
      % annotate the directions of the reference frame the way pole figures
      % do - see annotateFrame, which the three dimensional plots that
      % never build a sphericalPlot share with us

      if ~isempty(CS), return; end

      sP.axesLabels = [sP.axesLabels(:); annotateFrame(sP.ax,varargin{:})];

    end
  end
end

