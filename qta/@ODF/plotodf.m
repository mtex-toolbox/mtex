function plotodf(odf,varargin)
% plot odf
%
% Plots the ODF as various sections which can be controled by options.
%
% Input
%  odf - @ODF
%
% Options
%  SECTIONS   - number of plots
%  RESOLUTION - resolution of each plot
%  CENTER     - for radially symmetric plot
%  AXES       - for radially symmetric plot
%
% Flags
%  SIGMA (default)
%  OMEGA - sections along crystal directions @Miller
%  ALPHA
%  GAMMA
%  PHI1
%  PHI2
%  RADIALLY
%  AXISANGLE
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo



% -------- one - dimensional plot ---------------------------------------
if check_option(varargin,'RADIALLY')
  plotodf1d(odf,varargin{:});
  return
end

% ------------ two dimensional sections ----------------------------

% where to plot
[ax,odf,varargin] = getAxHandle(odf,varargin{:});

% generate grids
[S3G,S2G,sec] = regularSO3Grid(odf(1).CS,odf(1).SS,varargin{:});

Z = eval(odf,orientation(S3G),varargin{:});
clear S3G;

% ------------------------- plot -----------------------------------------
sectype = get_flag(varargin,{'alpha','phi1','gamma','phi2','sigma','omega','axisangle'},'phi2');
[symbol,labelx,labely] = sectionLabels(sectype);

if any(strcmpi(sectype,{'sigma','omega','axisangle'}))
  varargin = [{'innerPlotSpacing',10},varargin];
else
  varargin = [{'projection','plain',...
    'xAxisDirection','east','zAxisDirection','intoPlane',...
    'innerPlotSpacing',35,'outerPlotSpacing',35},varargin];
end

fprintf(['\nPlotting ODF as ',sectype,' sections, range: ',...
  xnum2str(min(sec)/degree),mtexdegchar,' - ',xnum2str(max(sec)/degree),mtexdegchar,'\n']);

% make new plot
if isempty(ax), newMTEXplot('xlabel',labelx,'ylabel',labely);end


% plot
if check_option(varargin,{'contour3','surf3','slice3'})
  
  [xlim ylim] = polar(S2G);

  v = get_option(varargin,{'surf3','contour3'},10,'double');
  contour3s(xlim(1,:)./degree,ylim(:,1)'./degree,sec./degree,Z,v,varargin{:},...
    'xlabel',labely,'ylabel',labelx,'zlabel',['$' symbol '$']);

else
  %
  multiplot(numel(sec),...
    S2G,  @(i) Z(:,:,i),...    'DISP',@(i,Z) [' ',symbol(2:end),' = ',xnum2str(sec(i)/degree),mtexdegchar,' ',...    ' Max: ',xnum2str(max(Z(:))),...    ' Min: ',xnum2str(min(Z(:)))],...
    'smooth','TR',@(i) [int2str(sec(i)*180/pi),'^\circ'],...
    'xlabel',labelx,'ylabel',labely,...
    'colorrange','equal',varargin{:}); %#ok<*EVLC>
end

% --------------- finalize plot ---------------------------
if isempty(ax),
  name = inputname(1);
  set(gcf,'Name',['ODF ' sectype '-sections "',name,'"']);
  setappdata(gcf,'sections',sec);
  setappdata(gcf,'SectionType',sectype);
  setappdata(gcf,'CS',odf(1).CS);
  setappdata(gcf,'SS',odf(1).SS);
  set(gcf,'tag','odf')


  if strcmpi(sectype,'omega') && ~isempty(find_type(varargin,'Miller'))
    h = varargin{find_type(varargin,'Miller')};
    setappdata(gcf,'h',h);
  end

  % set data cursor
  dcm_obj = datacursormode(gcf);
  set(dcm_obj,'SnapToDataVertex','off')
  set(dcm_obj,'UpdateFcn',{@tooltip});
  %menu = get(dcm_obj,'UIContextMenu');
  datacursormode on;
end

end

% --------------- Tooltip function -------------------------------
function txt = tooltip(varargin)

% 
dcm_obj = datacursormode(gcf);

hcmenu = dcm_obj.CurrentDataCursor.uiContextMenu;
if numel(get(hcmenu,'children'))<10
  uimenu(hcmenu, 'Label', 'Mark equivalent orientations', 'Callback', @markEquivalent);
  mcolor = uimenu(hcmenu, 'Label', 'Marker color', 'Callback', @display);
  msize = uimenu(hcmenu, 'Label', 'Marker size', 'Callback', @display);
  mshape = uimenu(hcmenu, 'Label', 'Marker shape', 'Callback', @display);
end

%
[ori,v] = currentOrientation;

txt = [xnum2str(v) ' at ' char(ori,'nodegree')];

end

%
function markEquivalent(varargin)

ori = currentOrientation;

annotate(ori);

end


function [ori,value] = currentOrientation

[pos,value,ax,iax] = getDataCursorPos(gcf); %#ok<ASGLU>
sec = getappdata(gcf,'sections');

switch getappdata(gcf,'SectionType')
  case 'phi1'
    euler1 = sec(iax);
    euler2 = pos(1);
    euler3 = pos(2);
    convention = 'Bunge';
  case 'phi2'
    euler3 = sec(iax);
    euler2 = pos(1);
    euler1 = pos(2);
    convention = 'Bunge';
  case 'alpha'
    euler3 = sec(iax);
    euler2 = pos(1);
    euler1 = pos(2);
    convention = 'Matthies';
  case 'sigma'
    euler1 = pos(2);
    euler2 = pos(1);
    euler3 = sec(iax) - pos(2);
    convention = 'Matthies';
  otherwise
    error('unknown sectioning!')
end

ori = orientation('Euler',euler1,euler2,euler3,convention,...
  getappdata(gcf,'CS'),getappdata(gcf,'SS'));

end
