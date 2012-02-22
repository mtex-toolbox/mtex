function varargout = plotspatial(ebsd,varargin)
% spatial EBSD plot
%
%% Input
%  ebsd - @EBSD
%
%% Options
%  property - property used for coloring (default: orientation), other properties may be
%     |'phase'| for achieving a spatial phase map, or an properity field of the ebsd
%     data set, e.g. |'bands'|, |'bc'|, |'mad'|.
%
%  colocoding - [[orientation2color.html,colorize orientation]] according a
%    colormap after inverse PoleFigure
%
%    * |'ipdf'|
%    * |'hkl'|
%
%    other color codings
%
%    * |'angle'|
%    * |'bunge'|, |'bunge2'|, |'euler'|
%    * |'sigma'|
%    * |'rodrigues'|
%
%  antipodal      - include [[AxialDirectional.html,antipodal symmetry]] when
%     using inverse
%     PoleFigure colorization
%
%% Flags
%  points   - plot dots instead of unitcells
%% Example
% plot a EBSD data set spatially with custom colorcoding
%
%   mtexdata aachen
%   plot(ebsd,'colorcoding','hkl')
%
%   plot(ebsd,'property','phase')
%
%   plot(ebsd,'property','mad')
%
%% See also
% EBSD/plot

% restrict to a given phase or region
%ebsd = copy(ebsd,varargin{:});

if ~numel(ebsd), return, end

%% check for 3d data
if isfield(ebsd.options,'z')
  slice3(ebsd,varargin{:});
  return
end

%% get spatial coordinates and colorcoding

x_D = [ebsd.options.x ebsd.options.y];

% seperate measurements per phase
nphase = numel(ebsd.phaseMap);
X = cell(1,nphase); d = cell(1,nphase);

for k=1:nphase
  iP = ebsd.phase==k;
  X{k} = x_D(iP,:);
  [d{k},property] = calcColorCode(ebsd,iP,varargin{:});
end

%% default plot options

varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

varargin = set_default_option(varargin,...
  {'name', [property ' plot of ' inputname(1) ' (' ebsd.comment ')']});

% clear up figure
newMTEXplot('renderer','opengl',varargin{:});

%%

isPhase = find(~cellfun('isempty',X));

for k=1:numel(isPhase)
  h(k) = plotUnitCells(X{isPhase(k)},d{isPhase(k)},ebsd.unitCell,varargin{:});
end

% make legend
minerals = get(ebsd,'minerals');
legend(h,minerals(isPhase));
legend('off')

if strcmpi(property,'phase'),  
  legend('show');
end


% set appdata
if strncmpi(property,'orientation',11)
  setappdata(gcf,'CS',ebsd.CS)
  setappdata(gcf,'r',get_option(varargin,'r',xvector,'vector3d'));
  setappdata(gcf,'colorcenter',get_option(varargin,'colorcenter',[]));
  setappdata(gcf,'colorcoding',lower(get_option(varargin,'colorcoding','ipdf')));
end

set(gcf,'tag','ebsd_spatial');
setappdata(gcf,'options',[extract_option(varargin,'antipodal'),...
  varargin]);



fixMTEXscreencoordinates('axis'); %due to axis;

axis equal tight
fixMTEXplot(gca,varargin{:});


if ~isOctave()
  %% set data cursor
  dcm_obj = datacursormode(gcf);
  set(dcm_obj,'SnapToDataVertex','off')
  set(dcm_obj,'UpdateFcn',{@tooltip,ebsd});

  if check_option(varargin,'cursor'), datacursormode on;end
end
if nargout>0, varargout{1}=h; end

%% Tooltip function
function txt = tooltip(empt,eventdata,ebsd) %#ok<INUSL>

pos = get(eventdata,'Position');
[xx,yy] = fixMTEXscreencoordinates(pos(1),pos(2));

[sub,map] = findByLocation(ebsd,[xx yy]);

if numel(sub)>0 
  
  minerals = get(sub,'minerals');  
 
  txt{1} = ['#'  num2str(find(map))];
  txt{2} = ['Phase: ', minerals{sub.phase}];
  if ~isNotIndexed(sub)
    txt{3} = ['Orientation: ' char(sub.rotations)];
  end
  
else
  txt = 'no data';
end

