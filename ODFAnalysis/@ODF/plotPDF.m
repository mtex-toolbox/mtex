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

% ensure crystal symmetry
if ~iscell(h), h = vec2cell(h);end
argin_check([h{:}],'Miller');
for i = 1:length(h), h{i} = odf.CS.ensureCS(h{i}); end

% superposition coefficients
if check_option(varargin,'superposition')
  c = get_option(varargin,'superposition');
else
  c = num2cell(ones(size(h)));
end

% plotting grid
sR = fundamentalSector(odf.SS,varargin{:});
r = plotS2Grid(sR,varargin{:});

% create a new figure if needed
[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});
  
for i = 1:length(h)
  
  if i>1, mtexFig.nextAxis; end

  % compute pole figures
  p = ensureNonNeg(pdf(odf,h{i},r,varargin{:},'superposition',c{i}));
  
  r.plot(p,'TR',h{i},'parent',mtexFig.gca,...
    'smooth','doNotDraw',varargin{:});
  
  % TODO: adapt this to other plots as well
  setappdata(mtexFig.gca,'h',h{i});
end

if isNew % finalize plot
  set(gcf,'tag','pdf');
  setappdata(gcf,'SS',odf.SS);
  setappdata(gcf,'h',h);
  setappdata(gcf,'odf',odf);  
  set(gcf,'Name',['Pole figures of "',inputname(1),'"']);
  
  mtexFig.drawNow('autoPosition');
end

end

% -------------- Tooltip function ---------------------------------
function txt = tooltip(varargin)

% 
dcm_obj = datacursormode(gcf);

hcmenu = dcm_obj.createContextMenu;
%hcmenu = dcm_obj.CurrentDataCursor.uiContextMenu;

if numel(get(hcmenu,'children'))<10
  uimenu(hcmenu, 'Label', 'Mark Equivalent Modes', 'Callback', @markEquivalent);
  uimenu(hcmenu, 'Label', 'Plot Fibre', 'Callback', @localPlotFibre);
  mcolor = uimenu(hcmenu, 'Label', 'Marker color', 'Callback', @display);
  msize = uimenu(hcmenu, 'Label', 'Marker size', 'Callback', @display);
  mshape = uimenu(hcmenu, 'Label', 'Marker shape', 'Callback', @display);
  dcm_obj.UIContextMenu = hcmenu;
end

[r,h,v] = currentVector;
txt = [xnum2str(v) ' at (' int2str(r.theta/degree) ',' int2str(r.rho/degree) ')'];

end

%
function localPlotFibre(varargin)

[r,h] = currentVector;

odf = getappdata(gcf,'odf');

figure
odf.plotFibre(h,r);

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

[r,value,ax] = getDataCursorPos(gcf);

h = getappdata(ax,'h');

% TODO: h should be antipodal if projection is antipodal

end



