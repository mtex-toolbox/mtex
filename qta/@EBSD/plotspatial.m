function plotspatial(ebsd,varargin)
% spatial EBSD plot
%
%% Syntax
%
%% Input
%
%% Options
%
%% See also

% get reference orientation
if ~check_option(varargin,'center','quaternion')
  q0 = mean(subsample(ebsd,1000));
else
  q0 = get_option(varargin,'center');
end
cs = get(ebsd,'CS');
  
%% compute colorcoding
switch lower(get_option(varargin,'colorcoding','ipdf'))
  case 'bunge'
    d = euler2rgb(getgrid(ebsd),'center',q0,varargin{:});
  case 'angle'
    d = quat2rgb(getgrid(ebsd),'center',q0,varargin{:});
  case 'sigma'
    d = sigma2rgb(getgrid(ebsd),'center',q0,varargin{:});
  case 'IHS'
    d = euler2rgb(q,ebsd.CS,ebsd.SS,'q0',q0,varargin{:});
    d = rgb2hsv(d);      
  case 'ipdf'     % colorcoding according according to ipdf
    h = quat2ipdf(getgrid(ebsd),varargin{:});
    d = ipdf2rgb(h,cs,varargin{:});
  otherwise
    error('Unknown colorcoding!')
end


%% plot 
newMTEXplot;

plotxy(ebsd.xy(:,1),ebsd.xy(:,2),d,varargin{:});

set(gcf,'tag','ebsd_spatial');
setappdata(gcf,'CS',cs);
setappdata(gcf,'r',get_option(varargin,'r',xvector,'vector3d'));
setappdata(gcf,'colorcoding',@(h) ipdf2rgb(h,cs,varargin{:}));
setappdata(gcf,'options',extract_option(varargin,'reduced'));


%% set data cursor
dcm_obj = datacursormode(gcf);
set(dcm_obj,'UpdateFcn',{@tooltip,ebsd});
    
if check_option(varargin,'cursor'), datacursormode on;end

function h = quat2ipdf(S3G,varargin)

  % get specimen direction
  r = get_option(varargin,'r',xvector,'vector3d');

  % set crystal symmetry
  cs = getCSym(S3G);

  % compute crystal directions
  h = inverse(quaternion(S3G)) .* r;


%% Tooltip function
function txt = tooltip(empt,eventdata,ebsd) %#ok<INUSL>

pos = get(eventdata,'Position');
xy = ebsd.xy;
q = quaternion(ebsd.orientations);

ind = find((pos(1) == xy(:,1)) & (pos(2) == xy(:,2)));

txt =  {['(x,y) : ',num2str(pos(1)),', ',num2str(pos(2))],...
  ['quaternion (id: ', num2str(ind),') : ' ], ...
  ['    a = ',num2str(q(ind).a,2)], ...
  ['    b = ', num2str(q(ind).b,2)],...
  ['    c = ', num2str(q(ind).c,2)],...
  ['    d = ', num2str(q(ind).d,2) ]};
