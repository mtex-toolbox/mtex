classdef orientationPlot < handle
% ODFSECTIONS 
%
% Example
%
%   cs = crystalSymmetry('mmm');
%   oS = axisAngleSections(cs,cs);
%   ori = oS.makeGrid('resolution',2*degree);
%   oM = PatalaColorKey(cs,cs);
%   rgb = oM.orientation2color(ori);
%   plot(oS,rgb,'surf')
%   %
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
      CS2 = getClass(varargin,'symmetry',specimenSymmetry.default);
      oP.CS2 = CS2.properGroup;
      
      if oP.CS1 == oP.CS2
        oP.antipodal = check_option(varargin,'antipodal');
      end
      
      oP.fRMode = char(extract_option(varargin,...
        {'restrict2FundamentalRegion','project2FundamentalRegion','ignoreFundamentalRegion'}));
      if isempty(oP.fRMode) && ~check_option(varargin,'complete')
        oP.fRMode = 'project2FundamentalRegion';
      end
      setAllAppdata(oP.ax,'orientationPlot',oP);
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
    
    function ori = quiverGrid(oP,varargin)
      
      res = 60*degree / ((1+oP.antipodal)*length(oP.CS1.properGroup) * ...
        length(oP.CS2.properGroup))^(1/3);
      ori = localOrientationGrid(oP.CS1,oP.CS2,oP.oR.maxAngle-1*degree,...
        'resolution',res,varargin{:});
      
    end
    
    
    function h = plot(oP,ori,varargin)
      % plot orientations into 3d space

      % ensure correct symmetry
      if ~isa(ori,'orientation')
        ori = orientation(ori,oP.CS1,oP.CS2);
      elseif ~check_option(varargin,'noSymmetryCheck')
        try
          ori = oP.CS1.ensureCS(ori);
        end
      end
      ori.antipodal = oP.antipodal;
      
      % extract data
      if nargin > 2 && isnumeric(varargin{1})
        data = reshape(varargin{1},length(ori),[]);
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
        if ~isempty(data), data = data(ind,:); end
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

      MarkerSize = get_option(varargin,'MarkerSize',getMTEXpref('markerSize'));
      Marker = get_option(varargin,'Marker','o');

      % markers are drawn as scatter objects - only those support
      % MarkerFaceAlpha / MarkerEdgeAlpha and they are at least as fast as
      % patches. Lines (option 'edgecolor') remain patches since a scatter
      % object can not connect its points.
      isLine = check_option(varargin,'edgecolor');

      % marker transparency
      if check_option(varargin,{'MarkerAlpha','MarkerFaceAlpha','MarkerEdgeAlpha'})
        alphaArgs = {...
          'MarkerFaceAlpha',get_option(varargin,{'MarkerAlpha','MarkerFaceAlpha'},1),...
          'MarkerEdgeAlpha',get_option(varargin,{'MarkerAlpha','MarkerEdgeAlpha'},1)};
      else
        alphaArgs = {};
      end

      % colorize according to data
      if ~isempty(data)

        if isLine
          h = patch(x(:),y(:),z(:),1,...
            'facevertexcdata',data,...
            'markerfacecolor','flat',...
            'markeredgecolor','flat',...
            'FaceColor','none',...
            'EdgeColor','none',...
            'MarkerSize',MarkerSize,...
            'Marker',Marker,...
            'parent',oP.ax);
        else
          holdState = oP.ax.NextPlot; oP.ax.NextPlot = 'add';
          h = scatter3(x(:),y(:),z(:),MarkerSize.^2,data,'filled',...
            'MarkerEdgeColor','flat','Marker',Marker,'parent',oP.ax,alphaArgs{:});
          oP.ax.NextPlot = holdState;
        end

      else
        % colorize with a specified color
        if ~check_option(varargin,{'MarkerColor','MarkerFaceColor','data','MarkerEdgeColor','EdgeColor'})
          [~,c] = nextstyle(gca,true,true,~ishold(gca));
          varargin = [{'MarkerEdgeColor',c},varargin];
        end
        MEC = str2rgb(get_option(varargin,{'MarkerEdgeColor','MarkerColor'},[0, 0.4470, 0.7410]));
        if check_option(varargin,'filled'), MFC = MEC; else, MFC = 'none'; end
        MFC = str2rgb(get_option(varargin,{'MarkerFaceColor','MarkerColor'},MFC));
  
        if isLine
          h = patch(x(:),y(:),z(:),1,...
            'FaceColor','none',...
            'EdgeColor','none',...
            'MarkerFaceColor',MFC,...
            'MarkerEdgeColor',MEC,...
            'MarkerSize',MarkerSize,...
            'Marker',Marker,...
            'parent',oP.ax);
        else
          holdState = oP.ax.NextPlot; oP.ax.NextPlot = 'add';
          h = scatter3(x(:),y(:),z(:),MarkerSize.^2,...
            'MarkerFaceColor',MFC,'MarkerEdgeColor',MEC,'Marker',Marker,...
            'parent',oP.ax,alphaArgs{:});
          oP.ax.NextPlot = holdState;
        end

        optiondraw(h,varargin{:});
        
        % scatter objects have a proper legend entry - show it only if a
        % DisplayName was requested
        if ~isLine && ~check_option(varargin,'DisplayName')
          set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
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
