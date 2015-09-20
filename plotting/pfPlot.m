classdef pfPlot < sphericalPlot
  % sphericalPlot is responsible for visualizing spherical data  
  
  properties
    h  % pole figure direction
    SS % specimen symmetry
  end
  
  methods
    
    function pfP = pfPlot(ax,SS,h,varargin)
  
      if nargin == 0, return;end
      
      pfP = pfP@sphericalPlot(ax,eareaProjection(fundamentalSector(SS,'upper',varargin{:})),varargin{:});
      pfP.h = argin_check(h,'Miller');
      pfP.SS = SS;
      if ~check_option(varargin,'noTitle')
        mtexTitle(ax,char(h,'LaTeX'));
      end      
      pfAnnotations = getMTEXpref('pfAnnotations');
      pfAnnotations('parent',pfP.ax,'doNotDraw');
      
    end
    
    function unifyMarkerSize(pfP)
      % TODO: unifyMarkerSize
    end
  end
  
  methods (Static = true)
    function [pfP,isNew] = new(SS,varargin)
      
      % set up pf plots, the following cases are distinguieshed
      %
      % 1: axis given and no pfPlot stored -> compute pfPlot -> generate as
      % many pfPlots as axes
      % 2: axis is hold and has pfPlot -> take this one
      % 3: new mtexFigure

      
      h = varargin{1};
      varargin(1) = [];
      if ~iscell(h), h = vec2cell(h);end
     
      % case 1: predefined axes
      % -----------------------
      if check_option(varargin,'parent')
        
        isNew = false;
        ax = get_option(varargin,'parent');
        
        for i = 1:length(ax)
          current_pfP = getappdata(ax(i),'sphericalPlot'); 
        
          % axis not yet a pole figure plot
          if isa(current_pfP,'pfPlots') && ishold(ax(i))
            pfP(i) = current_pfP; %#ok<AGROW>
          else
            % set up a new pfPlot
            pfP(i) = pfPlot(ax(i),SS,h{i},varargin{:}); %#ok<AGROW>
          end
        end        
        return;
      end
  
      % create a new mtexFigure or get a reference to it
      [mtexFig,isNew] = newMtexFigure(varargin{:});

      if isNew || ~isa(getappdata(mtexFig.children(1),'sphericalPlot'),'pfPlot')

        holdState = getHoldState(mtexFig.gca);
        for i = 1:length(h)
          
          if i>1, mtexFig.nextAxis; end % create a new axis

          hold(mtexFig.gca,holdState);
          pfP(i) = pfPlot(mtexFig.gca,SS,h{i},varargin{:}); %#ok<AGROW>
          
        end
       
      else % add to or overide existing axes        
        for i = 1:numel(mtexFig.children)         
          pfP(i) = getappdata(mtexFig.children(i),'sphericalPlot'); %#ok<AGROW>          
        end        
      end      
    end
  end
end
