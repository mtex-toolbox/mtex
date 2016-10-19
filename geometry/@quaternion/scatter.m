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
[mtexFig,isNew] = newMtexFigure(varargin{:});

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

% add some nans if lines are plotted
if check_option(varargin,'edgecolor')
  d = sqrt(diff(x([1:end,1])).^2 + diff(y([1:end,1])).^2 + diff(z([1:end,1])).^2);
  ind = find(d > 10);
  for k = 1:numel(ind)
    x = [x(1:ind(k)+k-1);nan;x(ind(k)+k:end)];
    y = [y(1:ind(k)+k-1);nan;y(ind(k)+k:end)];
    z = [z(1:ind(k)+k-1);nan;z(ind(k)+k:end)];
  end
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
  
  optiondraw(h,varargin{:});
end

% finalize plot
if isNew
  view(mtexFig.gca,3);
  grid(mtexFig.gca,'on');
  axis(mtexFig.gca,'vis3d','equal','on');
end

if nargout == 0, clear h;end
