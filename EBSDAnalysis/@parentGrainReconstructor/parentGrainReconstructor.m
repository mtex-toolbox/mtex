classdef parentGrainReconstructor < handle
  
  properties
    
    csParent  % parent symmetry
    csChild   % child symmetry
    p2c       % parent to childe orientation relationship
    
    ebsd      % initial / measured EBSD
    grainsI   % initial / measured grains 
    grains    % reconstructed grains

    mergeId   % a list of ids to the merged grains
    
    fit    
    graph
    
  end
  
  properties (Dependent=true, Hidden = true)
    childPhaseId    % phase id of the child phase
    parentPhaseId   % phase id of the parent phase
  end
  
  properties (Dependent=true)
    numParents      % number of child grains for each parent grain
    isTransformed   % child grains that have been reverted from child to parent phase
    isMerged        % child grains that have been merged into a parent grain    
    
    variantId       %
    packetId        %
  end
  
  
  methods
    
    
    function job = parentGrainReconstructor(ebsd,varargin)

      % set up ebsd and grains
      job.ebsd = ebsd;
      job.grains = getClass(varargin,'grain2d');
      job.grainsI = job.grains;
      
      if isempty(job.grains)
        [job.grains, job.ebsd.grainId] = calcGrains(ebsd('indexed'),'threshold',3*degree,varargin);
      end
      
      job.mergeId = 1:length(job.grains);
      
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
      end            
    end
    
    
    function id = get.parentPhaseId(job)
      id = job.ebsd.cs2phaseId(job.csParent);
    end
    
    function id = get.childPhaseId(job)
      id = job.ebsd.cs2phaseId(job.csChild);
    end
    
    function out = get.numParents(job)
      out = accumarray(job.mergeId,1);
    end
    
    function out = get.isMerged(job)
      % the merged ones are those 
      out = job.numParents(job.mergeId)>1;
    end
    
    function out = get.isTransformed(job)
      % which initial grains have been already reconstructed
      
      %Should this not be "which grains have been succesfully
      %reconstructed?
      %Then we could use this to return the area fraction of reconstructed
      %phase
      out = job.grainsI.phaseId == job.childPhaseId & ...
        job.grains.phaseId(job.mergeId) == job.parentPhaseId;
    end
    
    function out = get.packetId(job)
      
      if isfield(job.grainsI.prop,'packetId')
        out = job.grainsI.prop.packetId;
      else
        out = NaN(size(job.grainsI));
      end
    end
    
    function set.packetId(job,id)
      job.grainsI.prop.packetId = id;
    end
    
    function out = get.variantId(job)
      
      if isfield(job.grainsI.prop,'variantId')
        out = job.grainsI.prop.variantId;
      else
        out = NaN(size(job.grainsI));
      end
    end
    
    function set.variantId(job,id)
      job.grainsI.prop.variantId = id;
    end
    
  end

end