function [h,ax] = scatter(v,varargin)
%
% Syntax
%   scatter(v)              % plot the directions v
%   scatter(v,data)         % colorize directions according to data
%   scatter(v,'label',text) % plot text below markers
%   scatter(v,'label',text,'textaboveMarker') % plot text above markers
%   scatter(v,'numbered')   % plot directions with numbers
%
% Input
%  v     - @vector3d
%  data  - double
%  rgb   - a list of rgb color values
%
% Options
%  Marker            - 's','o','diamond','p'
%  MarkerFaceColor   - 'r','g','w','k','b'
%  MarkerEdgeColor   - 'r','g','w','k','b'
%  MarkerColor       - shortcut for the above two
%  MarkerSize        - size of the markers in pixel
%  MarkerAlpha       - transparency setting
%  MarkerEdgeAlpha   - transparency setting
%  MarkerFaceAlpha   - transparency setting
%  DynamicMarkerSize - scale marker size when plot is resized
%  Grid              - whether to display a grid 
%  grid_res          - resolution of the grid to be displayed 
%
% Output
%
% See also
% vector3d/text

% initialize spherical plots
opt = delete_option(varargin,...
  {'lineStyle','lineColor','lineWidth','color','edgeColor','MarkerSize','Marker','MarkerFaceColor','MarkerEdgeColor','MarkerColor'},1);
[sP, isNew] = newSphericalPlot(v,opt{:},'doNotDraw');
varargin = delete_option(varargin,'parent',1);

h = gobjects(1,numel(sP));
for i = 1:numel(sP)

  % project data
  [x,y] = project(sP(i).proj,v,varargin{:});

  % check that there is something left to plot
  %if all(isnan(x) | isnan(y)), continue; end
    
  % add some nans if lines are plotted
  if check_option(varargin,'edgecolor')
    
    x = x(:); y = y(:);
    % find large gaps
    d = sqrt(diff(x([1:end,1])).^2 + diff(y([1:end,1])).^2);
    ind = find(d > diff(sP(i).bounds([1,3])) / 20);
    
    % and fill the gaps with nans
    for k = 1:numel(ind)
      x = [x(1:ind(k)+k-1);nan;x(ind(k)+k:end)];
      y = [y(1:ind(k)+k-1);nan;y(ind(k)+k:end)];
    end
  end
  
  % default arguments
  patchArgs = {'parent',sP(i).ax,...
    'vertices',[x(:) y(:)],...
    'faces',1:numel(x),...
    'facecolor','none',...
    'edgecolor','none',...
    'marker','o',...
    };

  % markerSize
  if ~check_option(varargin,{'scatter_resolution','MarkerSize'})
    res = max(v.resolution,0.5*degree);
  else
    res = get_option(varargin,'scatter_resolution',1*degree);
  end
  MarkerSize  = get_option(varargin,'MarkerSize',min(getMTEXpref('markerSize'),50*res));
  
  patchArgs = [patchArgs,{'MarkerSize',MarkerSize}]; %#ok<AGROW>

  % dynamic marker-size
  if ~check_option(varargin,'MarkerSize') && ...
      (check_option(varargin,'dynamicMarkerSize') || length(v)>20)
    patchArgs = [patchArgs {'tag','dynamicMarkerSize','UserData',MarkerSize}]; %#ok<AGROW>
  end
    
  % ------------- color-coding according to the first argument ----------------
  if ~isempty(varargin) && isa(varargin{1},'crystalShape')
    
    h(i) = plot(x,y,varargin{1}.diameter,varargin{1},'parent', sP(i).ax,varargin{2:end});
    %sP(i).updateBounds(0.1);
  
  elseif check_option(varargin,'arrow')
    
    x(isnan(x)) = [];
    y(isnan(y)) = [];
    if length(x)>1
      arrowOpt = extract_option(varargin,{'length','baseAngle','tipAngle',...
        'Width','Page','Ends','type','color'},...
        {'double','double','double',...
        'double','double','char','char','double'});
      h(i) = arrow([x(1),y(1)],[x(2),y(2)],arrowOpt{:});
      h(i).Parent = sP(i).ax;
    end

  elseif ~isempty(varargin) && isnumeric(varargin{1}) && ~isempty(varargin{1})
      
    % extract color coding
    cdata = varargin{1};
    if numel(cdata) == length(v)
      cdata = reshape(cdata,[],1);
      sP(i).updateMinMax(cdata);
    else
      cdata = reshape(cdata,[],3);
    end

    if numel(MarkerSize) > 1
      
      ish = ishold(sP(i).ax);
      if ~ish, hold(sP(i).ax); end
      h(i) = optiondraw(scatter(x(:),y(:),MarkerSize(:),cdata,'filled',...
        'parent',sP(i).ax),varargin{:});
      if ~ish, hold(sP(i).ax); end
      

      h(i).Annotation.LegendInformation.IconDisplayStyle = "off";
            
    else % draw patches
    
      h(i) = optiondraw(patch(patchArgs{:},...
        'facevertexcdata',cdata,...
        'markerfacecolor','flat',...
        'markeredgecolor','flat'),varargin{2:end});
      h(i).Annotation.LegendInformation.IconDisplayStyle = "off";
      
    end
      
  else % --------- colorcoding according to nextStyle -----------------
    
    % get colors
    mfc = str2rgb(get_option(varargin,'MarkerColor'));
    mfc = str2rgb(get_option(varargin,'MarkerFaceColor',mfc));
    if ~ischar(mfc) || ~strcmpi(mfc,'none')
      mec = mfc;
    else
      mec = [];
    end
    mec = str2rgb(get_option(varargin,'MarkerEdgeColor',mec));
      
    if isempty(mfc) || isempty(mec)  % cycle through colors
      [ls,nextColor] = nextstyle(sP(i).ax,true,true,~ishold(sP(i).ax)); %#ok<ASGLU>
      
      if isempty(mfc), mfc = nextColor; end
      if isempty(mec), mec = nextColor; end
            
    end
  
    % draw patches
    if numel(MarkerSize) > 1
      
      h(i) = optiondraw(scatter(x(:),y(:),MarkerSize(:),'parent',sP(i).ax,...
        'MarkerFaceColor',mfc,'MarkerEdgeColor',mec),varargin{:});
    
    else
       
      h(i) = optiondraw(patch(patchArgs{:},...
        'MarkerFaceColor',mfc,...
        'MarkerEdgeColor',mec),varargin{:});
      
      % remove from legend
      
      h(i).Annotation.LegendInformation.IconDisplayStyle = "off";      

      % add transparency if required
      if check_option(varargin,{'MarkerAlpha','MarkerFaceAlpha','MarkerEdgeAlpha'})
        
        faceAlpha = round(255*get_option(varargin,{'MarkerAlpha','MarkerFaceAlpha'},1));
        edgeAlpha = round(255*get_option(varargin,{'MarkerAlpha','MarkerEdgeAlpha'},1));
        
        % we have to wait until the markers have been drawn
        mh = [];
        while isempty(mh)
          pause(0.01);
          mh = [h(i).MarkerHandle];
        end
                
        for j = 1:length(mh)
          mh(j).FaceColorData(4,:) = faceAlpha; %#ok<AGROW>
          mh(j).FaceColorType = 'truecoloralpha'; %#ok<AGROW>
          
          mh(j).EdgeColorData(4,:) = edgeAlpha; %#ok<AGROW>
          mh(j).EdgeColorType = 'truecoloralpha'; %#ok<AGROW>
        end
         
      end
      
      % since the legend entry for patch object is not nice we draw an
      % invisible scatter dot just for legend
      if check_option(varargin,'DisplayName')
        
        holdState = sP(i).ax.NextPlot;
        sP(i).ax.NextPlot = "add";
        if check_option(varargin,'edgecolor')
          line([NaN NaN],[NaN NaN],'color',str2rgb(get_option(varargin,'edgecolor')),...
          'parent',sP(i).ax,'DisplayName',get_option(varargin,'DisplayName'),...
          'linewidth',h(1).LineWidth);
        else
          optiondraw(scatter([],[],'parent',sP(i).ax,'MarkerFaceColor',mfc,...
            'MarkerEdgeColor',mec),varargin{:});
        end
        sP(i).ax.NextPlot = holdState;
      end
    end
  end

  % set resize function for dynamic marker sizes
  if ~check_option(varargin,{'MarkerAlpha','MarkerFaceAlpha','MarkerEdgeAlpha'})
    try
      hax = handle(sP(i).ax);
      hListener(1) = handle.listener(hax, findprop(hax, 'Position'), ...
        'PropertyPostSet', {@localResizeScatterCallback,sP(i).ax});
      % save listener, otherwise  callback may die
      setAllAppdata(hax, 'dynamicMarkerSizeListener', hListener);
    catch
      if ~isappdata(hax, 'dynamicMarkerSizeListener')
        hListener = addlistener(hax,'Position','PostSet',...
          @(obj,events) localResizeScatterCallback(obj,events,sP(i).ax));
        %      localResizeScatterCallback([],[],sP(i).ax);
        setAllAppdata(hax, 'dynamicMarkerSizeListener', hListener);
      end
      %disp('some Error!');
    end
  end

  % plot labels
  if check_option(varargin,'numbered')
    text(v,arrayfun(@int2str,1:length(v),'UniformOutput',false),'parent',sP(i).ax,...
      'addMarkerSpacing',varargin{:},'doNotDraw');
    localResizeScatterCallback([],[],sP(i).ax);
  elseif check_option(varargin,{'text','label','labeled'})
    text(v,get_option(varargin,{'text','label'}),'parent',sP(i).ax,...
      'addMarkerSpacing',varargin{:},'doNotDraw');
    localResizeScatterCallback([],[],sP(i).ax);
  end
  
end

% with opengl markers with thick boundary look ugly
if get_option(varargin,'linewidth',0) > 3 && ~check_option(varargin,'edgecolor')
  set(gcf,'Renderer','painters');
end

if isappdata(sP(1).parent,'mtexFig') && isNew
  mtexFig = getappdata(sP(1).parent,'mtexFig');
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
end

if nargout == 0
  clear h;
else
  ax = [sP.ax];
end

end


% ---------------------------------------------------------------
function localResizeScatterCallback(~,~,hax)
% get(fig,'position')

hax = handle(hax);

% get markerSize
markerSize = get(findobj(hax,'type','patch'),'MarkerSize');
if isempty(markerSize)
  markerSize = 0;
elseif iscell(markerSize)
  markerSize = [markerSize{:}];
end

markerSize = max(markerSize);

% correct text positions
t = findobj(hax,'Tag','setBelowMarker');
correctTextPostion(hax,t,markerSize,-1);

t = findobj(hax,'Tag','setAboveMarker');
correctTextPostion(hax,t,markerSize,1);

% ------------- scale scatterplots -------------------------------
u = findobj(hax,'Tag','dynamicMarkerSize');

if isempty(u), return;end

p = u(1).Parent;
while ~isgraphics(p,'axes'), p = p.Parent; end


oldUnit = p.Units;
p.Units = 'pixel';
pos = p.Position;
l = min([pos(3),pos(4)]);
if l < 0, return; end 

maxSize = getMTEXpref('markerSize');

for i = 1:length(u)
  d = u(i).UserData;
  o = u(i).MarkerSize;
  %n = l/350 * d;
  n = min(l/250 * d,maxSize);
  if abs((o-n)/o) > 0.05, u(i).MarkerSize = n; end
  
end

p.Units = oldUnit;

end

function correctTextPostion(ax,t,markerSize,dir)
% adjust text positions

if isempty(t), return; end

[~,p2dy] = pix2data(ax);

if ax.YDir=="reverse", dir = -dir; end

for it = 1:length(t)
  
  xy = t(it).UserData;
  if any(isnan(xy)), continue; end

  t(it).Position(2) = xy(2) + dir * ...
    (t(it).Extent(4)/2 + t(it).Margin + p2dy * (markerSize/2 + 4*(dir>0)));
  
end

end
