classdef orientationPlot < handle
% ODFSECTIONS 
%
% Example
%
%   cs = crystalSymmetry('mmm')
%   oS = axisAngleSections(cs,cs)
%   ori = oS.makeGrid('resolution');
%   oM = PatalaColorKey(cs,cs)
%   rgb = oM.orientation2color(ori);
%   plot(oS,rgb,'surf')
%
%   hold on
%   ori = orientation.rand(100,cs,cs)
%   plot(oS,ori)
  
  properties
    CS1 % crystal symmetry of phase 1
    CS2 % crystal symmetry of phase 2
    antipodal = false
    ax
    fRMode % restrict2FundamentalRegion | project2FundamentalRegion | ignoreFundamentalRegion
    plotGrid
    gridSize
  end
  
  properties (Dependent=true)
    CS % crystal symmetry
    SS % specimen symmetry
  end
    
  methods
    function oP = orientationPlot(ax,CS1,varargin)
      oP.ax = ax;
      oP.CS1 = CS1.properGroup;
      CS2 = getClass(varargin,'symmetry',specimenSymmetry);
      oP.CS2 = CS2.properGroup;
      
      if oP.CS1 == oP.CS2
        oP.antipodal = check_option(varargin,'antipodal');
      end
      
      oP.fRMode = char(extract_option(varargin,...
        {'restrict2FundamentalRegion','project2FundamentalRegion','ignoreFundamentalRegion'}));
      if isempty(oP.fRMode)
        oP.fRMode = 'project2FundamentalRegion';
      end
      setappdata(oP.ax,'orientationPlot',oP);
    end
        
    function CS = get.CS(oS), CS = oS.CS1; end
    function SS = get.SS(oS), SS = oS.CS2; end    
  end

  methods (Abstract = true)
    makeGrid(oP,varargin)
    [x,y,z] = project(oP,ori)
    ori = iproject(oP,x,y,z)
  end
  
  methods 
    
    function h = plot(oP,ori,varargin)
      % plot orientations into 3d space

      % ensure correct symmetry
      if isa(ori,'orientation')
        ori = oP.CS1.ensureCS(ori);
      else
        ori = orientation(ori,oP.CS1,oP.CS2);
      end
      ori.antipodal = oP.antipodal;
      
      % extract data
      if nargin > 2 && isnumeric(varargin{1})
        data = varargin{1};
        varargin(1) = [];
      else
        data = [];
      end

      % subsample to reduce size
      if (length(ori) > 2000 && ~check_option(varargin,'all')) || check_option(varargin,'points')
        points = fix(get_option(varargin,'points',2000));
        disp(['plot ', int2str(points) ,' random orientations out of ', ...
          int2str(length(ori)),' given orientations']);
        [ori,ind] = discreteSample(ori,fix(points),'withoutReplacement');
        if ~isempty(data), data = data(ind); end
      end
      
      % convert to cartesian coordiantes
      [x,y,z] = oP.project(ori,varargin{:});
      
      % add some nans if lines are plotted
      if check_option(varargin,'edgecolor')
        d = sqrt(diff(x([1:end,1])).^2 + diff(y([1:end,1])).^2 + diff(z([1:end,1])).^2);
        ind = find(d > 10*quantile(d,0.5));
        for k = 1:numel(ind)
          x = [x(1:ind(k)+k-1);nan;x(ind(k)+k:end)];
          y = [y(1:ind(k)+k-1);nan;y(ind(k)+k:end)];
          z = [z(1:ind(k)+k-1);nan;z(ind(k)+k:end)];
        end
      end

      % colorize according to data
      if ~isempty(data)
        h = patch(x(:),y(:),z(:),1,...
          'facevertexcdata',data,...
          'markerfacecolor','flat',...
          'markeredgecolor','flat',...
          'FaceColor','none',...
          'EdgeColor','none',...
          'MarkerSize',get_option(varargin,'MarkerSize',getMTEXpref('markerSize')),...
          'Marker',get_option(varargin,'Marker','o'),...
          'parent',oP.ax);                
        
      else
        % colorize with a specified color
        if ~check_option(varargin,{'MarkerColor','MarkerFaceColor','data','MarkerEdgeColor','EdgeColor'})
          [~,c] = nextstyle(gca,true,true,~ishold(gca));
          varargin = [{'MarkerEdgeColor',c},varargin];
        end
        MEC = get_option(varargin,{'MarkerEdgeColor','MarkerColor'},'b');
        if check_option(varargin,'filled'), MFC = MEC; else, MFC = 'none'; end
        MFC = get_option(varargin,{'MarkerFaceColor','MarkerColor'},MFC);   
  
        h = patch(x(:),y(:),z(:),1,...
          'FaceColor','none',...
          'EdgeColor','none',...
          'MarkerFaceColor',MFC,...
          'MarkerEdgeColor',MEC,...
          'MarkerSize',get_option(varargin,'MarkerSize',getMTEXpref('markerSize')),...
          'Marker',get_option(varargin,'Marker','o'),...
          'parent',oP.ax);
  
        optiondraw(h,varargin{:});
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        
        % since the legend entry for patch object is not nice we draw an
        % invisible scatter dot just for legend
        if check_option(varargin,'DisplayName')
          holdState = get(oP.ax,'nextPlot');
          set(oP.ax,'nextPlot','add');
          optiondraw(scatter([],[],'parent',oP.ax,'MarkerFaceColor',MFC,...
            'MarkerEdgeColor',MEC),varargin{:});
          set(oP.ax,'nextPlot',holdState);
        end
        
        
      end

      if nargout == 0, clear h;end
      
    end
    
    function  varargout = contour3s(oP,data,varargin)
      
      % get contours
      contours = get_option(varargin,{'surf3','contour3'},10,'double');
      
      [varargout{1:nargout}] = contour3s(oP.plotGrid.x,oP.plotGrid.y,oP.plotGrid.z,data,contours,'surf3',varargin{:});
      %[varargout{1:nargout}] = contour3s(oP.plotGrid.x,oP.plotGrid.y,oP.plotGrid.z,data,contours,'contour3',varargin{:});
     
      
    end
    
  end
  
end
