function plotspatial(ebsd,varargin)
% spatial EBSD plot
%
%% Syntax
%
%% Input
%  ebsd - @EBSD
%
%% Options
%  axial - include [[AxialDirectional.html,antipodal symmetry]]
%
%% See also

% default plot options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

ind = true(numel(ebsd),1);
cc = lower(get_option(varargin,'colorcoding','ipdf'));
  
%% compute colorcoding
switch cc
  case {'bunge','angle','sigma','ihs','ipdf'}
    [grid,ind] = getgrid(ebsd,'checkPhase',varargin{:});    
    d = orientation2color(grid,cc,varargin{:});
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
    co = get(gca,'colororder');
    colormap(co(1:length(ebsd),:));
  case fields(ebsd(1).options)
    d = get(ebsd,cc);
  otherwise
    error('Unknown colorcoding!')
end


%% plot 
newMTEXplot;

plotxy(get(ebsd(ind),'x'),get(ebsd(ind),'y'),d,varargin{:});
if strcmpi(cc,'ipdf')
  cs = get(grid,'CS');
  setappdata(gcf,'CS',cs)
  setappdata(gcf,'r',get_option(varargin,'r',xvector,'vector3d'));
  setappdata(gcf,'colorcoding',@(h) orientation2color(h,cc,cs,varargin{:}))
end
set(gcf,'tag','ebsd_spatial');
setappdata(gcf,'options',extract_option(varargin,'axial'));

set(gcf,'ResizeFcn',@fixMTEXplot);

%% set data cursor
dcm_obj = datacursormode(gcf);
set(dcm_obj,'UpdateFcn',{@tooltip,ebsd});

if check_option(varargin,'cursor'), datacursormode on;end


%% Tooltip function
function txt = tooltip(empt,eventdata,ebsd) %#ok<INUSL>

pos = get(eventdata,'Position');
[xp yp] = fixMTEXscreencoordinates(pos(1),pos(2));
[x y] = fixMTEXscreencoordinates(ebsd.xy(:,1), ebsd.xy(:,2));
q = get(ebsd,'quaternions');

%does not work with surf
ind = find(xp == x & yp == x);

txt =  {['(x,y) : ',num2str(xp),', ',num2str(yp)],...
  ['quaternion (id: ', num2str(ind),') : ' ], ...
  ['    a = ',num2str(q(ind).a,2)], ...
  ['    b = ', num2str(q(ind).b,2)],...
  ['    c = ', num2str(q(ind).c,2)],...
  ['    d = ', num2str(q(ind).d,2) ]};
