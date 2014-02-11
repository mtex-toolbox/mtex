function plotpdf(o,h,varargin)
% plot pole figures
%
% Syntax
%   plotpdf(ori,[h1,..,hN],<options>)
%
% Input
%  ori - @orientation
%  h   - @Miller crystallographic directions
%
% Options
%  superposition - plot superposed pole figures
%  points        - number of points to be plotted
%
% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%  complete  - plot entire (hemi)--sphere
%
% See also
% orientation/plotipdf S2Grid/plot savefigure
% Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

% where to plot
[ax,o,h,varargin] = getAxHandle(o,h,varargin{:});

cs = o.CS;
ss = o.SS;

% for a new plot 
if ~isempty(ax) || newMTEXplot('ensureTag','pdf',...
    'ensureAppdata',{{'SS',ss}})
  
  % convert to cell
  if ~iscell(h), h = vec2cell(h);end 
  argin_check([h{:}],{'Miller'});  
  for i = 1:length(h)
    h{i} = o.CS.ensureCS(h{i});
  end  
else
  h = getappdata(gcf,'h');
  options = getappdata(gcf,'options');
  if ~isempty(options), varargin = {options{:},varargin{:}};end
end

% colorcoding 1
data = get_option(varargin,'property',[]);

% ------------------ subsample if needed --------------------------

if ~check_option(varargin,'all') && ...
    (sum(length(o))*length(cs)*length(ss) > 10000 || check_option(varargin,'points'))

  points = fix(get_option(varargin,'points',10000/length(cs)/length(ss)));
  disp(['  plotting ', int2str(points) ,' random orientations out of ', int2str(length(o)),' given orientations']);
  disp('You can specify the the number points by the option "points".'); 
  disp('The option "all" ensures that all data are plotted');
  
  samples = discretesample(ones(1,length(o)),points);
  o= o.subSet(samples);
  if ~isempty(data), data = data(samples); end
end

% colorcoding 2
if check_option(varargin,'colorcoding')
  colorcoding = lower(get_option(varargin,'colorcoding','angle'));
  data = orientation2color(o,colorcoding,varargin{:});
  
  % convert RGB to ind
  if numel(data) == 3*length(o)  
    [data, map] = rgb2ind(reshape(data,[],1,3), 0.03,'nodither');
    set(gcf,'colormap',map);    
  end
  
end


% ------------------------ plot ---------------------------

% compute specimen directions
sh = @(i) symmetrise(h{i});
r = @(i) reshape(ss * o * sh(i),[],1);

% symmetrise data
data = @(i) repmat(data(:).',[length(ss) length(sh(i))]);

[minTheta,maxTheta,minRho,maxRho] = getFundamentalRegionPF(ss,'restrict2Hemisphere',varargin{:});

multiplot(ax{:},length(h),r,data,'scatter','TR',@(i) h(i),...  
  'minRho',minRho,'maxRho',maxRho,'minTheta',minTheta,'maxTheta',maxTheta,...
  'unifyMarkerSize',varargin{:});

if isempty(ax)
  setappdata(gcf,'h',h);
  setappdata(gcf,'SS',ss);
  setappdata(gcf,'CS',cs);
  setappdata(gcf,'options',extract_option(varargin,'antipodal'));
  set(gcf,'Name',['Pole figures of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
  set(gcf,'Tag','pdf');
  
  % set data cursor
  dcm_obj = datacursormode(gcf);
  set(dcm_obj,'SnapToDataVertex','off')
  set(dcm_obj,'UpdateFcn',{@tooltip});
  datacursormode on;
end

end

% Tooltip function
function txt = tooltip(varargin)

% 
dcm_obj = datacursormode(gcf);

hcmenu = dcm_obj.CurrentDataCursor.uiContextMenu;

%
[r,h,v] = currentVector;
[th,rh] = polar(r);
txt = ['id ' xnum2str(v) ' at (' int2str(th/degree) ',' int2str(rh/degree) ')'];

end


function [r,h,value] = currentVector

[pos,value,ax,iax] = getDataCursorPos(gcf);

r = vector3d('polar',pos(1),pos(2));

h = getappdata(gcf,'h');
h = h{iax};

projection = getappdata(ax,'projection');

if projection.antipodal
  h = set_option(h,'antipodal');
end

end




