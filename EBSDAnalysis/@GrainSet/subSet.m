function grains = subSet(grains,ind)
% 
%
% Input
%  grains - @grainSet
%  ind    - 
%
% Ouput
%  grains - @grainSet
%
% TODO this is not completely correct
% since

% fields to be updated
% V  = zeros(0,3)              % vertices - (x,y,(z)) coordinate
% F  = zeros(0,3)              % edges(faces) - vertices ids (v1,v2,(v3))
% I_FDint = sparse(0,0)        % cells - interior faces
% I_FDext = sparse(0,0)        % cells - exterior faces
% I_DG = sparse(0,0)           % grains - cells
% A_Db  = sparse(0,0)          % cells with grain boundary
% A_Do  = sparse(0,0)          % cells within one grain
%        
% meanRotation = rotation      % mean rotation of the grain        
% ebsd                         % the ebsd data

ng = size(grains.I_DG,2);

% ignore empty grains
mapping = find(any(grains.I_DG,1));
mapping = mapping(ind);
  
D = sparse(mapping,mapping,1,ng,ng);
old_D = any(grains.I_DG,2);
  
grains.I_DG = grains.I_DG*D;
%   grains.A_G  = grains.A_G*D;
grains.meanRotation = grains.meanRotation(ind);
%   grains.gphase = grains.gphase(s);

% remove lines that correspond not cell not required
D = double(diag(any(grains.I_DG,2)));
  
grains.A_Db = grains.A_Db*D;
grains.A_Do = grains.A_Do*D;
grains.I_FDext = grains.I_FDext*D;
grains.I_FDint = grains.I_FDint*D;

ebsd_subs = nonzeros(cumsum(old_D) .* any(grains.I_DG,2));
grains.ebsd = subSet(grains.ebsd,ebsd_subs);
  
% remove grains
D = any(grains.I_FDext | grains.I_FDint,2);
grains.F(~D,:) = 0;
  
% remove vertices
[~,~,v] = find(double(grains.F));
D = sparse(v,1,1,size(grains.V,1),1)>0;
grains.V(~D,:) = 0;

% remove edges
grains = cleanupFaces(grains);

end
