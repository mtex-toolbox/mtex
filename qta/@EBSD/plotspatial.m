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

ind = true(numel(ebsd),1);
cc = lower(get_option(varargin,'colorcoding','ipdf'));
  
%% compute colorcoding
switch cc
  case {'bunge','angle','sigma','ihs','ipdf'}
    [grid,ind] = getgrid(ebsd,'checkPhase',varargin{:});
    cs = get(grid,'CS');
    ss = get(grid,'SS');
    switch cc
      case 'bunge'
        d = euler2rgb(grid,varargin{:});
      case 'angle'
        d = quat2rgb(grid,varargin{:});
      case 'sigma'
        d = sigma2rgb(grid,varargin{:});
      case 'ihs'
        d = euler2rgb(grid,cs,ss,varargin{:});
        d = rgb2hsv(d);
      case 'ipdf'     % colorcoding according according to ipdf    
        h = quat2ipdf(grid,varargin{:});
        d = ipdf2rgb(h,cs,varargin{:});
    end
  case 'phase'
    d = [];
    for i = 1:length(ebsd)
      if numel(ebsd(i).phase == 1)
        d = [d;ebsd(i).phase * ones(sampleSize(ebsd(i)),1)]; %#ok<AGROW>
      elseif numel(ebsd(i).phase == 0)
        d = [d;nan(sampleSize(ebsd(i)),1)]; %#ok<AGROW>
      else
        d = [d,ebsd.phase(:)]; %#ok<AGROW>
      end
    end
  case fields(ebsd(1).options)
    d = get(ebsd,cc);
  otherwise
    error('Unknown colorcoding!')
end


%% plot 
newMTEXplot;

plotxy(get(ebsd(ind),'x'),get(ebsd(ind),'y'),d,varargin{:});
if strcmpi(cc,'ipdf')
  setappdata(gcf,'CS',cs);
  setappdata(gcf,'r',get_option(varargin,'r',xvector,'vector3d'));
  setappdata(gcf,'colorcoding',@(h) ipdf2rgb(h,cs,varargin{:}));
end
set(gcf,'tag','ebsd_spatial');
setappdata(gcf,'options',extract_option(varargin,'reduced'));


%% set data cursor
dcm_obj = datacursormode(gcf);
set(dcm_obj,'UpdateFcn',{@tooltip,ebsd});
    
if check_option(varargin,'cursor'), datacursormode on;end

function h = quat2ipdf(S3G,varargin)

  % get specimen direction
  r = get_option(varargin,'r',xvector,'vector3d');

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
