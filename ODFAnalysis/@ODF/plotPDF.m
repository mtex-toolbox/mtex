function plotPDF(odf,h,varargin)
% plot pole figures
%
% Syntax
%   plotPDF(odf,[h1,..,hN],<options>)
%   plotPDF(odf,{h1,..,hN},'superposition',{c1,..,cN},<options>)
%
% Input
%  odf - @ODF
%  h   - @Miller crystallographic directions
%  c   - structure coefficients
%
% Options
%  RESOLUTION    - resolution of the plots
%  SUPERPOSITION - plot superposed pole figures
%
% Flags
%  antipodal    - include [[AxialDirectional.html,antipodal symmetry]]
%  COMPLETE - plot entire (hemi)--sphere
%
% See also
% S2Grid/plot annotate savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

% convert to cell
if ~iscell(h), h = vec2cell(h);end

% ensure crystal symmetry
try
  argin_check([h{:}],'Miller');
  for i = 1:length(h)
    h{i} = odf.CS.ensureCS(h{i});
  end
catch %#ok<CTCH>
  plotIPDF(odf,h,varargin);
  return
end

% superposition coefficients
if check_option(varargin,'superposition')
  c = get_option(varargin,'superposition');
else
  c = num2cell(ones(size(h)));
end

% plotting grid
sR = getFundamentalRegionPF(odf.SS,'restrict2Hemisphere',varargin{:});
r = plotS2Grid(sR,varargin{:});

% compute pole figures
for i =1:length(h)
  p{i} = ensureNonNeg(pdf(odf,h{i},r,varargin{:},'superposition',c{i})); %#ok<AGROW,NASGU>
end

% plot pole figures
if check_option(varargin,'parent')
  r.smooth(p{1},'TR',h{1},varargin{:});
else
  
  mtexFig = mtexFigure; % create a new figure
  
  for i = 1:length(h)
    r.plot(p{i},'TR',h{i},'parent',mtexFig.nextAxis,'smooth',varargin{:});
  end

  % finalize plot
  mtexFig.drawNow;
  setappdata(gcf,'odf',odf);
  setappdata(gcf,'h',h);
  setappdata(gcf,'CS',odf.CS);
  setappdata(gcf,'SS',odf.SS);
  set(gcf,'tag','pdf');
  name = inputname(1);
  set(gcf,'Name',['Pole figures of "',name,'"']);

  % set data cursor
  dcm_obj = datacursormode(gcf);
  set(dcm_obj,'SnapToDataVertex','off')
  set(dcm_obj,'UpdateFcn',{@tooltip});
  datacursormode on;

end
  
end

% -------------- Tooltip function ---------------------------------
function txt = tooltip(varargin)

% 
dcm_obj = datacursormode(gcf);

hcmenu = dcm_obj.CurrentDataCursor.uiContextMenu;
if numel(get(hcmenu,'children'))<10
  uimenu(hcmenu, 'Label', 'Mark Equivalent Modes', 'Callback', @markEquivalent);
  uimenu(hcmenu, 'Label', 'Plot Fibre', 'Callback', @plotFibre);
  mcolor = uimenu(hcmenu, 'Label', 'Marker color', 'Callback', @display);
  msize = uimenu(hcmenu, 'Label', 'Marker size', 'Callback', @display);
  mshape = uimenu(hcmenu, 'Label', 'Marker shape', 'Callback', @display);
end

%
[r,h,v] = currentVector;
[th,rh] = polar(r);
txt = [xnum2str(v) ' at (' int2str(th/degree) ',' int2str(rh/degree) ')'];

end

%
function plotFibre(varargin)

[r,h] = currentVector;

odf = getappdata(gcf,'odf');

figure
plotFibre(odf,h,r);

end

%
function markEquivalent(varargin)

[r,h] = currentVector;

odf = getappdata(gcf,'odf');

fibre = orientation('fibre',h,r,odf.CS,odf.SS);
f = eval(odf,fibre); %#ok<EVLC>

[v,p] = max(f); %#ok<ASGLU>

annotate(fibre(p));

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



