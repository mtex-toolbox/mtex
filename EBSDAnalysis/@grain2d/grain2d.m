classdef grain2d < phaseList & dynProp
  % two dimensional grains

  % properties with as many rows as data
  properties
    poly={}    % cell list of polygons forming the grains
    id=[]      % id of each grain    
    grainSize = [] % number of measurements per grain
  end
  
  properties (Hidden = true)
    inclusionId = [];
  end
  
  % general properties
  properties    
    boundary = grainBoundary % boundary of the grains
    innerBoundary = grainBoundary % inner grain boundary
  end
    
  properties (Dependent = true)
    meanOrientation  % mean orientation
    V                % vertices with x,y coordinates
    scanUnit         % unit of the vertice coordinates
    id2ind           % 
    GOS              % intragranular average misorientation angle    
    x                % x coordinates of the vertices of the grains
    y                % y coordinates of the vertices of the grains
    triplePoints     % triple points
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
                        
      grains.boundary = grainBoundary(V,F,I_FDext,ebsd,grains.phaseId);
      grains.boundary.scanUnit = ebsd.scanUnit;
      grains.innerBoundary = grainBoundary(V,F,I_FDint,ebsd,grains.phaseId);
      
      [grains.poly, grains.inclusionId]  = calcPolygons(I_FDext * I_DG,F,V);

      
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
    end
    
    function V = get.V(grains)
      V = grains.boundary.V;
    end
    
    function x = get.x(grains)
      x = grains.boundary.x;
    end
    
    function y = get.y(grains)
      y = grains.boundary.y;
    end
    
    function grains = set.V(grains,V)
      grains.boundary.V = V;
      grains.innerBoundary.V = V;
      
      % update V in triple points
      tP = grains.triplePoints;
      grains.triplePoints.V = V(tP.id,:);
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
    
    function varargout = size(grains,varargin)
      [varargout{1:nargout}] = size(grains.id,varargin{:});
    end
    
    function ori = get.meanOrientation(grains)
      ori = orientation(grains.prop.meanRotation,grains.CS);
    end
    
    function grains = set.meanOrientation(grains,ori)
      grains.prop.meanRotation = rotation(ori);
    end

    function gos = get.GOS(grains)
      gos = grains.prop.GOS;
    end
    
    function unit = get.scanUnit(grains)
      unit = grains.boundary.scanUnit;
    end
    
    function tP = get.triplePoints(grains)
      tP = grains.boundary.triplePoints;
    end
    
    function grains = set.triplePoints(grains,tP)
      grains.boundary.triplePoints = tP;
    end
    
  end
  
end

