classdef grain3Boundary < phaseList & dynProp
%
% Variables of type grain3Boundary represent 2-dimensional faces of
% 3-dimensional grains. Those are typically
% generated during grain reconstruction and are accessible via
%
%   grains.boundary
%
% Each grain boundary face stores many properties: its position within
% the map, the ids of the adjacent grains, the ids of the adjacent EBSD
% measurements, the grain boundary misorientation, etc. These properties
% are explained in more detail in the section <Boundary3Properties.html
% boundary properties>.
%
% Class Properties
%  allV         - @vector3d list of all stored vertices 
%  scanUnit     - scanning unit (default - um)
%  tripleJunctions - @tripleJunctionList
%  F            - list of boundary faces as ids to allV
%  grainId      - id's of the neighboring grains to a boundary segment
%  ebsdId       - id's of the neighboring ebsd data to a boundary segment
%  misrotation  - misrotation between neighboring ebsd data to a boundary segment
%
% Dependent Class Properties
%  V              - @vector3d list of active/used vertices 
%  misorientation - disorientation between neighboring ebsd data to a boundary segment
%  N              - normal of the boundary face as @vector3d
%  centroid       - centroid of the boundary face as @vector3d
%  I_VF           - incidence matrix vertices - edges
%  I_FG           - incidence matrix edges - grains
%  A_F            - adjacency matrix edges - edges
%  A_V            - adjacency matrix vertices - vertices
%

  properties  % with as many rows as data
    id = []
    F                     % cell array or n x 3 array with all faces
    grainId = zeros(0,2)  % id's of the neighboring grains to a face
                          % (faceNormals direction from grain#1 to grain#2)
    ebsdId = zeros(0,2)   % id's of the neighboring ebsd data to a face
    misrotation = rotation % misrotations
  end
  
  properties
    allV     % vertices, @vector3d
  end

  properties (Dependent)
    idV      % ids of the used vertices
    V        % used vertices, @vector3d
    N        % face normal
    misorientation
  end

  methods

    function gB = grain3Boundary(V, F, ebsdInd, grainId, phaseId, mori, CSList, phaseMap, ebsdId, varargin)
      %
      % Input
      %  V       - @vector3d list of vertices
      %  F       - cell array of closed loops of indices to V describing the boundary faces
      %  F       - n x 3 array of indices to V describing the boundary faces
      %  ebsdInd - [Id1,Id2] list of adjacent EBSD index for each segment
      %  grainId - [Id1,Id2] list of adjacent grainIds for each segment
      %  phaseId - list of adjacent phaseIds for each segment     
      %  mori    - misorientation at each segment
      %  CSList  - list of phases
      %  phaseMap- reference to CSList
      
      % ensure V is vector3d
      V = reshape(vector3d(V),[],1);
      
      gB.allV = V;
      gB.F = F;
      gB.id = (1:length(F))';
      gB.grainId = grainId;
      gB.misrotation = mori;

      gB.ebsdId = ebsdInd;
      if nargin == 9 % store ebsd_id instead of index
        gB.ebsdId(ebsdInd>0) = ebsdId(ebsdInd(ebsdInd>0));
      end

      gB.phaseId = zeros(size(ebsdInd));
      gB.phaseId(ebsdInd>0) = phaseId(ebsdInd(ebsdInd>0));

      gB.CSList = CSList;
      gB.phaseMap = phaseMap;
      
    end

    function V = get.V(gB3)
      V = gB3.allV(gB3.idV);
    end

    function gB3 = set.V(gB3,V)
      gB3.allV(gB3.idV) = V;
    end

    function out = get.idV(gB3)
      if iscell(gB3.F)
      out = unique([gB3.F{:}]);
      else
      out = unique(gB3.F);
      end
    end

    function mori = get.misorientation(gB3)
            
      mori = orientation(gB3.misrotation,gB3.CS{:});
      mori.antipodal = equal(checkSinglePhase(gB3),2);
      
      % set not indexed orientations to nan
      if ~all(gB3.isIndexed), mori(~gB3.isIndexed) = NaN; end
      
    end

    function N = get.N(gB3)

      if isnumeric(gB3.F)
        
        VV = gB3.allV(gB3.F);        
        N = normalize(cross(VV(:,2)-VV(:,1),VV(:,3)-VV(:,1)));

      else
        % duplicate vertices according to their occurrence in the face
        Faces = gB3.F.';
        VV = gB3.allV([Faces{:}]);
        faceSize = cellfun(@numel,Faces).';
        faceEnds = cumsum(faceSize);
        faceId = repelem(1:length(gB3.F),faceSize).';
  
        % some reference point within the face
        c = accumarray(faceId,VV) ./ faceSize;

        % center around this estimate - this ensures (0,0,0) is in the plane
        VV = VV - c(faceId);

        % compute normal directions
        N = normalize(cross(VV(faceEnds-1),VV(faceEnds)));
      end

    end



    function out = hasPhaseId(gB,phaseId,phaseId2)
      if isempty(phaseId), out = false(size(gB)); return; end
      
      if nargin == 2
        out = any(gB.phaseId == phaseId,2);

        % not indexed phase should include outer border as well
        if phaseId > 0 && ischar(gB.CSList{phaseId}), out = out | ...
          any(gB.phaseId == 0,2); end
        
      elseif isempty(phaseId2)
        out = false(size(gB));
      elseif phaseId == phaseId2
        out = all(gB.phaseId == phaseId,2);
      else
        out = gB.hasPhaseId(phaseId) & gB.hasPhaseId(phaseId2);
      end 
    end

  end

end