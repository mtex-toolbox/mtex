classdef grain2d < phaseList & dynProp
  % two dimensional grains

  % properties with as many rows as data
  properties
    poly={}    % cell list of polygons forming the grains
    id=[]      % id of each grain
    meanRotation = rotation % mean rotation of the grains
    grainSize = [] % number of measurements per grain
  end
    
  % general properties
  properties    
    boundary = grainBoundary % boundary of the grains
    innerBoundary = grainBoundary % inner grain boundary
  end
    
  properties (Dependent = true)
    meanOrientation  % mean orientation
    V                % vertices with x,y coordinates
    id2ind           % 
  end
  
  properties (Dependent = true, Access = protected)
    idV % active vertices    
  end
  
  methods
    function grains = grain2d(ebsd,V,F,I_DG,I_FD,A_Db)
      %
      % Input:
      %   ebsd - EBSD data set
      %   V    - list of vertices
      %   F    - list of edges
      %   I_DG - incidence matrix - ebsd cells x grains
      %   I_FD - incidence matrix - edges x ebsd cells
      %   A_Db - adjacense matrix of cells
      
      if nargin == 0, return;end
      
      % compute phaseId's     
      grains.phaseId = max(I_DG' * ...
        spdiags(ebsd.phaseId,0,numel(ebsd.phaseId),numel(ebsd.phaseId)),[],2);
      grains.CSList = ebsd.CSList;
      grains.phaseMap = ebsd.phaseMap;
           
      % split face x cell incidence matrix into
      % I_FDext - faces x cells external grain boundaries
      % I_FDint - faces x cells internal grain boundaries
      [I_FDext,I_FDint] = calcBoundary;

      % remove empty lines from I_FD, F, and V
      isBoundary = full(any(I_FDext,2) | any(I_FDint,2));
      F = F(isBoundary,:);
      I_FDext = I_FDext.'; I_FDext = I_FDext(:,isBoundary).';
      I_FDint = I_FDint.'; I_FDint = I_FDint(:,isBoundary).';
            
      % remove vertices that are not needed anymore
      [inUse,~,F] = unique(F);
      V = V(inUse,:);
      F = reshape(F,[],2);

      grains.id = (1:numel(grains.phaseId)).';
      grains.grainSize = full(sum(I_DG,1)).';
                        
      grains.boundary = grainBoundary(V,F,I_FDext,ebsd);
      grains.innerBoundary = grainBoundary(V,F,I_FDint,ebsd);
      
      %grains.poly = BoundaryFaceOrder(I_FDext);
      grains.poly = calcPolygons(I_FDext * I_DG,F,V);
      
      grains.meanRotation = calcMeanRotation;
      
      
      function [I_FDext,I_FDint] = calcBoundary
        % distinguish between interior and exterior grain boundaries      
        
        % cells that have a subgrain boundary, i.e. a boundary with a cell
        % belonging to the same grain
        sub = ((A_Db * I_DG) & I_DG)';                 % grains x cell
        [i,j] = find( diag(any(sub,1))*double(A_Db) ); % all adjacence to those
        sub = any(sub(:,i) & sub(:,j),1);              % pairs in a grain

        % split grain boundaries A_Db into interior and exterior
        A_Db_int = sparse(i(sub),j(sub),1,size(I_DG,1),size(I_DG,1));
        A_Db_ext = A_Db - A_Db_int;                    % adjacent over grain boundray
            
        % create incidence graphs
        I_FDbg = diag( sum(I_FD,2)==1 ) * I_FD;
        D_Fbg  = diag(any(I_FDbg,2));
                
        [ix,iy] = find(A_Db_ext);
        D_Fext  = diag(sum(abs(I_FD(:,ix)) & abs(I_FD(:,iy)),2)>0);
        
        I_FDext = (D_Fext| D_Fbg)*I_FD;
        
        [ix,iy] = find(A_Db_int);
        D_Fsub  = diag(sum(abs(I_FD(:,ix)) & abs(I_FD(:,iy)),2)>0);
        I_FDint = D_Fsub*I_FD;
        
      end
      
      function poly = BoundaryFaceOrder(I_FD)
        % TODO: this needs to become a private function
        % Input:
        %  I_FG - incidence matrix faces to grains
        
        % step 1: compute edge orientation of faces
   
        I_FG = I_FD * I_DG;
        [iF,iG] = find(I_FG);
        % compute ori here!
        %
        % iF - faceId
        % iG - grainId
        % ori - edgeOrientation +-1
        
        poly = cell(max(iG),1);

        % go through iF and iG grainwise
        cs = [0 cumsum(full(sum(I_FG~=0,1)))];
        for k=1:size(I_DG,2)
          ndx = cs(k)+1:cs(k+1);
  
          E1 = F(iF(ndx),:);
            
          EC = EulerCycles2(E1);
          
          % first cicle should positive and all others negatively oriented
          for c = 1:numel(EC)
            if xor( c==1 , polySgnArea(V(EC{c},1),V(EC{c},2))>0 )
              EC{c} = fliplr(EC{c});
            end
          end

          % this is needed
          for c=3:numel(EC), EC{c} = [EC{1}(1) EC{c}]; end

          poly{k} = [EC{:}];
          
        end

      end
    
      function meanRotation = calcMeanRotation

        [d,g] = find(I_DG);

        grainRange    = [0;cumsum(grains.grainSize)];        %
        firstD        = d(grainRange(2:end));
        phaseId       = ebsd.phaseId(firstD);
        q             = quaternion(ebsd.rotations);
        meanRotation  = q(firstD);

        indexedPhases = ~cellfun('isclass',grains.CSList(:),'char');

        for p = grains.indexedPhasesId
          ndx = ebsd.phaseId(d) == p;
          if any(ndx)
            q(d(ndx)) = project2FundamentalRegion(...
              q(d(ndx)),grains.CSList{p},meanRotation(g(ndx)));
          end
  
          % mean may be inaccurate for some grains and should be projected again
          % any(sparse(d(ndx),g(ndx),angle(q(d(ndx)),meanRotation(g(ndx))) > getMaxAngle(ebsd.CS{p})/2))
        end

        doMeanCalc    = find(grains.grainSize>1 & indexedPhases(phaseId));
        cellMean      = cell(size(doMeanCalc));
        for k = 1:numel(doMeanCalc)
          cellMean{k} = d(grainRange(doMeanCalc(k))+1:grainRange(doMeanCalc(k)+1));
        end
        cellMean = cellfun(@mean,partition(q,cellMean),'uniformoutput',false);

        meanRotation(doMeanCalc) = [cellMean{:}];

      end      
    end
    
    function V = get.V(grains)
      V = grains.boundary.V;
    end
    
    function grains = set.V(grains,V)
      grains.boundary.V = V;
    end
    
    function idV = get.idV(grains)
      
      isCell = cellfun('isclass',grains.poly,'cell');
      polygons = grains.poly;
      polygons(isCell) = cellfun(@(x) [x{:}] ,grains.poly(isCell),'UniformOutput',false);
      idV = unique([polygons{:}]);
      
    end
    
    function id2ind = get.id2ind(grains)
      id2ind = zeros(max(grains.id),1);
      id2ind(grains.id) = 1:length(grains);
    end
    
    function ori = get.meanOrientation(grains)
      ori = orientation(grains.meanRotation,grains.CS);
    end
    
  end
  
end

