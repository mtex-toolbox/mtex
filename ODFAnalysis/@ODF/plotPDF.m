function plotPDF(odf,h,varargin)
% plot pole figures
%
% Syntax
%   plotPDF(odf,[h1,..,hN])
%   plotPDF(odf,{[h11,h12],h2,hN],'superposition',{[c11,c12],c2,cN})
%   plotPDF(odf,pf.h,'superposition',pf.c)
%
% Input
%  odf - @ODF
%  h   - @Miller crystallographic directions
%  c   - structure coefficients
%
% Options
%  resolution    - resolution of the plots
%  superposition - plot superposed pole figures
%
% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%  complete  - plot entire (hemi)--sphere
%
% See also
% S2Grid/plot annotate savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

% superposition coefficients
if check_option(varargin,'superposition')
  c = get_option(varargin,'superposition');
else
  c = num2cell(ones(size(h)));
end

% ensure crystal symmetry
if ~iscell(h), h = mat2cell(h,1,cellfun(@length,c)); end
argin_check([h{:}],'Miller');
for i = 1:length(h), h{i} = odf.CS.ensureCS(h{i}); end

% plotting grid
sR = fundamentalSector(odf.SS,varargin{:});
r = plotS2Grid(sR,varargin{:});

% create a new figure if needed
[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});
pfAnnotations = getMTEXpref('pfAnnotations');

for i = 1:length(h)
  
  % create a new axis
  mtexFig.nextAxis;

  % compute pole figures
  p = ensureNonNeg(odf.calcPDF(h{i},r,varargin{:},'superposition',c{i}));
  
  % plot the pole figure
  mtexTitle(mtexFig.gca,char(h{i},'LaTeX'));
  [~,caxes] = r.plot(p,'smooth','doNotDraw',varargin{:});
  
  % plot annotations
  for cax = caxes(:).'
    pfAnnotations('parent',cax,'doNotDraw');
    setappdata(cax,'h',h{i});
    set(cax,'tag','pdf');
    setappdata(cax,'SS',odf.SS);
  end
  
end

if isNew % finalize plot
  set(gcf,'Name',['Pole figures of "',inputname(1),'"']);
  
  dcm = mtexFig.dataCursorMenu;
  uimenu(dcm, 'Label', 'Mark Equivalent Modes', 'Callback', @markEquivalent);
  uimenu(dcm, 'Label', 'Plot Fibre', 'Callback', @localPlotFibre);
  %mcolor = uimenu(hcmenu, 'Label', 'Marker color', 'Callback', @display);
  %msize = uimenu(hcmenu, 'Label', 'Marker size', 'Callback', @display);
  %mshape = uimenu(hcmenu, 'Label', 'Marker shape', 'Callback', @display);
  
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
  
  
  if check_option(varargin,'3d'), fcw(gcf,'-link'); end
  
  
end

% -------------- Tooltip function ---------------------------------

  function txt = tooltip(varargin)

    [r_local,v] = getDataCursorPos(mtexFig);

    txt = [xnum2str(v) ' at (' int2str(r_local.theta/degree) ',' int2str(r_local.rho/degree) ')'];

  end
  
  function localPlotFibre(varargin)

    [r_local,~,ax] = getDataCursorPos(mtexFig);

    figure
    f = fibre(h{mtexFig.children==ax},r_local);
    odf.plot(f);

  end

  function markEquivalent(varargin)

    [r_local,~,ax] = getDataCursorPos(mtexFig);
    
    fibre = orientation('fibre',h{mtexFig.children==ax},r_local,odf.CS,odf.SS);
    f = eval(odf,fibre); %#ok<EVLC>

    [v,vpos] = max(f); %#ok<ASGLU>

    annotate(fibre(vpos));

  end

end
