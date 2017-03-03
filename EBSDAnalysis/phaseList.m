classdef phaseList
% handles a list of phases

  properties
    phaseId = []    % index to a phase map - 1,2,3,4,....    
    CSList = {}     % list of crystal symmetries
    phaseMap = []   % phase numbers as used in the data - 0,5,10,11,...
  end
  
  properties (Dependent = true)
    phase           % phase
    isIndexed       % indexed measurements
    CS              % crystal symmetry of one specific phase
    mineral         % mineral name of one specific phase
    mineralList     % list of mineral names
    indexedPhasesId % id's of all non empty indexed phase
    color           % color of one specific phase
  end
    
  methods
    
    function pL = phaseList(phases,CSList)

      if nargin == 2, pL = pL.init(phases,CSList); end
      
    end
    
    % --------------------------------------------------------------
    
    function pL = init(pL,phases,CSList)
      % extract phases
      [pL.phaseMap,~,pL.phaseId] =  unique(phases);
              
      pL.phaseMap(isnan(pL.phaseMap)) = 0;
      
      pL.CSList = ensurecell(CSList);
      
      % check number of symmetries and phases coincides
      if numel(pL.phaseMap)>1 && length(pL.CSList) == 1
        
        % if only one symmetry was specified 
        % apply this symmetry to all phases except a zero phase
        pL.CSList = repmat(pL.CSList,numel(pL.phaseMap),1);
          
        if pL.phaseMap(1) <= 0, pL.CSList{1} = 'notIndexed'; end

      elseif numel(pL.phaseMap) > length(pL.CSList)
        
        % if to few symmetries have been specified
        % prepend as many  not indexed phases as required
        pL.CSList = [repcell('notIndexed',1,numel(pL.phaseMap)-length(pL.CSList)),pL.CSList];
        
      elseif numel(pL.phaseMap) < length(pL.CSList) 
        
        % if more symmetries have been specified then phases are present in
        % the data 
        
        first = isa(pL.CSList{1},'symmetry');
      
        % if everything is indexed but phase is 0
        if (max(pL.phaseMap) == 0) && ~first
          
          pL.phaseMap = [-1;pL.phaseMap(:)];
          pL.phaseId = 1 + pL.phaseId;
          
        % the normal case: there are simply some phases missing
        % all we have to do is to extend the phaseMap
        elseif ~first + max(pL.phaseMap) <= numel(pL.CSList)
          
          % 
          pL.phaseId = ~first + pL.phaseMap(pL.phaseId);
          
          % extend phaseMap
          pL.phaseMap = first + (0:numel(pL.CSList)-1);
          
        else
        
          % no zero phase - maybe everything was indexed
          if pL.phaseMap(1) > 0 && isa(pL.CSList{1},'symmetry')
            pL.phaseId = pL.phaseId + 1;
            pL.phaseMap = [0;pL.phaseMap];
          end
          
          % append some phase numbers for the not existing phases
          pL.phaseMap = [pL.phaseMap;max(pL.phaseMap) + (1:length(pL.CSList)-numel(pL.phaseMap))];
        end
      end

      % ensure that there is at least one notIndexed phase
      % by prepending it !! TODO
      % this probably requires to specify phaseMap as an option    
      if all(cellfun(@(x) isa(x,'symmetry'),pL.CSList))
        pL.CSList = [{'notIndexed'};pL.CSList(:)];
        pL.phaseId = pL.phaseId + 1;
        if  ismember(0,pL.phaseMap)
          pL.phaseMap = [-1;pL.phaseMap(:)];
        else
          pL.phaseMap = [0;pL.phaseMap(:)];
        end
      end
      
      % apply colors
      colorOrder = getMTEXpref('EBSDColorNames');
      nc = numel(colorOrder);
      c = 1;
      
      for ph = 1:numel(pL.phaseMap)
        if isa(pL.CSList{ph},'symmetry') && isempty(pL.CSList{ph}.color)
          pL.CSList{ph}.color = colorOrder{mod(c-1,nc)+1};
          c = c+1;
        end
      end
      
    end
    
    function phase = get.phase(pL)
      phase = zeros(size(pL));
      isIndex = pL.phaseId>0;
      phase(isIndex) = pL.phaseMap(pL.phaseId(isIndex));
    end
    
    function pL = set.phase(pL,phase)
      
      if numel(phase) == 1
        phase = repmat(phase,size(pL.phaseId));
      elseif numel(phase) == numel(pL.phaseId)
        phase = reshape(phase,size(pL.phaseId));
      else
        error('List of phases has wrong size.')
      end
      
      phId = zeros(size(phase));
      for i = 1:numel(pL.phaseMap)
        phId(phase==pL.phaseMap(i)) = i;
      end
      
      pL.phaseId = phId;
            
    end

    function id = get.indexedPhasesId(pL)
      
      id = intersect(...
        find(~cellfun('isclass',pL.CSList,'char')),...
        unique(pL.phaseId));
    
      id = id(:).';
      
    end
      
    function cs = get.CS(pL)
      
      % ensure single phase
      id = checkSinglePhase(pL);
                          
      if numel(id) > 1
        cs = pL.CSList(id);
      else
        cs = pL.CSList{id};
      end
                
    end
    
    function pL = set.CS(pL,cs)
            
      if isa(cs,'symmetry')      
        % ensure single phase
        id = unique(pL.phaseId);
      
        if numel(id) == 1
          pL.CSList{id} = cs;
        else
          % TODO
        end
      elseif iscell(cs)    
        if length(cs) == numel(pL.phaseMap)
          pL.CSList = cs;
        elseif length(cs) == numel(pL.indexedPhasesId)
          pL.CSList = repcell('notIndexed',1,numel(pL.phaseMap));
          pL.CSList(pL.indexedPhasesId) = cs;
        else
          error('The number of symmetries specified is less than the largest phase id.')
        end        
      else
        error('Assignment should be of type symmetry');
      end
         
      % set CSList also to all children
      for fn = fieldnames(pL).'
        try %#ok<TRYNC>
         if isa(pL.(char(fn)),'phaseList')
           pL.(char(fn)).CSList = pL.CSList;
         end
        end
      end
      
    end
    
    function mineral = get.mineral(pL)
      
      cs = pL.CS;
      if iscell(cs)
        mineral = {cs{1}.mineral,cs{2}.mineral};
      else
        mineral = cs.mineral;
      end
    end
    
    
    function pL = set.color(pL,color)
      
      pL.CS.color = color;
      
    end
    
    function c = get.color(pL)
      
      % notindexed phase should be white by default
      if ~any(pL.isIndexed)
        c = ones(1,3); 
        return
      end
      
      % ensure single phase and extract symmetry
      cs = pL.CS;
            
      % extract colormaps
      cmap = getMTEXpref('EBSDColors');
      colorNames = getMTEXpref('EBSDColorNames');
  
      if isempty(cs.color)
        c = cmap{pL.phaseId};
      elseif ischar(cs.color)
        c = cmap{strcmpi(cs.color,colorNames)};
      else
        c = cs.color;
      end
      
    end
    
    function minerals = get.mineralList(pL)
      isCS = cellfun('isclass',pL.CSList,'crystalSymmetry');
      minerals(isCS) = cellfun(@(x) x.mineral,pL.CSList(isCS),'uniformoutput',false);
      minerals(~isCS) = pL.CSList(~isCS);
    end

    function isInd = get.isIndexed(pL)
      notIndexedPhase = [0,find(cellfun('isclass',pL.CSList,'char'))];
      isInd = ~any(ismember(pL.phaseId,notIndexedPhase),2);
    end
    
    function out = isempty(pL)
      out = isempty(pL.phaseId);
    end
    
    function varargout = size(pL,varargin)
      [varargout{1:nargout}] = size(pL.phaseId(:,1),varargin{:});
    end
    
    function out = length(pL)
      out = size(pL.phaseId,1);
    end

    function e = end(pL,i,n)

      if n==1
        e = size(pL.phaseId,1);
      else
        e = size(pL.phaseId,i);
      end
    end
       
    function id = checkSinglePhase(pL)
      % ensure single phase
      
      phaseId = pL.phaseId; %#ok<*PROP>
      phaseId = phaseId(~any(isnan(pL.phaseId),2),:);
      id = unique(phaseId,'rows');
                           
      if numel(id)>size(pL.phaseId,2)     
              
        error('MTEX:MultiplePhases',['This operatorion is only permitted for a single phase! ' ...
          'Please see ' doclink('EBSDModifyData','modify EBSD data')  ...
          '  for how to restrict EBSD data to a single phase.']);
        
      elseif isempty(id) || ~all(any(bsxfun(@eq,id,pL.indexedPhasesId(:)),1))
        error('MTEX:NoPhase','There are no indexed data in this variable!');
      end
      
    end
  end
end
