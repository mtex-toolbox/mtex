classdef ipfPlot < sphericalPlot
  % sphericalPlot is responsible for visualizing spherical data  
  
  properties
    r  % pole figure direction
    CS % crystal symmetry
    SS % specimen symmetry
  end
  
  methods
    
    function ipfP = ipfPlot(ax,CS,r,varargin)
  
      if nargin == 0, return;end
      
      sR = CS.fundamentalSector(varargin{:});
      proj = sphericalProjection.new(sR);
      ipfP = ipfP@sphericalPlot(ax,proj,varargin{:});
      ipfP.r = argin_check(r,'vector3d');
      ipfP.CS = CS;
      if ~check_option(varargin,'noTitle')
        mtexTitle(ax,char(r,'LaTeX'));
      end
      
      if ~check_option(varargin,'noLabel')
          
        h = sR.vertices;
        if length(unique(h,'antipodal')) <=2
          h = [h,xvector,yvector,zvector];
        else
          varargin = ['Marker','none',varargin];
        end
        h = Miller(unique(h),CS);
        switch CS.lattice
          case {'hexagonal','trigonal'}
            h.dispStyle = 'UVTW';
          otherwise
            h.dispStyle = 'uvw';
        end
        varargin = delete_option(varargin,'position');
        annotate(unique(round(h)),'MarkerFaceColor','k','labeled',...
          'symmetrised','backgroundcolor','w','autoAlignText',varargin{:},'doNotDraw');
      end
     
    end
    
    function unifyMarkerSize(pfP)
      % TODO: unifyMarkerSize
    end
  end
  
  methods (Static = true)
    function [ipfP,mtexFig,isNew] = new(CS,varargin)
      
      % set up pf plots, the following cases are distinguieshed
      %
      % 1: axis given and no pfPlot stored -> compute pfPlot -> generate as
      % many pfPlots as axes
      % 2: axis is hold and has pfPlot -> take this one
      % 3: new mtexFigure

      
      r = varargin{1};
      if ~iscell(r), r = vec2cell(r);end
     
      % case 1: predefined axes
      % -----------------------
      if check_option(varargin,'parent')
        
        isNew = false;
        ax = get_option(varargin,'parent');
        
        for i = 1:length(ax)
          current_ipfP = getappdata(ax(i),'sphericalPlot'); 
        
          % axis not yet a pole figure plot
          if isa(current_ipfP,'ipfPlot') && ishold(ax(i))
            ipfP(i) = current_ipfP; %#ok<AGROW>
          else
            % set up a new pfPlot
            ipfP(i) = ipfPlot(ax(i),CS,r{i},varargin{:}); %#ok<AGROW>
          end
        end        
        return;
      end
  
      % create a new mtexFigure or get a reference to it
      [mtexFig,isNew] = newMtexFigure(varargin{:});

      if isNew || ~isa(getappdata(mtexFig.children(1),'sphericalPlot'),'ipfPlot')

        holdState = getHoldState(mtexFig.gca);
        for i = 1:length(r)
          
          if i>1, mtexFig.nextAxis; end % create a new axis

          hold(mtexFig.gca,holdState);
          ipfP(i) = ipfPlot(mtexFig.gca,CS,r{i},varargin{:}); %#ok<AGROW>
          
        end
       
      else % add to or overide existing axes        
        for i = 1:numel(mtexFig.children)         
          ipfP(i) = getappdata(mtexFig.children(i),'sphericalPlot'); %#ok<AGROW>          
        end        
      end      
    end
  end
end
