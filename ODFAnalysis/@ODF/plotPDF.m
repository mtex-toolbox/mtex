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
  p = ensureNonNeg(odf.calcPDF(h{i},r,varargin{:},'superposition',c{i}));
  
  r.plot(p,'parent',mtexFig.gca,'smooth','doNotDraw',varargin{:});
  mtexTitle(mtexFig.gca,char(h{i},'LaTeX'));
  
end

if isNew % finalize plot
  set(gcf,'tag','pdf');
  setappdata(gcf,'SS',odf.SS);
  setappdata(gcf,'h',h);
  set(gcf,'Name',['Pole figures of "',inputname(1),'"']);
  
  dcm = mtexFig.dataCursorMenu;
  uimenu(dcm, 'Label', 'Mark Equivalent Modes', 'Callback', @markEquivalent);
  uimenu(dcm, 'Label', 'Plot Fibre', 'Callback', @localPlotFibre);
  %mcolor = uimenu(hcmenu, 'Label', 'Marker color', 'Callback', @display);
  %msize = uimenu(hcmenu, 'Label', 'Marker size', 'Callback', @display);
  %mshape = uimenu(hcmenu, 'Label', 'Marker shape', 'Callback', @display);
  
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
  
  if check_option(varargin,'3d')
    rotate3d(gcf);
    linkprop(mtexFig.children, 'CameraPosition');
  end
end

% -------------- Tooltip function ---------------------------------

  function txt = tooltip(varargin)

    [r_local,v] = getDataCursorPos(mtexFig);

    txt = [xnum2str(v) ' at (' int2str(r_local.theta/degree) ',' int2str(r_local.rho/degree) ')'];

  end
  
  function localPlotFibre(varargin)

    [r_local,~,ax] = getDataCursorPos(mtexFig);

    figure
    odf.plotFibre(h{mtexFig.children==ax},r_local);

  end

  function markEquivalent(varargin)

    [r_local,~,ax] = getDataCursorPos(mtexFig);
    
    fibre = orientation('fibre',h{mtexFig.children==ax},r_local,odf.CS,odf.SS);
    f = eval(odf,fibre); %#ok<EVLC>

    [v,vpos] = max(f); %#ok<ASGLU>

    annotate(fibre(vpos));

  end

end



%


%






