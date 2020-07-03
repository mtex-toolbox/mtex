function plotIPDF(ori,varargin)
% plot orientations into inverse pole figures
%
% Syntax
%   plotIPDF(ori,[r1,r2,r3])
%   plotIPDF(ori,[r1,r2,r3],'points',100)
%   plotIPDF(ori,[r1,r2,r3],'points','all')
%   plotIPDF(ori,[r1,r2,r3],'contourf')
%   plotIPDF(ori,[r1,r2,r3],'antipodal')
%   plotIPDF(ori,data,[r1,r2,r3])
%
% Input
%  ebsd - @EBSD
%  r   - @vector3d specimen directions
%
% Options
%  RESOLUTION - resolution of the plots
%  property   - user defined colorcoding
%  MarkerSize -
%  MarkerFaceColor -
%  MarkerEdgeColor -
%
% Flags
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%  complete  - ignore fundamental region
%  upper     - restrict to upper hemisphere
%  lower     - restrict to lower hemisphere
%  filled    - fill the marker with current color
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});

% maybe we should call this function with the option add2all
if ~isNew && ~check_option(varargin,'parent') && ...
    ((((ishold(mtexFig.gca) && nargin > 1 && isa(varargin{1},'vector3d') && length(varargin{1})>1))) || check_option(varargin,'add2all'))
  plot(ori,varargin{:},'add2all');
  return
end

% extract data
if check_option(varargin,'property')
  data = get_option(varargin,'property');
  data = reshape(data,[1,length(ori) numel(data)/length(ori)]);
elseif nargin > 1 && ~isa(varargin{1},'vector3d')
  [data,varargin] = extract_data(length(ori),varargin);
  data = reshape(data,[1,length(ori) numel(data)/length(ori)]);
else
  data = [];
end

% find inverse pole figure direction
r = [];
try r = getappdata(mtexFig.currentAxes,'inversePoleFigureDirection'); end
if isempty(r), r = varargin{1}; end
argin_check(r,'vector3d');

%  subsample if needed
if (length(ori)*numSym(ori.CS)*numSym(ori.SS) > 100000 || check_option(varargin,'points')) ...
    && ~check_option(varargin,{'all','contourf','smooth','contour','pcolor'})

  points = fix(get_option(varargin,'points',100000/numSym(ori.CS)/numSym(ori.SS)));
  disp(['  I''m plotting ', int2str(points) ,' random orientations out of ', int2str(length(ori)),' given orientations']);

  samples = discretesample(length(ori),points);
  ori = ori.subSet(samples);
  if ~isempty(data), data = data(:,samples,:); end

end

for ir = 1:length(r)

  if ir>1, mtexFig.nextAxis; end

  % the crystal directions
  rSym = symmetrise(r(ir),ori.SS);
  h = ori(:) \ rSym;

  %  plot
  [~,cax] = h.plot(repmat(data,1,length(rSym)),'symmetrised',...
    'fundamentalRegion','doNotDraw',varargin{:});
  if isNew, mtexTitle(cax(1),char(r(ir),'LaTeX')); end

  % plot annotations
  setappdata(cax,'inversePoleFigureDirection',r(ir));
  set(cax,'tag','ipdf');
  setappdata(cax,'CS',ori.CS);
  setappdata(cax,'SS',ori.SS);

  % TODO: unifyMarkerSize

end

if isNew || check_option(varargin,'figSize')
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
end

% --------------- Tooltip function ------------------
function txt = tooltip(varargin)

  [r_local,id,value] = getDataCursorPos(mtexFig,length(ori));

  %id = (id-1)/

  h_local = round(Miller(r_local,ori.CS));

  txt{1} = ['id = ' xnum2str(id)];
  txt{2} = ['(h,k,l) = ' char(h_local,'tolerance',3*degree,'commasep')];
  txt{3} = ['Euler = ' char(ori.subSet(id))];
  if ~isempty(value)
    txt{4} = ['value = ' xnum2str(value)];
  end

end

end
