function plotIPDF(o,varargin)
% plot orientations into inverse pole figures
%
% Input
%  ebsd - @EBSD
%  r   - @vector3d specimen directions
%
% Options
%  RESOLUTION - resolution of the plots
%  property   - user defined colorcoding
%
% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%  complete  - plot entire (hemi)--sphere
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

[mtexFig,isNew] = newMtexFigure('ensureTag','ipdf',...
  'ensureAppdata',{{'CS',o.CS}},...
  'name',['Inverse Pole figures of ' o.CS.mineral],...
  'datacursormode',@tooltip,varargin{:});

if isNew 
  
  r = varargin{1};
  argin_check(r,'vector3d');
  setappdata(mtexFig.parent,'inversePoleFigureDirection',r);
    
else % take inverse pole figure directions from figure
   
  r = getappdata(mtexFig.parent,'inversePoleFigureDirection');
    
end

% color coding
data = get_option(varargin,'property',[]);
if size(data,2) == length(o), data = data.'; end

%  subsample if needed 
if (length(o)*length(o.CS)*length(o.SS) > 100000 || check_option(varargin,'points')) ...
    && ~check_option(varargin,{'all','contourf','smooth','contour'})

  points = fix(get_option(varargin,'points',100000/length(o.CS)/length(o.SS)));
  disp(['  I''m plotting ', int2str(points) ,' random orientations out of ', int2str(length(o)),' given orientations']);

  samples = discretesample(length(o),points);
  o = o.subSet(samples);
  if ~isempty(data), data = data(samples,:); end

end

for ir = 1:length(r)

  % TODO: it might happen that the spherical region needs two axes
  if ir>1, mtexFig.nextAxis; end  
  
  % the crystal directions
  rSym = symmetrise(r(ir),o.SS);
  h = o(:) \ rSym;
  
  %  plot  
  h.plot(repmat(data(:),1,length(rSym)),'symmetrised',...
    'fundamentalRegion','parent',mtexFig.gca,'doNotDraw',varargin{:});
  
  mtexTitle(mtexFig.gca,char(r(ir),'LaTeX'));

  % TODO: unifyMarkerSize

end

if isNew || check_option(varargin,'figSize')
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
end

% --------------- Tooltip function ------------------
function txt = tooltip(empt,eventdata) %#ok<INUSL>

pos = get(eventdata,'Position');
xp = pos(1); yp = pos(2);

rho = atan2(yp,xp);
rqr = xp^2 + yp^2;
theta = acos(1-rqr/2);

m = Miller(vector3d('polar',theta,rho),getappdata(gcf,'CS'));
m = round(m);
txt = char(m,'tolerance',3*degree,'commasep');
