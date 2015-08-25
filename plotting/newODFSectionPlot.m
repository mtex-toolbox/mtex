function oS = newODFSectionPlot(CS,SS,varargin)
% generate a new ODF section plot

[mtexFig,isNew] = newMtexFigure('ensureAppdata',...
  {{'ODFSections',[]}},varargin{:});

if ~isNew
  oS = getappdata(mtexFig.parent,'ODFSections');
  return
end

% maybe ODFSection is specified directly
oS = getClass(varargin,'ODFSections');
if ~isempty(oS), return; end

if isa(CS,'specimenSymmetry') || isa(SS,'specimenSymmetry')
  default = 'phi2';
else
  default = 'axisAngle';
end

switch get_flag(varargin,{'phi2','phi1','gamma','sigma','axisAngle','pf','ipf','omega'},default)
  case 'phi2'
    oS = phi2Sections(CS,SS,varargin{:});
  case 'phi1'
    oS = phi1Sections(CS,SS,varargin{:});
  case 'gamma'
    oS = gammaSections(CS,SS,varargin{:});
  case 'sigma'
    oS = sigmaSections(CS,SS,varargin{:});    
  case 'axisAngle'
    oS = axisAngleSections(CS,SS,varargin{:});
  case 'pf'
    oS = pfSections(CS,SS,varargin{:});
  case 'ipf'
    oS = ipfSections(CS,SS,varargin{:});
  case 'omega'
    oS = omegaSections(CS,SS,varargin{:});
  otherwise
    error('Unknown section type')
end

setappdata(mtexFig.parent,'ODFSections',oS);