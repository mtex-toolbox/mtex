classdef EBSD < dynProp & dynOption
  % constructor
  %
  % *EBSD* is the low level constructor for an *EBSD* object representing EBSD
  % data. For importing real world data you might want to use the predefined
  % [[ImportEBSDData.html,EBSD interfaces]]. You can also simulate EBSD data
  % from an ODF by the command [[ODF.calcEBSD.html,calcEBSD]].
  %
  % Syntax
  %   ebsd = EBSD(orientations,CS,...,param,val,...)
  %
  % Input
  %  orientations - @orientation
  %  CS           - crystal / specimen @symmetry
  %
  % Options
  %  phase    - specifing the phase of the EBSD object
  %  options  - struct with fields holding properties for each orientation
  %  xy       - spatial coordinates n x 2, where n is the number of input orientations
  %  unitCell - for internal use
  %
  % See also
  % ODF/calcEBSD EBSD/calcODF loadEBSD
  
  properties
    
    CS = {}               % crystal symmetries
    phaseMap = []         %
    rotations = rotation  %
    unitCell = []         %
    
  end
  
  properties (Dependent = true)
    phase           % phase
    phaseId         % 
    orientations    %
    mineral         % mineral name
    allMinerals     % all mineral names
    indexedPhasesId % id's of all non empty indexed phase
  end
  
  methods
    
    function ebsd = EBSD(varargin)
      
      if nargin==1 && isa(varargin{1},'EBSD') % copy constructor
        obj = varargin{1};
        
        ebsd.CS = obj.CS;
        ebsd.phaseMap = obj.phaseMap;
        ebsd.rotations = obj.rotations;
        ebsd.unitCell = obj.unitCell;
        ebsd.phase = obj.phase;
        ebsd.prop = obj.prop;
        ebsd.opt = obj.opt;
        return
      else
        ebsd.rotations = reshape(rotation(varargin{:}),[],1);
      end
      
      % extract additional properties
      ebsd.prop = get_option(varargin,'options',struct);
      
      % extract phases
      [ebsd.phaseMap,~,ebsd.prop.phaseId] =  unique(...
        get_option(varargin,'phase',ones(length(ebsd.rotations),1)));
      ebsd.phaseMap(isnan(ebsd.phaseMap)) = 0;
      
      % TODO!!
      % if all phases are zero replace them by 1
      %if all(ebsd.phase == 0), ebsd.phase = ones(length(ebsd),1);end
      
      % -------------- set up symmetries --------------------------
      
      % if input is orientation -> only one phase
      if nargin >= 1 && isa(varargin{1},'orientation')
        
        % take symmetry from orientations
        ebsd.CS = {get(varargin{1},'CS')};
        
        
      else % otherwise there can be more then one phase
        
        % CS given as option
        if check_option(varargin,'cs')
          
          ebsd.CS = ensurecell(get_option(varargin,'CS',{}));
          
          % CS given as second argument
        elseif nargin >= 2 && ((isa(varargin{2},'symmetry') && isCS(varargin{2}))...
            || (isa(varargin{2},'cell') && any(cellfun('isclass',varargin{2},'symmetry'))))
          ebsd.CS = ensurecell(varargin{2});
          
        else % CS not given -> guess cubic
          
          ebsd.CS = {symmetry('cubic','mineral','unkown')};
          
        end
        
        % check number of symmetries and phases coincides
        if numel(ebsd.phaseMap)>1 && length(ebsd.CS) == 1
          
          ebsd.CS = repmat(ebsd.CS,numel(ebsd.phaseMap),1);
          
          if ebsd.phaseMap(1) <= 0
            ebsd.CS{1} = 'notIndexed';
          end
          
        elseif max([0;ebsd.phaseMap(:)]) < length(ebsd.CS)
          
          ebsd.CS = ebsd.CS(ebsd.phaseMap+1);
          
        elseif numel(ebsd.phaseMap) ~= length(ebsd.CS)
          error('symmetry mismatch')
        end
      end
      
      % get unit cell
      ebsd.unitCell = get_option(varargin,'unitCell',[]);
      
      % remove ignore phases
      if check_option(varargin,'ignorePhase')
        
        del = ismember(ebsd.phaseMap(ebsd.phaseId),get_option(varargin,'ignorePhase',[]));
        ebsd = subSet(ebsd,~del);
        
      end
      
      % apply colors
      colorOrder = getMTEXpref('EBSDColorNames');
      nc = numel(colorOrder);
      c = 1;
      
      for ph = 1:numel(ebsd.phaseMap)
        if ~ischar(ebsd.CS{ph}) && isempty(get(ebsd.CS{ph},'color'))
          ebsd.CS{ph} = set(ebsd.CS{ph},'color',colorOrder{mod(c-1,nc)+1});
          c = c+1;
        end
      end
    end
    
    % --------------------------------------------------------------
    function phaseId = get.phaseId(ebsd)
      phaseId = ebsd.prop.phaseId;
    end
    
    function phase = get.phase(ebsd)
      phase = ebsd.phaseMap(ebsd.prop.phaseId);
    end
    
    function ebsd = set.phaseId(ebsd,phaseId)
      ebsd.prop.phaseId = phaseId;
    end
    
    function ebsd = set.phase(ebsd,phase)
      
      phId = zeros(size(ph));
      for i = 1:numel(ebsd.phaseMap)
        phId(phase==ebsd.phaseMap(i)) = i;
      end
      
      ebsd.prop.phaseId = phaseId;
            
    end
    
    function id = get.indexedPhasesId(obj)
      
      id = intersect(...
        find(~cellfun('isclass',obj.CS,'char')),...
        unique(obj.phaseId));
    
    end
      
    function ori = get.orientations(ebsd)
      
      % ensure single phase
      [ebsd,cs] = checkSinglePhase(ebsd);
      
      ori = orientation(ebsd.rotations,cs);
    end
        
    
    function mineral = get.mineral(ebsd)
      
      % ensure single phase
      [~,cs] = checkSinglePhase(ebsd);
      mineral = cs.mineral;      
      
    end
    
    function minerals = get.allMinerals(ebsd)
      isCS = cellfun('isclass',ebsd.CS,'symmetry');
      minerals(isCS) = cellfun(@(x) x.mineral,ebsd.CS(isCS),'uniformoutput',false);
      minerals(~isCS) = ebsd.CS(~isCS);
    end
    
  end
      
end
