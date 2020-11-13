classdef parentGrainReconstructor < handle
  
  properties
    
    csParent  % parent symmetry
    csChild   % child symmetry
    p2c       % parent to childe orientation relationship
    
    ebsd      % reconstructed parent EBSD data
    grains    % reconstructed parent grains

    mergeId 
    
    fit    
    graph
    
  end
  
  properties (Dependent=true, Hidden = true)
    childPhaseId    % phase id of the child phase
    parentPhaseId   % phase id of the parent phase
  end
  
  
  methods
    
    
    function job = parentGrainReconstructor(ebsd,varargin)

      % set up ebsd and grains
      job.ebsd = ebsd;
      job.grains = getClass(varargin,'grain2d');
      
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
    
    function disp(job)
      
      gs = job.grains.grainSize;
      p = 100*sum(gs(job.grains.phaseId == job.parentPhaseId)) / sum(gs);
      matrix(1,:) = {'parent', job.csParent.mineral, char(job.csParent), ...
        length(job.grains(job.csParent)),[xnum2str(p) '%']};
      
      p = 100*sum(gs(job.grains.phaseId == job.childPhaseId)) / sum(gs);
      if ~isempty(job.csChild)
        matrix(2,:) = {'child', job.csChild.mineral, char(job.csChild), ...
          length(job.grains(job.csChild)),[xnum2str(p) '%']};
      end
      
      cprintf(matrix,'-L',' ','-Lc',...
        {'phase' 'mineral' 'symmetry' 'grains' 'ebsd'},...
        '-d','  ','-ic',true);

      disp(' ');
      
      if ~isempty(job.p2c)
        disp(['  parent to child OR: ' round2Miller(job.p2c)])
        disp(' ');
      end
      
      if ~isempty(job.graph) && size(job.graph,2) == length(job.grains)
        
        [~,mId] = merge(job.grains, job.graph,'testRun');
        numComp = accumarray(mId,1);
        untouched = nnz(numComp==1);
        numComp = numComp(numComp>1);
        
        disp(['  mergable grains: ' int2str(sum(numComp)) ...
          ' -> ' int2str(length(numComp)) ' keep ' int2str(untouched)]);
        disp(' ');
      end
      
      recAreaGrains = sum(job.grains(job.csParent).area)/sum(job.grains.area)*100;
      recAreaEBSD = length(job.ebsd(job.csParent))/length(job.ebsd)*100;
      fprintf('  grains reconstructed: %.0f%%\n', recAreaGrains);
      fprintf('  ebsd reconstructed: %.0f%%\n', recAreaEBSD);
      
    end
    
    function job = calcParent2Child(job, varargin)
      
      % get neighbouring grain pairs
      grainPairs = job.grains(job.csChild).neighbors;

      p2c0 = orientation.KurdjumovSachs(job.csParent,job.csChild);
      if ~isempty(job.p2c), p2c0 = job.p2c; end       
      p2c0 = getClass(varargin,'orientation',p2c0);
      
      % compute an optimal parent to child orientation relationship
      [job.p2c, job.fit] = calcParent2Child(job.grains(grainPairs).meanOrientation,p2c0);
      
    end
    
    function job = buildGraph(job, varargin)
    
      threshold = get_option(varargin,'threshold',2*degree);
      tol = get_option(varargin,'tolerance',1.5*degree);
      
      % child to child misorientations
      pairs = neighbors(job.grains(job.csChild),job.grains(job.csChild));

      p2p = inv(job.grains(pairs(:,2)).meanOrientation) .* ...
        job.grains(pairs(:,1)).meanOrientation;

      p2pFit = min(angle_outer(p2p,job.p2c * inv(variants(job.p2c))),[],2); %#ok<MINV>

      prob = 1 - 0.5 * (1 + erf(2*(p2pFit - threshold)./tol));

      % child 2 child neighbours
      grainPairs = job.grains(job.csChild).neighbors;
      
      % the corresponding similarity matrix
      job.graph = sparse(grainPairs(:,1),grainPairs(:,2),prob,...
        length(job.grains),length(job.grains));
      
      % parent to child neighbours
      grainPairs = neighbors(job.grains(job.csParent),job.grains(job.csChild));
      
      childOri = job.grains(job.grains.id2ind(grainPairs(:,2))).meanOrientation;
      parentOri = job.grains(job.grains.id2ind(grainPairs(:,1))).meanOrientation;
      
      p2cFit = angle(job.p2c, inv(childOri).*parentOri);
            
      prob = 1 - 0.5 * (1 + erf(2*(p2cFit - threshold)./tol));
      
      job.graph = job.graph + sparse(grainPairs(:,1),grainPairs(:,2),prob,...
        length(job.grains),length(job.grains));
            
    end

    function job = clusterGraph(job, varargin)

      p = get_option(varargin,'inflationPower', 1.6);
      
      job.graph = mclComponents(job.graph,p);
      
    end
    
    
    function job = mergeSimilar(job, varargin)
      
      [job.grains, mergeId] = merge(job.grains, varargin{:});
      job.mergeId = mergeId(job.mergeId); %#ok<*PROPLC>
      job.ebsd('indexed').grainId = mergeId(job.ebsd('indexed').grainId);
            
    end

    
    
  end
  
end