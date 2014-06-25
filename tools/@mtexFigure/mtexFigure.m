classdef mtexFigure < handle
  
  properties
    parent            % the parent figure
    children          % the axes
    cBarAxis          % the colorbar axes
    outerPlotSpacing  % 
    innerPlotSpacing  %  
    keepAspectRatio   %
    nrows = 1         % number of rows
    ncols = 1         % number of columns
    axisWidth
    axisHeight
  end
  
  properties (Dependent = true)        
    axesWidth
    axesHeight
  end
  
  methods    
    
    function mtexFig = mtexFigure(varargin)

      % check whether the figure has to be cleared
      % ------------------------------------------
     
      % check hold state
      newFigure = ~isappdata(gcf,'mtexFig') || check_option(varargin,'newFigure') || ...
        (strcmp(getHoldState,'off') && ~check_option(varargin,'hold'));

      % check tag
      if ~newFigure && check_option(varargin,'ensureTag') && ...
          ~any(strcmpi(get(gcf,'tag'),get_option(varargin,'ensureTag')))
        newFigure = true;
        warning('MTEX:newFigure','Plot type not compatible to previous plot! I''going to create a new figure.');
      end

      % check appdata
      ad = get_option(varargin,'ensureAppdata');
      if ~newFigure
        try
          for i = 1:length(ad)
            if ~isappdata(gcf,ad{i}{1}) || (~isempty(ad{i}{2}) && ~all(getappdata(gcf,ad{i}{1}) == ad{i}{2}))
              newFigure = true;
              warning('MTEX:newFigure','Plot properties not compatible to previous plot! I''going to create a new figure.');
              break
            end
          end
        catch %#ok<CTCH>
          newFigure = true;
        end
      end

      % clear figure and set it up 
      if newFigure
                
        clf('reset');
        rmallappdata(gcf);

        iconMTEX(gcf);
        MTEXFigureMenu(varargin{:});

        % set tag
        if check_option(varargin,'ensureTag','char')
          set(gcf,'tag',get_option(varargin,'ensureTag'));
        end

        % set appdata
        if check_option(varargin,'ensureAppdata')
          for i = 1:length(ad)
            setappdata(gcf,ad{i}{1},ad{i}{2})
          end
        end

        % set figure name
        if ~isempty(get_option(varargin,'FigureTitle'))
          set(gcf,'Name',get_option(varargin,'FigureTitle'));
        end

        old_units = get(gcf,'units');
        set(gcf,'units','pixel');

        varargin = delete_option(varargin,'color',1);
        
        set(gcf,'units',old_units);
      
        % set custom resize function
        set(gcf,'ResizeFcn',@(src,evt) figResize(src,evt,mtexFig));

        mtexFig.parent = gcf;
        mtexFig.children = [];
        
        mtexFig.outerPlotSpacing = get_option(varargin,'outerPlotSpacing',...
          getMTEXpref('outerPlotSpacing'));
        mtexFig.innerPlotSpacing = get_option(varargin,'innerPlotSpacing',...
          getMTEXpref('innerPlotSpacing'));
        mtexFig.keepAspectRatio = get_option(varargin,'keepAspectRatio',true);
              
        % invisible axes for adding a colorbar
        mtexFig.cBarAxis = axes('visible','off','position',[0 0 1 1],...
          'tag','colorbaraxis','HandleVisibility','callback');

        % set correct colorrange for colorbar axis
        if check_option(varargin,{'logarithmic','log'})
          set(mtexFig.cBarAxis,'ZScale','log');
        end        
        set(mtexFig.parent,'currentAxes',mtexFig.cBarAxis);
        
        % bring invisible axis in back
        %ch = allchild(mtexFig.parent);
        %ch = [ch(ch ~= d);ch(ch == d)];
        %set(mtexFig.parent,'children',ch,'currentAxes',ch(1));
        
        
        set(mtexFig.parent,'color',[1 1 1],'nextPlot','replace');
        setappdata(mtexFig.parent,'mtexFig',mtexFig);        
        
        optiondraw(mtexFig.parent,varargin{:});
        
      else
        
        % get existing mtexFigure
        mtexFig = getappdata(gcf,'mtexFig');
        
        holdState = getHoldState;        
        % distribute hold state over all axes
        for i=1:numel(mtexFig.children)
          hold(mtexFig.children(i),holdState); 
        end
      end

     end
    
    function adjustFigurePosition(mtexFig)
      % determine optimal size
      
      screenExtend = get(0,'MonitorPositions');
      screenExtend = screenExtend(1,:); % consider only the first monitor
      screenExtend = screenExtend(3:4);
      
      % compute best partioning
      calcBestFit(mtexFig,'screen','maxWidth',300);
      
      % resize figure      
      width = mtexFig.axesWidth;
      height = mtexFig.axesHeight;
      position = [(screenExtend(1)-width)/2,(screenExtend(2)-height)/2,width,height];
      set(mtexFig.parent,'position',position);
      
    end
       
    function aw = get.axesWidth(mtexFig)
      % the width of all axes is the number of columns times the width of
      % each single axis + inner and outer spacing
      
      aw = mtexFig.ncols * mtexFig.axisWidth + ...
        2*mtexFig.outerPlotSpacing + ...
        (mtexFig.ncols-1) * mtexFig.innerPlotSpacing;
    end
    
    function ah = get.axesHeight(mtexFig)
      % the height of all axes is the number of rows times the height of
      % each single axis + inner and outer spacing
      
      ah = mtexFig.nrows * mtexFig.axisHeight + ...
        2*mtexFig.outerPlotSpacing + ...
        (mtexFig.nrows-1) * mtexFig.innerPlotSpacing;
    end

    
    
    function unifyMarkerSize(mtexFig)
      % ensure same marker size in all scatter plots
      
      if check_option(varargin,'unifyMarkerSize')
        ax = findobj(a,'tag','dynamicMarkerSize');
        if ~isempty(ax)
          markerSize = ensurecell(get(ax,'UserData'));
          set(ax,'UserData',min([markerSize{:}]));
        end
      end
    end
  end
end

