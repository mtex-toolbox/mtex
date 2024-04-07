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
%  p2c       - refined parent to child orientation relationship
%  ebsdPrior   - EBSD prior to reconstruction
%  grainsPrior - grains prior to reconstruction
%  transformedGrains - prior child grains that has been reconstrcuted
%  grains    - grains at the current stage of reconstruction
%  parentGrains - parent grains at current stage of reconstruction
%  childGrains  - child grains at current stage of reconstruction
%  ebsd      - EBSD at the current stage of reconstruction
%  mergeId   - connection between prior and reconstructed grains
%  graph     - grain graph with edges representing probabilities of adjecent grains to form a parent grain
%  votes     - table of of votes with as many rows as job.grains
%  numChilds     - number of child grains for each parent grain
%  isTransformed - child grains that have been reverted from child to parent phase
%  isChild       - child grains that have been reverted from child to parent phase
%  isMerged      - child grains that have been merged into a parent grain    
%  variantId    - reconstructed variant ids
%  packetId     - reconstructed packet ids
%  bainId       - reconstructed bain ids % AAG ADDED
%
% References
%
% * <https://arxiv.org/abs/2201.02103 The variant graph approach to
% improved parent grain reconstruction>, arXiv, 2022,
% * <https://doi.org/10.1107/S1600576721011560 Parent grain reconstruction
% from partially or fully transformed microstructures in MTEX>, J. Appl.
% Cryst. 55, 2022.
% 
% See also
% MaParentGrainReconstruction TiBetaReconstruction
%

  properties

    p2c            % parent to child orientation relationship

    ebsdPrior      % EBSD prior to reconstruction
    grainsPrior    % grains prior to reconstruction

    grains         % grains at the current stage of reconstruction

    mergeId        % connects grainsPrior -> grains

    votes          % votes computed by calcGBVotes or calcTPVotes
    graph          % graph computed by calcGraph

    useBoundaryOrientations = false
    reportFit = true
    
  end
  
  properties (Dependent=true)
    csParent        % parent symmetry
    csChild         % child symmetry
    childPhaseId    % phase id of the child phase
    parentPhaseId   % phase id of the parent phase
    variantMap      % allows to reorder variants
    c2c             % all child to child ORs
  end
  
  properties (Dependent=true)
    ebsd            % EBSD at the current stage of reconstruction
    
    numChilds       % number of child grains for each parent grain
    isChild         % is a child grain
    isParent        % is a parent grain
    isTransformed   % a child grain that has been reconstructed into a parent grain
    isMerged        % child grains that have been merged into a parent grain    
    
    transformedGrains  % transformed measured grains 
    parentEBSD         % parent EBSD data at the current state of reconstruction
    parentGrains       % parent grains at the current state of reconstruction
    childGrains        % remaining child grains at the current state of reconstruction
    
    variantId       %
    packetId        %
    bainId          % 
    parentId        %
  end
  
  properties (Hidden=true, Dependent=true)
    hasVariantGraph
    hasGraph
  end

  methods

    function job = parentGrainReconstructor(ebsd,varargin)

      % set up ebsd and grains
      job.ebsdPrior = ebsd;
      job.grains = getClass(varargin,'grain2d');
      job.grainsPrior = job.grains;
      
      if isempty(job.grains)
        [job.grains, job.ebsdPrior.grainId] = ...
          calcGrains(ebsd('indexed'),'threshold',3*degree,varargin);
      end

      % project EBSD orientations close the grain mean orientations
      job.ebsdPrior = job.ebsdPrior.project2FundamentalRegion(job.grains);
      
      job.mergeId = (1:length(job.grains)).';
      
      % check for provided orientation relationship
      job.p2c = getClass(varargin,'orientation',orientation);
      
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
      end
      
    end
    
    function cs = get.csParent(job)
      cs = job.p2c.CS;
    end
    
    function set.csParent(job,cs)
      job.p2c.CS = cs;
    end
    
    function cs = get.csChild(job)
      cs = job.p2c.SS;
    end
    
    function set.csChild(job,cs)
      job.p2c.SS = cs;
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
      
      out = job.grainsPrior.phaseId == job.childPhaseId & ...
        job.grains.phaseId(job.mergeId) == job.parentPhaseId;
    end
    
    function out = get.isChild(job)
      out = job.grains.phaseId == job.childPhaseId;
    end
    
    function out = get.isParent(job)
      out = job.grains.phaseId == job.parentPhaseId;
    end
    
    function out = get.parentGrains(job)      
      out = job.grains( job.grains.phaseId == job.parentPhaseId );      
    end
    
    function out = get.childGrains(job)      
      out = job.grains( job.grains.phaseId == job.childPhaseId );      
    end
    
    function out = get.parentEBSD(job)      
      out = job.ebsd;
      out = out(job.csParent);
    end
    
    function out = get.transformedGrains(job)
      out = job.grainsPrior(job.isTransformed);
    end
    
    function set.transformedGrains(job,grains)
      job.grainsPrior(job.isTransformed) = grains;
    end
    
    function out = get.packetId(job)
      
      if isfield(job.grainsPrior.prop,'packetId')
        out = job.grainsPrior.prop.packetId;
      else
        out = NaN(size(job.grainsPrior));
      end
    end
    
    %% AAG ADDED
    function out = get.bainId(job)   
      
      if isfield(job.grainsPrior.prop,'bainId')
        out = job.grainsPrior.prop.bainId;
      else
        out = NaN(size(job.grainsPrior));
      end
    end
    %% AAG ADDED

    function out = get.parentId(job)
      out = nan(size(job.grainsPrior));
      ind = job.isTransformed;
      
      cOri = job.grainsPrior(ind).meanOrientation;
      pOri = job.grains(ind).meanOrientation;

      [~,out(ind)] = min(angle_outer(inv(cOri) .* pOri, ...
        variants(job.p2c, 'parent'),'noSym2'),[],2);
    end
    
    function set.packetId(job,id)
      job.grainsPrior.prop.packetId = id;
    end

    %% AAG ADDED
    function set.bainId(job,id)
      job.grainsPrior.prop.bainId = id;
    end
    %% AAG ADDED
    
    function out = get.variantId(job)
      
      if isfield(job.grainsPrior.prop,'variantId')
        out = job.grainsPrior.prop.variantId;
      else
        out = NaN(size(job.grainsPrior));
      end
    end
    
    function set.variantId(job,id)
      job.grainsPrior.prop.variantId = id;
    end
     
    function set.variantMap(job,vMap)
      job.p2c.opt.variantMap = vMap;
    end
    
    function vMap = get.variantMap(job) 
      if ~isfield(job.p2c.opt,'variantMap') || isempty(job.p2c.opt.variantMap)
        vMap = 1:length(job.p2c.variants); 
      else
        vMap = job.p2c.opt.variantMap;
      end      
    end
    
    function ebsd = get.ebsd(job)
      ebsd = calcParentEBSD(job);
    end
    
    function c2c = get.c2c(job)
      % child to child misorientation variants
      p2cV = job.p2c.variants; 
      c2c = job.p2c .* inv(p2cV(:));
    end
    
    function out = get.hasVariantGraph(job)
      out = ~isempty(job.graph) && length(job.graph)>1.5*length(job.grains);
    end

    function out = get.hasGraph(job)
      out = ~isempty(job.graph) && length(job.graph)<1.5*length(job.grains);
    end

  end

end
