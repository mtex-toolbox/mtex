function [h,ax] = scatter3d(v,varargin)
% plot spherical data
%
% Syntax
%   scatter3d(v,data)
%
% Input
%  v - @vector3d
%


% where to plot
if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
else
  ax = gca;
end

% plot a inner sphere that is not translucent
plotEmptySphere(ax);

% normalize vectors
v = reshape(v,[],1);
v = 1.02 .* v ./ norm(v);

if nargin > 1 && isnumeric(varargin{1})
  data = varargin{1};
  data = reshape(data,length(v),[]);
  varargin{1} = [];
else
  data = {};
end

if v.antipodal
  v = [v;-v];
  data = [data;data];
end

% markerSize
if ~check_option(varargin,{'scatter_resolution','MarkerSize'},'double')
  res = max(v.resolution,0.5*degree);
else
  res = get_option(varargin,'scatter_resolution',1*degree);
end
MarkerSize  = get_option(varargin,'MarkerSize',max(1,min(getMTEXpref('markerSize'),50*res)));


% plot
data = ensurecell(data);
if isempty(data), data = {}; end
h = optiondraw(scatter3(v.x(:),v.y(:),v.z(:),MarkerSize.^2,data{:},'filled','parent',ax),varargin{:});

% add transparency if required
if check_option(varargin,{'MarkerAlpha','MarkerFaceAlpha','MarkerEdgeAlpha'})
  
  faceAlpha = round(255*get_option(varargin,{'MarkerAlpha','MarkerFaceAlpha'},1));
  edgeAlpha = round(255*get_option(varargin,{'MarkerAlpha','MarkerEdgeAlpha'},1));
        
  % we have to wait until the markers have been drawn
  mh = [];
  while isempty(mh)
    pause(0.01);
    hh = handle(h);
    mh = [hh.MarkerHandle];
  end
                
  for j = 1:length(mh)
    mh(j).FaceColorData(4,:) = faceAlpha; %#ok<AGROW>
    mh(j).FaceColorType = 'truecoloralpha'; %#ok<AGROW>
    
    mh(j).EdgeColorData(4,:) = edgeAlpha; %#ok<AGROW>
    mh(j).EdgeColorType = 'truecoloralpha'; %#ok<AGROW>
  end
  
end

axis(ax,'equal','vis3d','off');
set(ax,'XDir','rev','YDir','rev',...
  'XLim',[-1.02,1.02],'YLim',[-1.02,1.02],'ZLim',[-1.02,1.02]);

pC = getClass(varargin,'plottingConvention',getMTEXpref('xyzPlotting'));
pC.setView(ax);

hold(ax,'off')

if nargout == 0, clear h;end

end


% since the legend entry for patch object is not nice we draw an
% invisible scatter dot just for legend
%if check_option(varargin,'DisplayName')
%  holdState = get(ax,'nextPlot');
%  set(ax,'nextPlot','add');
  %optiondraw(scatter([],[],'parent',ax,'MarkerFaceColor',mfc,...
  %  'MarkerEdgeColor',mec),varargin{:});%
  %set(ax,'nextPlot',holdState);
%end