function plotPDF(o,h,varargin)
% plot pole figures
%
% Syntax
%   plotPDF(ori,[h1,..,hN],<options>)
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
% orientation/plotIPDF S2Grid/plot savefigure
% Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

mtexFig = mtexFigure('ensureTag','pdf','ensureAppdata',{{'SS',o.SS}});

% for a new plot 
if isempty(mtexFig.children)
  
  % convert to cell
  if ~iscell(h), h = vec2cell(h);end 
  argin_check([h{:}],{'Miller'});  
  for i = 1:length(h)
    h{i} = o.CS.ensureCS(h{i});
  end    
else
  h = getappdata(gcf,'h');
end

% colorcoding 1
data = get_option(varargin,'property',[]);

% ------------------ subsample if needed --------------------------

if ~check_option(varargin,'all') && ...
    (sum(length(o))*length(o.CS)*length(o.SS) > 10000 || check_option(varargin,'points'))

  points = fix(get_option(varargin,'points',10000/length(o.CS)/length(o.SS)));
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

% predefines axes?
paxes = get_option(varargin,'parent',mtexFig.children);

for i = 1:length(h)

  % compute specimen directions
  sh = symmetrise(h{i});
  r = reshape(o.SS * o * sh,[],1);
  
  if isempty(paxes), ax = mtexFig.nextAxis; else ax = paxes(i); end
   
  r.plot(repmat(data(:).',[length(o.SS) length(sh)]),'fundamentalRegion',...
    'parent',ax,'scatter','TR',h(i),varargin{:});
  
  % TODO: unifyMarkerSize

end

if isempty(paxes)
  setappdata(gcf,'h',h);
  setappdata(gcf,'SS',o.SS);
  setappdata(gcf,'CS',o.CS);
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




