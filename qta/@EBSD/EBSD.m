function ebsd = EBSD(varargin)
% constructor
%
% *EBSD* is the low level constructor for an *EBSD* object representing EBSD
% data. For importing real world data you might want to use the predefined
% [[ImportEBSDData.html,EBSD interfaces]]. You can also simulate EBSD data
% from an ODF by the command [[ODF.calcEBSD.html,calcEBSD]].
%
%% Syntax
%  ebsd = EBSD(orientations,CS,SS,...,param,val,...)
%
%% Input
%  orientations - @orientation
%  CS,SS        - crystal / specimen @symmetry
%
%% Options
%  Comment  - string
%  phase    - specifing the phase of the EBSD object
%  options  - struct with fields holding properties for each orientation
%  xy       - spatial coordinates n x 2, where n is the number of input orientations
%  unitCell - for internal use
%
%% See also
% ODF/calcEBSD EBSD/calcODF loadEBSD


if nargin==1 && isa(varargin{1},'EBSD') % copy constructor
  ebsd = varargin{1};
  return
else
  rotations = rotation(varargin{:});
end

ebsd.comment = [];

ebsd.comment = get_option(varargin,'comment',[]);
ebsd.rotations = rotations(:);

[ebsd.phaseMap,ignore,ebsd.phase] =  unique(...
  get_option(varargin,'phase',ones(numel(ebsd.rotations),1)));
ebsd.phaseMap(isnan(ebsd.phaseMap)) = 0;

% if all phases are zero replace them by 1
if all(ebsd.phase == 0), ebsd.phase = ones(numel(ebsd.rotations),1);end

% take symmetry from orientations
if nargin >= 1 && isa(varargin{1},'orientation')

  ebsd.SS = get(varargin{1},'SS');
  ebsd.CS = {get(varargin{1},'CS')};

else

  % specimen symmetry
  if nargin >= 3 && isa(varargin{3},'symmetry') && ~isCS(varargin{3})
    ebsd.SS = varargin{3};
  else
    ebsd.SS = get_option(varargin,'SS',symmetry);
  end

  % set up crystal symmetries
  if check_option(varargin,'cs')
    CS = ensurecell(get_option(varargin,'CS',{}));
  elseif nargin >= 2 && ((isa(varargin{2},'symmetry') && isCS(varargin{2}))...
      || (isa(varargin{2},'cell') && any(cellfun('isclass',varargin{2},'symmetry'))))
    CS = ensurecell(varargin{2});
  else
    CS = {symmetry('cubic','mineral','unkown')};
  end
  
  if numel(ebsd.phaseMap)>1 && numel(CS) == 1
    C = repmat(CS,numel(ebsd.phaseMap),1);
    if ebsd.phaseMap(1) <= 0
      C{1} = 'notIndexed';
    end
  elseif max([0;ebsd.phaseMap(:)]) < numel(CS)
    C = CS(ebsd.phaseMap+1);
  
  elseif numel(ebsd.phaseMap) == numel(CS)
    C = CS;
  else
    error('symmetry mismatch')
  end

  ebsd.CS = C;

end


ebsd.options = get_option(varargin,'options',struct);
ebsd.unitCell = get_option(varargin,'unitCell',[]);

ebsd = class(ebsd,'EBSD');

%% remove ignore phases
if check_option(varargin,'ignorePhase')

  del = ismember(ebsd.phaseMap(ebsd.phase),get_option(varargin,'ignorePhase',[]));
  ebsd = subsref(ebsd,~del);

end

%% apply colors
colorOrder = getMTEXpref('EBSDColorNames');
nc = numel(colorOrder);
c = 1;

for ph = 1:numel(ebsd.phaseMap)
  if ~ischar(ebsd.CS{ph}) && isempty(get(ebsd.CS{ph},'color'))
    ebsd.CS{ph} = set(ebsd.CS{ph},'color',colorOrder{mod(c-1,nc)+1});
    c = c+1;
  end
end
