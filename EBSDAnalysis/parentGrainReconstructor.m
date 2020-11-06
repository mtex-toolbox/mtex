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
      recAreaGrains = sum(job.grains(job.csParent).area)/sum(job.grains.area)*100;
      recAreaEBSD = length(job.ebsd(job.csParent))/length(job.ebsd)*100;
      fprintf('  grains reconstructed: %.0f%%\n', recAreaGrains);
      fprintf('  ebsd reconstructed: %.0f%%\n', recAreaEBSD);
      
    end
    
    function calcParent2Child(job, varargin)
      
      % get neighbouring grain pairs
      grainPairs = job.grains(job.csChild).neighbors;

      p2c0 = orientation.KurdjumovSachs(job.csParent,job.csChild);
      if ~isempty(job.p2c), p2c0 = job.p2c; end       
      p2c0 = getClass(varargin,'orientation',p2c0);
      
      % compute an optimal parent to child orientation relationship
      [job.p2c, job.fit] = calcParent2Child(job.grains(grainPairs).meanOrientation,p2c0);
      
    end
    
    function buildGraph(job, varargin)
    
      threshold = get_option(varargin,'threshold',2*degree);
      tol = get_option(varargin,'tolerance',1.5*degree);
      
      prob = 1 - 0.5 * (1 + erf(2*(job.fit - threshold)./tol));

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

    function clusterGraph(job, varargin)

      p = get_option(varargin,'inflation power', 1.6);
      
      job.graph = mclComponents(job.graph,p);
      
    end
    
    function mergeByGraph(job,varargin)
%       % merge grains according to the adjecency matrix A
%       
%       % merge grains according to the adjacency matrix A
%       [recParentGrains, recParentId] = merge(job.grains,job.graph);
%       grains.prop.parentGrainId = recParentId;
%       % ensure grainId in parentEBSD is set up correctly with parentGrains
%       recEBSD = ebsd;
%       %recEBSD('indexed').grainId = recParentId(ebsd('indexed').grainId);
%       recEBSD.grainId = recParentId(ebsd.grainId);
%       %% Initialize the parent orientation we are going to reconstruct
%       recParentOri = orientation.nan(max(recParentId),1,parent.CS);
%       fit = inf(size(recParentOri));
%       weights = grains.grainSize;
%     
%       
%       
      
      
      % the remember child orientations
      wasChildGrain = job.grains.phaseId == job.childPhaseId;
      
      childOri = orientation.nan(length(job.grains),1,job.csChild);
      childOri(wasChildGrain) = job.grains.meanRotation(wasChildGrain);
      
      % weights are previous grainSize
      weights = job.grains.grainSize;
      
      % perform the grain merge
      grains = job.grains;
      [job.grains, mergeId] = merge(job.grains,job.graph);
      job.mergeId = mergeId(job.mergeId);
            
      % ensure grainId in parentEBSD is set up correctly with parentGrains
      job.ebsd('indexed').grainId = mergeId(job.ebsd('indexed').grainId);

      % the parent orientation we are going to compute
      parentOri = orientation.nan(max(mergeId),1,job.csParent);
      job.fit = inf(size(parentOri));
      
      % obtain phase info
      pId = unique(grains(job.csParent).phase);
      cId = unique(grains(job.csChild).phase);
      phaseList = grains.phase;
      
      % compute parent grain orientation by looping through all merged grains
      for k = 1:max(mergeId)
          
          %Check if empty
          if ~any(mergeId==k), continue; end

          %Parent orientation(s)
          if all(phaseList(mergeId==k) == pId)
              parentOri(k) = mean(grains(mergeId==k).meanOrientation);
              job.fit(k) = 0;
          %Child orientations(s)
          elseif all(phaseList(mergeId==k) == cId)
                if nnz(mergeId==k) > 1
                    [parentOri(k),job.fit(k)] = calcParent(grains(mergeId == k).meanOrientation,...
                                               job.p2c, 'weights', weights(mergeId == k));
                end
          %Parent and child orientations
          elseif all(ismember(phaseList(mergeId==k),[cId,pId]))
                [ori,fit] = calcParent(grains(mergeId==k, grains.phase==cId).meanOrientation,...
                                      mean(grains(mergeId==k, grains.phase==pId).meanOrientation, 'robust'),...
                                      job.p2c,'weights', weights(mergeId == k));
                parentOri(k) = mean(ori, 'robust');
                job.fit(k) = mean(fit);
          end  
                 
%         if nnz(mergeId == k) > 1
%           % compute the parent orientation from the child orientations
%           [parentOri(k),job.fit(k)] = calcParent(childOri(mergeId==k),...
%             job.p2c, 'weights', weights(mergeId==k));
%         end
        progress(k,max(mergeId),'computing parent grain orientations: ');
      end
      
      % update mean orientation of the parent grains
      job.grains(job.fit < 5*degree).meanOrientation = ...
        parentOri(job.fit < 5*degree);
      job.grains = job.grains.update;
      
    end
    
    function mergeSimilar(job, varargin)
      
      [job.grains, mergeId] = merge(job.grains, varargin{:});
      job.mergeId = mergeId(job.mergeId);
      job.ebsd('indexed').grainId = mergeId(job.ebsd('indexed').grainId);
            
    end

    function ebsd = calcParentEBSD(job)
      % update EBSD
           
      % consider only child pixels that have been reconstructed to parent
      % grains
      isNowParent = job.ebsd.phaseId == job.childPhaseId &...
        job.grains.phaseId(max(1,job.ebsd.grainId)) == job.parentPhaseId;

      % compute parent orientation
      [ori,fit] = calcParent(job.ebsd(isNowParent).orientations,...
        job.grains(job.ebsd.grainId(isNowParent)).meanOrientation,job.p2c);
      
      % setup parent ebsd
      ebsd = job.ebsd;
      ebsd.prop.fit = nan(size(ebsd));
      ebsd(isNowParent).orientations = ori;
      ebsd.prop.fit(isNowParent) = fit;
      
    end
    
  end
  
end