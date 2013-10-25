function varargout = plotspatial(ebsd,varargin)
% spatial EBSD plot
%
% Input
%  ebsd - @EBSD
%
% Options
%  property - property used for coloring (default: orientation), other properties may be
%     |'phase'| for achieving a spatial phase map, or an properity field of the ebsd
%     data set, e.g. |'bands'|, |'bc'|, |'mad'|.
%
%  colocoding - [[orientation2color.html,colorize orientation]] according to
%    a colorization of the inverse pole figure
%
%    * |'ipdfHSV'|
%    * |'ipdfHKL'|
%    * |'ipdfAngle'|
%    * |'ipdfCenter'|
%
%    other color codings
%
%    * |'angle'|
%    * |'BungeRGB'|
%    * |'RodriguesHSV'|
%    * |'orientationCenter'|
%
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]] when
%     using inverse PoleFigure colorization
%
% Flags
%  points   - plot dots instead of unitcells
%
% Example
% plot a EBSD data set spatially with custom colorcoding
%
%   mtexdata aachen
%   plot(ebsd,'colorcoding','ipdfHKL')
%
%   plot(ebsd,'property','phase')
%
%   plot(ebsd,'property','mad')
%
% See also
% EBSD/plot

if isempty(ebsd), return, end

% check for 3d data
if isProp(ebsd,'z')
  slice3(ebsd,varargin{:});
  return
end

% get spatial coordinates and colorcoding

x_D = [ebsd.prop.x ebsd.prop.y];

% seperate measurements per phase
numberOfPhases = numel(ebsd.phaseMap);
X = cell(1,numberOfPhases);
d = cell(1,numberOfPhases);
opts = cell(1,numberOfPhases);

% what to plot
prop = get_option(varargin,'property','orientations',...
  {'char','double','orientation','quaternion','rotation'});

isPhase = false(numberOfPhases,1);
for k=1:numberOfPhases
  currentPhase = ebsd.phase==k;
  isPhase(k)   = any(currentPhase);

  if isPhase(k)
    [d{k},property,opts{k}] = calcColorCode(ebsd,currentPhase,prop,varargin{:});
    X{k} = x_D(currentPhase,:);
  end
end

% ensure all data have the same size
dim2 = cellfun(@(x) size(x,2),d);

if numel(unique(dim2)) > 1
  for k = 1:numel(d)
    if dim2(k)>0
      d{k} = repmat(d{k},[1,max(dim2)/dim2(k)]);
    end
  end
end


% default plot options

varargin = set_default_option(varargin,...
  {'name', [property ' plot of ' inputname(1)]});

% clear up figure
newMTEXplot('renderer','opengl',varargin{:});
setCamera(varargin{:});

%

selectedPhases = find(isPhase);
for p=1:numel(selectedPhases)
  if ~isempty(d{selectedPhases(p)})    
    h(p) = plotUnitCells(X{selectedPhases(p)},...
      reshape(d{selectedPhases(p)},size(X{selectedPhases(p)},1),[]),ebsd.unitCell,varargin{:});
  end
end

% make legend
if strcmpi(property,'phase')
  minerals = get(ebsd,'minerals');
  legend(h,minerals(isPhase),'location','NorthEast');
end


% set appdata
if strncmpi(property,'orientation',11)
  setappdata(gcf,'CS',ebsd.CS(isPhase));
  setappdata(gcf,'CCOptions',opts(isPhase));
  setappdata(gcf,'colorcoding',property(13:end));
end

set(gcf,'tag','ebsd_spatial');

axis equal tight
fixMTEXplot(gca,varargin{:});


% set data cursor
if ~isOctave()  
  dcm_obj = datacursormode(gcf);
  set(dcm_obj,'SnapToDataVertex','off')
  set(dcm_obj,'UpdateFcn',{@tooltip,ebsd});

  datacursormode on;
end
if nargout>0, varargout{1}=h; end

% Tooltip function
function txt = tooltip(empt,eventdata,ebsd) %#ok<INUSL>


[pos,value] = getDataCursorPos(gcf);
[sub,map] = findByLocation(ebsd,[pos(1) pos(2)]);

if numel(sub)>0

  minerals = get(sub,'minerals');

  txt{1} = ['#'  num2str(find(map))];
  txt{2} = ['Phase: ', minerals{sub.phase}];
  if ~isNotIndexed(sub)
    txt{3} = ['Orientation: ' char(sub.rotations,'nodegree')];
  end
  if ~isempty(value)
    txt{3} = ['Value: ' xnum2str(value)];
  end
else
  txt = 'no data';
end

