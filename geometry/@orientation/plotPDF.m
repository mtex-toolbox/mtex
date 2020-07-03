function plotPDF(ori,varargin)
% plot orientations into pole figures
%
% Syntax
%   plotPDF(ori,[h1,h2,h3])
%   plotPDF(ori,[h1,h2,h3],'points',100)
%   plotPDF(ori,[h1,h2,h3],'points','all')
%   plotPDF(ori,[h1,h2,h3],'contourf')
%   plotPDF(ori,[h1,h2,h3],'antipodal')
%   plotPDF(ori,[h1,h2,h3],'superposition',{1,[1.5 0.5]})
%   plotPDF(ori,data,[h1,h2,h3])
%
% Input
%  ori - @orientation
%  h   - @Miller crystallographic directions
%
% Options
%  superposition - plot superposed pole figures
%  points        - number of points to be plotted
%  MarkerSize -
%  MarkerFaceColor -
%  MarkerEdgeColor -
%
% Flags
%  noTitle    - suppress the Miller indices at the top
%  noSymmetry - ignore symmetricaly equivalent points
%  antipodal  - include <VectorsAxes.html antipodal symmetry>
%  complete   - ignore fundamental region
%  upper      - restrict to upper hemisphere
%  lower      - restrict to lower hemisphere
%  filled     - fill the marker with current color
%
%
% See also
% orientation/plotIPDF S2Grid/plot savefigure
% Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});

 h = [];
if nargin > 1
  if isa(varargin{1},'Miller')
    h = varargin{1};
  elseif iscell(varargin{1}) && isa(varargin{1}{1},'Miller')
    h = varargin{1};
  end
end

% maybe we should call this function with add2all
if ~isNew && ~check_option(varargin,'parent') && ...
    ((ishold(mtexFig.gca) && length(h)>1) || check_option(varargin,'add2all'))
  plot(ori,varargin{:},'add2all');
  return
end

% extract data
if check_option(varargin,'property')
  data = get_option(varargin,'property');
  data = reshape(data,[length(ori) 1 numel(data)/length(ori)]);
elseif (nargin > 1 && ~(isa(varargin{1},'Miller')) || ...
    (nargin > 2 && iscell(varargin{2}) && isa(varargin{2}{1},'Miller')))
  [data,varargin] = extract_data(length(ori),varargin);
  data = reshape(data,[length(ori) 1 numel(data)/length(ori)]);
else
  data = [];
end


% find crystal directions
h = [];
try h = getappdata(mtexFig.currentAxes,'h'); end %#ok<TRYNC>

if isempty(h) % for a new plot
  h = varargin{1};
  varargin(1) = [];
  if ~iscell(h), h = vec2cell(h);end
else
  h = {h};
end

% all h should by Miller and have the right symmetry
argin_check([h{:}],{'Miller'});
for i = 1:length(h), h{i} = ori.CS.ensureCS(h{i}); end

if isNew
  if isa(ori.SS,'specimenSymmetry')
    pfAnnotations = getMTEXpref('pfAnnotations');
  else
    pfAnnotations = @(varargin) 1;
  end
  set(mtexFig.parent,'Name',['Pole figures of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
else
  pfAnnotations = @(varargin) 1;
end


% ------------------ subsample if needed --------------------------
if ~check_option(varargin,{'all','contour','contourf','smooth','pcolor'}) && ...
    (sum(length(ori))*numSym(ori.CS)*numSym(ori.SS) > 10000 || check_option(varargin,'points'))

  points = fix(get_option(varargin,'points',10000/numSym(ori.CS)/numSym(ori.SS)));
  disp(['  I''m plotting ', int2str(points) ,' random orientations out of ', int2str(length(ori)),' given orientations']);
  disp('  You can specify the the number points by the option "points".');
  disp('  The option "all" ensures that all data are plotted');

  samples = discretesample(length(ori),points);
  ori= ori.subSet(samples);
  if ~isempty(data), data = data(samples,:,:); end

end

% plot
for i = 1:length(h)

  if i>1, mtexFig.nextAxis; end

  % compute specimen directions
  if check_option(varargin,'noSymmetry')
    sh = h{i};
  else
    sh = symmetrise(h{i});
  end
  r = reshape(reshape(ori.SS * (ori * sh).',[],length(ori)).',[],1); % ori x (SS x CS)
  opt = replicateMarkerSize(varargin,numSym(ori.SS)*length(sh));

  % maybe we can restric ourselfs to the upper hemisphere
  if all(angle(h{i},-h{i})<1e-2) && ~check_option(varargin,{'lower','complete','3d'})
    opt = [opt,'upper']; %#ok<AGROW>
  end

  [~,cax] = r.plot(repmat(data,[1 numSym(ori.SS)*length(sh) 1]),...
    ori.SS.fundamentalSector(varargin{:}),'doNotDraw',opt{:});

  if ~check_option(varargin,'noTitle'), mtexTitle(cax(1),char(h{i},'LaTeX')); end

  % plot annotations
  pfAnnotations('parent',cax,'doNotDraw','add2all');
  setappdata(cax,'h',h{i});
  set(cax,'tag','pdf');
  setappdata(cax,'SS',ori.SS);

  % TODO: unifyMarkerSize

end

if isNew || check_option(varargin,'figSize')
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
end

if check_option(varargin,'3d')
  datacursormode off
  fcw(mtexFig.parent,'-link');
end

% ----------- Tooltip function ------------------------
function txt = tooltip(varargin)

[r_local,id,value] = getDataCursorPos(mtexFig,length(ori));

txt{1} = ['id = ' xnum2str(id)];
txt{2} = ['polar = (' int2str(r_local.theta/degree) mtexdegchar ',' int2str(r_local.rho/degree) mtexdegchar ')'];
txt{3} = ['Euler = ' char(ori.subSet(id))];
if ~isempty(value)
  txt{4} = ['value = ' xnum2str(value)];
end

end

end

function opt = replicateMarkerSize(opt,n)

ms = get_option(opt,'MarkerSize');
if length(ms)>1 && n > 1
  ms = repmat(ms(:),1,n);
  opt = set_option(opt,'MarkerSize',ms);
end

end
