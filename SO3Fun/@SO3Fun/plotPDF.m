function plotPDF(SO3F,h,varargin)
% plot pole density function
%
% Syntax
%   plotPDF(odf,[h1,..,hN])
%   plotPDF(odf,{[h11,h12],h2,hN],'superposition',{[c11,c12],c2,cN})
%   plotPDF(odf,pf.h,'superposition',pf.c)
%
% Input
%  odf - @SO3Fun
%  h   - @Miller crystallographic directions
%  c   - structure coefficients
%
% Options
%  resolution    - resolution of the plots
%  superposition - plot superposed pole figures
%
% Flags
%  noTitle   - suppress the Miller indices at the top
%  antipodal - include <VectorsAxes.html antipodal symmetry>
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

% ensure h is a cell array
if ~iscell(h), h = mat2cell(h,1,cellfun(@length,c)); end

if isa(SO3F.SS,'crystalSymmetry')  
  pfAnnotations = @(varargin) [];
else
  pfAnnotations = getMTEXpref('pfAnnotations');
end

% create a new figure if needed
[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});

% maybe we should call this function with the option add2all
if ~isNew && ~check_option(varargin,'parent') && ...
    ((ishold(mtexFig.gca) && length(h)>1) || check_option(varargin,'add2all'))
  plot(SO3F,varargin{:},'add2all');
  return
end

for i = 1:length(h)

  % create a new axis
  if ~isstruct(mtexFig) && i>1, mtexFig.nextAxis; end
  
  % compute pole figures
  pdf = radon(SO3F,h{i},[],varargin{:}).' * c{i}.';
    
  % plot the pole density function
  [~,cax] = plot(pdf,'smooth','doNotDraw','ensureNonNeg',varargin{:});
  mtexTitle(cax(1),char(h{i},'LaTeX'));

  % plot annotations
  pfAnnotations('parent',cax,'doNotDraw','add2all');
  set(cax,'tag','pdf');
  setappdata(cax,'h',h{i});
  setappdata(cax,'SS',SO3F.SS);

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

    [r_local,~,value] = getDataCursorPos(mtexFig);

    txt = [xnum2str(value) ' at (' int2str(r_local.theta/degree) ',' int2str(r_local.rho/degree) ')'];

  end

  function localPlotFibre(varargin)

    [r_local,~,~,ax] = getDataCursorPos(mtexFig);

    figure
    f = fibre(h{mtexFig.children==ax},r_local);
    SO3F.plot(f);

  end

  function markEquivalent(varargin)

    [r_local,~,~,ax] = getDataCursorPos(mtexFig);

    f = orientation(fibre(h{mtexFig.children==ax},r_local,SO3F.CS,SO3F.SS));
    f = eval(SO3F,f);

    [v,vpos] = max(f); %#ok<ASGLU>

    annotate(fibre(vpos));

  end

end
