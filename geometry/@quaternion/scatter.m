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
mtexFig = newMtexFigure(varargin{:});

% create a new scatter plot
if isappdata(mtexFig.gca,'projection')
  projection = getappdata(mtexFig.gca,'projection');
else
  projection = get_option(varargin,'projection','axisAngle');
  setappdata(mtexFig.gca,'projection',projection);
end

% project data
switch lower(projection)
  case 'rodrigues'
    v = Rodrigues(q);
    v = v(abs(v) < 1e5);
    [x,y,z] = double(v);
  case 'axisangle'
    [x,y,z] = double(q.axis .* q.angle ./ degree);
  case 'euler'
    [x,y,z] = q.Euler(varargin{:});
    x = x./degree;
    y = y./degree;
    z = z./degree;
end

% scatter plot
if nargin> 1 && isnumeric(varargin{1}) && ~isempty(varargin{1})
  h = patch(x(:),y(:),z(:),1,...
    'facevertexcdata',varargin{1},...
    'markerfacecolor','flat',...
    'markeredgecolor','flat',...
    'FaceColor','none',...
    'EdgeColor','none',...
    'MarkerSize',get_option(varargin,'MarkerSize',5),...
    'Marker',get_option(varargin,'Marker','o'),...
    'parent',mtexFig.gca);
else
  % color
  if ~check_option(varargin,{'MarkerColor','MarkerFaceColor','data','MarkerEdgeColor'})
    [ls,c] = nextstyle(gca,true,true,~ishold(gca));
    varargin = {'MarkerEdgeColor',c,varargin{:}};
  end
  MFC = get_option(varargin,{'MarkerFaceColor','MarkerColor'},'none');
  MEC = get_option(varargin,{'MarkerEdgeColor','MarkerColor'},'b');
  
  h = patch(x(:),y(:),z(:),1,...
    'FaceColor','none',...
    'EdgeColor','none',...
    'MarkerFaceColor',MFC,...
    'MarkerEdgeColor',MEC,...
    'MarkerSize',get_option(varargin,'MarkerSize',5),...
    'Marker',get_option(varargin,'Marker','o'),...
    'parent',mtexFig.gca);
end

% finalize plot
view(mtexFig.gca,3);
grid(mtexFig.gca,'on');
axis(mtexFig.gca,'vis3d','equal','on');

if nargout == 0, clear h;end
