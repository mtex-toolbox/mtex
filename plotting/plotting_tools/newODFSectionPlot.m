function oS = newODFSectionPlot(CS,varargin)
% generate a new ODF section plot

[mtexFig,isNew] = newMtexFigure('ensureAppdata',...
  {{'ODFSections',[]}},varargin{:});

if ~isNew
  oS = getappdata(mtexFig.parent,'ODFSections');
  if ~isempty(oS), return; end
end

% maybe ODFSection is specified directly
oS = getClass(varargin,'ODFSections');
if ~isempty(oS)
  setappdata(mtexFig.parent,'ODFSections',oS);
  return; 
end

if nargin > 1 && isa(varargin{1},'referenceFrame')
  SS = varargin{1};
  varargin(1) = [];
else
  SS = specimenFrame.default;
end

if nargin > 0 && (isa(CS,'specimenFrame') || isa(SS,'specimenFrame'))
  default = 'phi2';
else
  default = 'axisAngle';
end

switch lower(get_flag(varargin,{'phi2','phi1','gamma','alpha','sigma','axisAngle','pf','ipf','omega','Phi','beta'},default))
  case 'phi2'
    oS = phi2Sections(CS,SS,varargin{:});
  case 'phi1'
    oS = phi1Sections(CS,SS,varargin{:});
  case 'gamma'
    oS = gammaSections(CS,SS,varargin{:});
  case 'alpha'
    oS = alphaSections(CS,SS,varargin{:});
  case 'sigma'
    oS = sigmaSections(CS,SS,varargin{:});    
  case 'axisangle'
    oS = axisAngleSections(CS,SS,varargin{:});
  case 'pf'
    oS = pfSections(CS,SS,varargin{:});
  case 'ipf'
    oS = ipfSections(CS,SS,varargin{:});
  case 'omega'
    oS = omegaSections(CS,SS,varargin{:});
  case 'phi'
    oS = PhiSections(CS,SS,varargin{:});
  otherwise
    error('Unknown section type')
end

setappdata(mtexFig.parent,'ODFSections',oS);
