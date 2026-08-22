classdef phaseList
% handles a list of phases

  properties
    phaseId = []    % index to a phase map - 1,2,3,4,....    
    CSList = []     % list of crystal symmetries
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
    colorList       % list of all mineral colors
  end
    
  methods
    
    function pL = phaseList(phases,CSList)

      if nargin == 2, pL = pL.init(phases,CSList); end
      
    end
    
    % --------------------------------------------------------------
    
    function pL = init(pL,phases,CSList)

      phases = phases(:);
      phases(isnan(phases)) = 0;

      if isempty(phases)
        pL.phaseMap = zeros(0,1);
        pL.phaseId  = zeros(0,1);
      else
        mn = min(phases);  mx = max(phases);
        
        shift   = 1 - mn;
        present = false(mx - mn + 1, 1);
        present(phases + shift) = true;
        phaseMap = find(present) - shift;      % sorted unique values (column)
        lut = zeros(mx - mn + 1, 1);
        lut(phaseMap + shift) = 1:numel(phaseMap);
        pL.phaseMap = phaseMap;
        pL.phaseId  = lut(phases + shift);
  
      end

      pL.CSList = CSList;
      
      % check number of symmetries and phases coincides
      if numel(pL.phaseMap)>1 && isscalar(pL.CSList)
        
        % if only one symmetry was specified 
        % apply this symmetry to all phases except a zero phase
        pL.CSList = repmat(pL.CSList,numel(pL.phaseMap),1);
          
        if pL.phaseMap(1) <= 0, pL.CSList(1) = notIndexed; end

      elseif numel(pL.phaseMap) > length(pL.CSList)
        
        % if to few symmetries have been specified
        % prepend as many  not indexed phases as required
        pL.CSList = [repmat(notIndexed,1,numel(pL.phaseMap)-length(pL.CSList)),pL.CSList];
        
      elseif numel(pL.phaseMap) < length(pL.CSList) 
        
        % if more symmetries have been specified then phases are present in
        % the data 
        
        firstIndexed = pL.CSList(1).isIndexed;
      
        % if everything is indexed but phase is 0
        if (max(pL.phaseMap) == 0) && ~firstIndexed
          
          pL.phaseMap = [-1;pL.phaseMap(:)];
          pL.phaseId = 1 + pL.phaseId;
          
        % the normal case: there are simply some phases missing
        % all we have to do is to extend the phaseMap
        elseif ~firstIndexed + max(pL.phaseMap) <= numel(pL.CSList)
          
          % 
          pL.phaseId = ~firstIndexed + pL.phaseMap(pL.phaseId);
          
          % extend phaseMap
          pL.phaseMap = firstIndexed + (0:numel(pL.CSList)-1);
          
        else
        
          % no zero phase - maybe everything was indexed
          if pL.phaseMap(1) > 0 && pL.CSList(1).isIndexed
            pL.phaseId = pL.phaseId + 1;
            pL.phaseMap = [0;pL.phaseMap];
          end
          
          % append some phase numbers for the not existing phases
          pL.phaseMap = [pL.phaseMap;max(pL.phaseMap) + (1:length(pL.CSList)-numel(pL.phaseMap)).'];
        end
      end

      % ensure that there is at least one notIndexed phase
      % by prepending it !! TODO
      % this probably requires to specify phaseMap as an option    
      if all([pL.CSList.isIndexed])
        pL.CSList = [notIndexed, pL.CSList(:).'];
        pL.phaseId = pL.phaseId + 1;
        if  ismember(0,pL.phaseMap)
          pL.phaseMap = [-1;pL.phaseMap(:)];
        else
          pL.phaseMap = [0;pL.phaseMap(:)];
        end
      end
      
      % apply colors
      colorOrder = getMTEXpref('PhaseColorOrder');
      nc = numel(colorOrder);
      c = 1;
      
      for ph = 1:numel(pL.phaseMap)
        if pL.CSList(ph).isIndexed && isempty(pL.CSList(ph).color)
          pL.CSList(ph).color = str2rgb(colorOrder{mod(c-1,nc)+1});
          c = c+1;
        end
      end
      
    end
    
    function phase = get.phase(pL)
      phase = zeros(size(pL.phaseId));
      isIndex = pL.phaseId>0;
      phase(isIndex) = pL.phaseMap(pL.phaseId(isIndex));

      % a per entry view takes the shape of the object, while phaseId stays a
      % column (#2128) - guarded, a @grainBoundary has an n x 2 phaseId
      if numel(phase) == prod(size(pL)) %#ok<PSIZE>
        phase = reshape(phase,size(pL));
      end
    end
    
    function pL = set.phase(pL,phase)
      
      if isscalar(phase)
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
      
      id = intersect(find([pL.CSList.isIndexed]), unique(pL.phaseId));
    
      id = id(:).';
      
    end
      
    function cs = get.CS(pL)
      
      % ensure single phase
      id = checkSinglePhase(pL);
      cs = pL.CSList(id);

    end
      
    
    function pL = set.CS(pL,cs)
          
      if isa(cs,'symmetry')
        
        id = cs2phaseId(pL,cs);
        
        % if not yet in CSlist append
        if id == 0
          pL.CSList(end+1) = cs;
          
          pL.phaseId = length(pL.CSList) * ones(size(pL.phaseId));          
          
          pL.phaseMap(end+1) = max(pL.phaseMap)+1;
          
        else
          
          pL.CSList(id) = cs;
          pL.phaseId = id * ones(size(pL.phaseId));

          return

        end

      elseif iscell(cs)    
        if length(cs) == numel(pL.phaseMap)
          pL.CSList = cs;
        elseif length(cs) == numel(pL.indexedPhasesId)
          pL.CSList = repmat(notIndexed,1,numel(pL.phaseMap));
          pL.CSList(pL.indexedPhasesId) = cs;
        else
          error('The number of symmetries specified is less than the largest phase id.')
        end        
      else
        error('Assignment should be of type symmetry');
      end
         
      % set CSList also to all children
      for fn = setdiff(fieldnames(pL).','grainSize')
        try %#ok<TRYNC>
         if isa(pL.(char(fn)),'phaseList')
           pL.(char(fn)).CSList = pL.CSList;
           pL.(char(fn)).phaseMap = pL.phaseMap;
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

    function pL = set.mineral(pL,name)      
      pL.CS.mineral = name;
    end
    
    function pL = set.color(pL,color)
      pL.CS.color = color;
    end
    
    function rgb = get.color(pL)

      % A not indexed phase carries a name and a colour of its own since
      % @notIndexed took both, so ask it rather than answering "no colour"
      % for every one of them. pL.CS is no help here - checkSinglePhase
      % errors on a purely not indexed list. An unnamed one still comes back
      % NaN, because that is the colour @notIndexed gives itself.
      if ~any(pL.isIndexed)
        id = unique(pL.phaseId(pL.phaseId > 0));
        if isscalar(id) && ~isempty(pL.CSList(id).color)
          rgb = str2rgb(pL.CSList(id).color);
        else
          rgb = nan(1,3);
        end
        return
      end

      % ensure single phase and extract symmetry
      cs = pL.CS;
            
      % if not set use predefined color order
      if isempty(cs.color)
        colors = getMTEXpref('PhaseColorOrder');
        rgb = colors{pL.phaseId};
      else
        rgb = cs.color;
      end
      
      % ensure its numeric
      rgb = str2rgb(rgb);
      
    end
    
    function cList = get.colorList(pL)
      cList = cat(1,pL.CSList.color);
    end


    function minerals = get.mineralList(pL)
      minerals = {pL.CSList.mineral};
    end

    function isInd = get.isIndexed(pL)
      notIndexedPhase = [0,find(~[pL.CSList.isIndexed])];
      isInd = ~any(isnan(pL.phaseId) | ismember(pL.phaseId,notIndexedPhase),2);
      isInd = reshape(isInd, size(pL));
    end
    
    function out = isempty(pL)
      out = isempty(pL.phaseId);
    end
    
    function varargout = size(pL,varargin)
      % a phase list is always a column vector - note that phaseId itself
      % may have two columns, e.g. for boundaries which store the phases on
      % both sides. For an empty phase list phaseId is 0 x 0, hence indexing
      % its first column would fail.
      if isempty(pL.phaseId)
        [varargout{1:nargout}] = size(zeros(0,1),varargin{:});
      else
        [varargout{1:nargout}] = size(pL.phaseId(:,1),varargin{:});
      end
    end
    
    function out = numel(pL)
      %st = dbstack('-completenames');
      st = dbstack(1);
      %assignin("base","st",st);
      if ~isempty(st) && (strcmp(st(1).name,'resolveVariableSize') || ...
          strcmp(st(1).name,'VEDataAttributes.VEDataAttributes'))
        out = 1;
      else        
        out = size(pL.phaseId,1);
        %out = 1;
      end
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
       
    function out = isSinglePhase(pL)
      
      % consider only indexed
      phaseId = pL.phaseId(pL.isIndexed,:);
      phaseId = phaseId(~any(isnan(phaseId),2),:);
      id = unique(phaseId,'rows');
      
      out = numel(id) <= size(pL.phaseId,2) ;
      
    end
    
    function id = checkSinglePhase(pL,phaseId)
      % ensure single phase
      
      if nargin == 1, phaseId = pL.phaseId; end

      % ignore nan
      phaseId = phaseId(all(phaseId>0,2),:);
      
      % ignore not indexed
      notIndexed = find(~[pL.CSList.isIndexed]);
      for k = 1:length(notIndexed)
        phaseId(any(phaseId == notIndexed(k),2),:) = [];
      end

      if isempty(phaseId)
        mtexError([...
          '----------------------------------------------------------------\n'...
          ' There are no indexed data in this variable!\n' ...
          ' Maybe you misspelled a phase name?\n' ...
          '----------------------------------------------------------------\n']);
        error('MTEX:NoPhase','');
      
      elseif ~all(all(phaseId == phaseId(1,:)))

        id2 = find(~all(phaseId == phaseId(1,:),2),1);

        mtexError([...
          '----------------------------------------------------------------\n'...
          ' Your variable contains the phases: ' ...
          pL.mineralList{phaseId(1,1)} ', ' pL.mineralList{phaseId(id2,1)} '\n\n' ...
          ' However, you are executing a command that is only permitted for a single phase!\n\n' ...
          ' Please read the chapter ' doclink('EBSDSelect','"select EBSD data"')  ...
          ' for how to restrict EBSD data or grains to a single phase.\n' ...
          '----------------------------------------------------------------\n']);

      end

      id = phaseId(1,:);
             
    end
    
  end
  
  
  methods (Hidden = true)
    
    function id = cs2phaseId(pL,cs)
      
      if ((ischar(cs) || isstring(cs)) && strcmpi(cs,'notIndexed')) || ...
          isa(cs,'notIndexed')
        id = 1;
        return;
      elseif ~isa(cs,'crystalSymmetry')
        id = 0;
        return;
      end
      
      for id = 1:length(pL.CSList)
        if pL.CSList(id) == cs || (~isempty(cs.mineral) && ...
            strcmp(pL.CSList(id).mineral,cs.mineral))
          return
        end
      end
      id = 0;
      
    end
    
    function phId = name2id(pL,phName)
      % convert phase name to id
              
      if ischar(phName) || isstring(phName)

        phaseNumbers = cellfun(@num2str,num2cell(pL.phaseMap(:)),'Uniformoutput',false);
    
        % maybe we have a perfect match
        phases = strcmpi(pL.mineralList(:),phName) | strcmpi(phaseNumbers,phName);

        % if no perfect match was found allow also for partial matches
        if ~any(phases)
          phases = strncmpi(pL.mineralList(:),phName,length(phName));
        end

        switch nnz(phases)
          case 0
            phId = 0;
          case 1
            phId = find(phases);
          otherwise
            mtexError(" Multiple phases matching your shortcut '" + phName + "'.\n" + ...
              " Please provide the full phase name.");
        end
        
      elseif isa(phName,'phaseItem')
        phId = find(pL.CSList == phName); % TODO!!
      else
        phId = find(phName == pL.phaseMap);
      end
      
    end

  end
end
