function h = scatter(q,varargin)
% plot function
%
% Input
%  q - Quaternion
%
% Options
%  rodrigues - plot in rodrigues space
%  axisAngle - plot in axis / angle
%

% prepare axis
mtexFig = newMtexFigure('ensureTag','quaternionScatter',varargin{:});

% create a new scatter plot
if isappdata(mtexFig.gca,'projection')
  projection = getappdata(mtexFig.gca,'projection');
else
  if check_option(varargin,{'rodrigues'})
    projection = 'rodrigues';
  else
    projection = 'axisangle';
  end
  setappdata(mtexFig.gca,'projection',projection);
end

% project data
switch projection
  case 'rodrigues'
    v = Rodrigues(q);
    v = v(abs(v) < 1e5);
    [x,y,z] = double(v);
  case 'axisangle'
    [x,y,z] = double(q.axis .* q.angle ./ degree);
end

% color
if ~check_option(varargin,{'MarkerColor','MarkerFaceColor','data','MarkerEdgeColor'})
  [ls,c] = nextstyle(gca,true,true,~ishold(gca));
  varargin = {'MarkerEdgeColor',c,varargin{:}};
end
MFC = get_option(varargin,{'MarkerFaceColor','MarkerColor'},'none');
MEC = get_option(varargin,{'MarkerEdgeColor','MarkerColor'},'b');

% scatter plot
h = patch(x(:),y(:),z(:),1,...
  'FaceColor','none',...
  'EdgeColor','none',...
  'MarkerFaceColor',MFC,...
  'MarkerEdgeColor',MEC,...
  'MarkerSize',get_option(varargin,'MarkerSize',5),...
  'Marker',get_option(varargin,'Marker','o'),...
  'parent',mtexFig.gca);

% finalize plot
view(mtexFig.gca,3);
grid(mtexFig.gca,'on');
axis(mtexFig.gca,'vis3d','equal','on');

if nargout == 0, clear h;end
