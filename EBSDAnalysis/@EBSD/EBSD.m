classdef EBSD < dynProp & dynOption & misorientationAnalysis
  % constructor
  %
  % *EBSD* is the low level constructor for an *EBSD* object representing EBSD
  % data. For importing real world data you might want to use the predefined
  % <ImportEBSDData.html EBSD interfaces>. You can also simulate EBSD data
  % from an ODF by the command <ODF.calcEBSD.html calcEBSD>.
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
    
    allCS = {}            % crystal symmetries
    phaseMap = []         %
    rotations = rotation  %
    unitCell = []         %
    
  end
  
  properties (Dependent = true)
    phase           % phase
    phaseId         % 
    orientations    %
    CS              % crystal symmetry of one specific phase
    mineral         % mineral name of one specific phase
    allMinerals     % all mineral names
    indexedPhasesId % id's of all non empty indexed phase
    weights         %
    color           % color of one specific phase
  end
  
  methods
    
    function ebsd = EBSD(varargin)
                  
      ebsd.rotations = reshape(rotation(varargin{:}),[],1);
            
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
        ebsd.allCS = {varargin{1}.CS};
        
        
      else % otherwise there can be more then one phase
        
        % CS given as option
        if check_option(varargin,'cs')
          
          ebsd.allCS = ensurecell(get_option(varargin,'CS',{}));
          
          % CS given as second argument
        elseif nargin >= 2 && ((isa(varargin{2},'symmetry') && isCS(varargin{2}))...
            || (isa(varargin{2},'cell') && any(cellfun('isclass',varargin{2},'symmetry'))))
          ebsd.allCS = ensurecell(varargin{2});
          
        else % CS not given -> guess cubic
          
          ebsd.allCS = {symmetry('cubic','mineral','unkown')};
          
        end
        
        % check number of symmetries and phases coincides
        if numel(ebsd.phaseMap)>1 && length(ebsd.allCS) == 1
          
          ebsd.allCS = repmat(ebsd.allCS,numel(ebsd.phaseMap),1);
          
          if ebsd.phaseMap(1) <= 0
            ebsd.allCS{1} = 'notIndexed';
          end
          
        elseif max([0;ebsd.phaseMap(:)]) < length(ebsd.allCS)
          
          ebsd.allCS = ebsd.allCS(ebsd.phaseMap+1);
          
        elseif sum(ebsd.phaseMap>0) == numel(ebsd.allCS)
          
          ebsd.allCS(ebsd.phaseMap>0) = ebsd.allCS;
          ebsd.allCS(ebsd.phaseMap<=0) = repcell('notIndexed',1,sum(ebsd.phaseMap<=0));
          
        elseif numel(ebsd.phaseMap) ~= length(ebsd.allCS)
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
        if isa(ebsd.allCS{ph},'symmetry') && isempty(ebsd.allCS{ph}.color)
          ebsd.allCS{ph}.color = colorOrder{mod(c-1,nc)+1};
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
        find(~cellfun('isclass',obj.allCS,'char')),...
        unique(obj.phaseId));
    
      id = id(:).';
      
    end
      
    function ori = get.orientations(ebsd)
      
      % ensure single phase
      [ebsd,cs] = checkSinglePhase(ebsd);
      
      ori = orientation(ebsd.rotations,cs);
    end
        
    
    function cs = get.CS(ebsd)
      
      % ensure single phase
      id = ebsd.indexedPhasesId;
               
      if numel(id)>1     
              
        error('MTEX:MultiplePhases',['This operatorion is only permitted for a single phase! ' ...
          'Please see ' doclink('ebsdModifyData','modify EBSD data')  ...
          '  for how to restrict EBSD data to a single phase.']);
      end
      cs = ebsd.allCS{id};
            
    end
    
    function ebsd = set.CS(ebsd,cs)
            
      if isa(cs,'symmetry')      
        % ensure single phase
        id = unique(ebsd.phaseId);
      
        if numel(id) == 1
          ebsd.allCS{id} = cs;
        else
          % TODO
        end
      elseif iscell(cs)    
        if length(cs) == numel(ebsd.phaseMap)
          ebsd.allCS = cs;
        elseif length(CS) == numel(ebsd.indexedPhasesId)
          ebsd.allCS = repcell('not indexed',1,numel(ebsd.phaseMap));
          ebsd.allCS(ebsd.indexedPhasesId) = cs;
        else
          error('The number of symmetries specified is less than the largest phase id.')
        end        
      else
        error('Assignment should be of type symmetry');
      end
    end
    
    function mineral = get.mineral(ebsd)
      
      % ensure single phase
      [~,cs] = checkSinglePhase(ebsd);
      mineral = cs.mineral;      
      
    end
    
    
    function ebsd = set.color(ebsd,color)
      
      ebsd.CS.color = color;
      
    end
    
    function c = get.color(ebsd)
      
      % notindexed phase should be white by default
      if all(isNotIndexed(ebsd))
        c = ones(1,3); 
        return
      end
      
      % ensure single phase and extract symmetry
      cs = ebsd.CS;
            
      % extract colormaps
      cmap = getMTEXpref('EBSDColors');
      colorNames = getMTEXpref('EBSDColorNames');
  
      if isempty(cs.color)
        c = cmap{ebsd.phaseId};
      elseif ischar(cs.color)
        c = cmap{strcmpi(cs.color,colorNames)};
      else
        c = cs.color;
      end
      
    end
    
    function minerals = get.allMinerals(ebsd)
      isCS = cellfun('isclass',ebsd.allCS,'symmetry');
      minerals(isCS) = cellfun(@(x) x.mineral,ebsd.allCS(isCS),'uniformoutput',false);
      minerals(~isCS) = ebsd.allCS(~isCS);
    end
    
    function w = get.weights(ebsd)
      if ebsd.isProp('weights')
        w = ebsd.prop.weights;
      else
        w = ones(size(ebsd));
      end      
    end
    
    function ebsd = set.weights(ebsd,weights)
      ebsd.prop.weights = weights;
    end
    
  end
      
end
