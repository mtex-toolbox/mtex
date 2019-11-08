function [poly,inclId] = calcPolygons(I_FG,F,V)
%
% Input:
%  I_FG - incidence matrix faces to grains
%  F    - list of faces
%  V    - list of vertices

inclId = zeros(size(I_FG,2),1);
poly = cell(size(I_FG,2),1);

% for all grains
for k=1:size(I_FG,2)
    
  % inner and outer boundaries are circles in the face graph
  EC = EulerCycles(F(I_FG(:,k)>0,:));
          
  % first cicle should be positive and all others negatively oriented
  for c = 1:numel(EC)
    if xor( c==1 , polySgnArea(V(EC{c},1),V(EC{c},2))>0 )
      EC{c} = fliplr(EC{c});
    end
  end
    
  % this is needed
  for c=2:numel(EC), EC{c} = [EC{c} EC{1}(1)]; end
  
  poly{k} = [EC{:}];
  inclId(k) = length(poly{k}) - length(EC{1});
  
end

end

function test

[x,y] = meshgrid(1:3);

cs = crystalSymmetry('1')

ori = orientation.byAxisAngle(xvector,[0,90*degree],cs);

ori_id = [ 0 1 1 ; ...
  1 0 1;...
  1 1 1];

ori = ori(ori_id + 1);

ebsd = EBSD(ori,ori_id,{cs},struct('x',x,'y',y))
  
end


%
%

