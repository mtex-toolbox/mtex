classdef parentGrainReconstructor < handle
% class guiding through the parent grain reconstruction process 
%
% Syntax
%   job = parentGrainReconstructor(ebsd, grains)
%
%   job = parentGrainReconstructor(ebsd, grains, p2c0)
%
% Input
%  ebsd - @EBSD
%  grains - @grain2d
%  p2c0 - initial guess for the parent to child orientation relationship
%
% Class Properties
%  csParent  - @crystalSymmetry of the parent phase
%  csChild   - @crystalSymmetry of the child phase
%  p2c       - parent to child orientation relationship
%  ebsd      - measured @EBSD
%  grainsMeasured - measured @grain2d
%  grains    - reconstructed grains
%  mergeId   - list of ids to the merged grains
%  fit       - 
%  graph     -
%  votes     -
%  numChilds         - number of child grains for each parent grain
%  isTransformed     - child grains that have been reverted from child to parent phase
%  isMerged          - child grains that have been merged into a parent grain    
%  transformedGrains - transformed measured grains 
%  parentGrains - measured and reconstructed parent grains
%  childGrains  - not yet reconstructed child grains
%  variantId    - reconstructed variant ids
%  packetId     - reconstructed packet ids
%
% See also
% MaParentGrainReconstruction TiBetaReconstruction
%

  properties
    
    csParent  % parent symmetry
    csChild   % child symmetry

    
    ebsd      % initial / measured EBSD
    grainsMeasured % initialy measured grains 
    grains    % reconstructed grains

    mergeId   % a list of ids to the merged grains
    
    fit    
    graph
    votes
    variantMap      
    
  end
  
  properties (Dependent=true)
    childPhaseId    % phase id of the child phase
    parentPhaseId   % phase id of the parent phase
  end
  
  properties (Dependent=true)
    numChilds       % number of child grains for each parent grain
    isTransformed   % child grains that have been reverted from child to parent phase
    isMerged        % child grains that have been merged into a parent grain    
    
    transformedGrains  % transformed measured grains 
    parentGrains       % 
    childGrains        %
    
    variantId       %
    packetId        %
  end
  
  properties (SetObservable) 
    p2c       % parent to child orientation relationship
  end
  
  
  methods
    
    
    function job = parentGrainReconstructor(ebsd,varargin)

      % set up ebsd and grains
      job.ebsd = ebsd;
      job.grains = getClass(varargin,'grain2d');
      job.grainsMeasured = job.grains;
      
      if isempty(job.grains)
        [job.grains, job.ebsd.grainId] = calcGrains(ebsd('indexed'),'threshold',3*degree,varargin);
      end
      
      job.mergeId = (1:length(job.grains)).';
      
      % check for provided orientation relationship
      job.p2c = getClass(varargin,'orientation');
      
      % determine parent and child phase
      if isempty(job.p2c)
        % try to guess parent and child phase
        numPhase = accumarray(ebsd.phaseId,1,[length(ebsd.CSList),1]);
        indexedPhasesId = find(~cellfun(@ischar,ebsd.CSList));
        numPhase = numPhase(indexedPhasesId );
        
        [~,maxPhase] = max(numPhase);
        job.csChild = ebsd.CSList{indexedPhasesId(maxPhase)};
        
        [~,minPhase] = min(numPhase);
        if minPhase ~= maxPhase
          job.csParent = ebsd.CSList{indexedPhasesId(minPhase)};
        end
      else
        % extract from existing orientation relationship
        assert(~(job.p2c.CS == job.p2c.SS),'p2c should be a misorientation')
        job.csParent = job.p2c.CS;
        job.csChild = job.p2c.SS;
        %job.variantMap = 1:length(job.p2c.variants);
      end   
      
      % add listener to p2c
      addlistener(job,'p2c','PostSet',@job.handlePropEvents);
    end
       
    function handlePropEvents(job,metaProp,eventData)
      switch metaProp.Name 
        case 'p2c'
          
          numVariants = length(job.p2c.variants);
          
          %Initialisation
          if length(job.variantMap) ~= numVariants
            
            % default to Morito convention for cubic to cubic misorientation
            if job.p2c.CS.lattice == latticeType.cubic && ...
                job.p2c.SS.lattice == latticeType.cubic && ...
                numVariants == 24
            
              job.variantMap = 'morito';
              
            else % otherwise the default is 1,2,3,4,...,numVariants
              job.variantMap = 1:numVariants;
            end
          end          
      end
    end
	
    function id = get.parentPhaseId(job)
      id = job.grains.cs2phaseId(job.csParent);
    end
    
    function id = get.childPhaseId(job)
      id = job.grains.cs2phaseId(job.csChild);
    end
    
    function out = get.numChilds(job)
      out = accumarray(job.mergeId,1);
    end
    
    function out = get.isMerged(job)
      % the merged ones are those 
      out = job.numChilds(job.mergeId)>1;
    end
    
    function out = get.isTransformed(job)
      % which initial grains have been already reconstructed
      
      %Should this not be "which grains have been succesfully
      %reconstructed?
      %Then we could use this to return the area fraction of reconstructed
      %phase
      out = job.grainsMeasured.phaseId == job.childPhaseId & ...
        job.grains.phaseId(job.mergeId) == job.parentPhaseId;
    end
    
    function out = get.parentGrains(job)
      
      out = job.grains( job.grains.phaseId == job.parentPhaseId );
      
    end
    
    function out = get.childGrains(job)
      
      out = job.grains( job.grains.phaseId == job.childPhaseId );
      
    end
    
    function out = get.transformedGrains(job)
      out = job.grainsMeasured(job.isTransformed);
    end
    
    function set.transformedGrains(job,grains)
      job.grainsMeasured(job.isTransformed) = grains;
    end
    
    function out = get.packetId(job)
      
      if isfield(job.grainsMeasured.prop,'packetId')
        out = job.grainsMeasured.prop.packetId;
      else
        out = NaN(size(job.grainsMeasured));
      end
    end
    
    function set.packetId(job,id)
      job.grainsMeasured.prop.packetId = id;
    end
    
    function out = get.variantId(job)
      
      if isfield(job.grainsMeasured.prop,'variantId')
        out = job.grainsMeasured.prop.variantId;
      else
        out = NaN(size(job.grainsMeasured));
      end
    end
    
    function set.variantId(job,id)
      job.grainsMeasured.prop.variantId = id;
    end
        
    function set.variantMap(job,id) 
      assert(~isempty(job.p2c),'Define p2c before mapping variant Ids');
      numVariants = length(job.p2c.variants);
        
      if strcmpi(id,'morito') && numVariants == 24
        job.variantMap = [1 3 5 21 23 19 11 7 9 16 14 18 ...
          24 22 20 4 2 6 13 15 17 8 12 10];
        
        % TODO: maybe we can find a more robust implementation of the
        % morito order, i.e., one that does not depend 
        
      else
        assert(length(id) == numVariants,'Supply %d natural numbers as Ids',numVariants);
        job.variantMap = id;
      end
    end
    
  end

end