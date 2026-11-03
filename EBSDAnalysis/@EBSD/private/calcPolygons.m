function [poly,inclusionId] = calcPolygons(I_FG,F,V)
%
% Input
%  I_FG - incidence matrix faces to grains
%  F    - list of faces
%  V    - list of vertices
%
% Output
%  poly        - cell list of indices to V
%  inclusionId - number of trailing vertices in poly{k} belonging to
%                inclusion (hole) loops EC{2:end}, i.e. numel(poly{k})
%                minus the length of the main loop EC{1}. Known for free
%                here since every grain's cycles are traced individually
%                below; see EBSDAnalysis/@grain2d/grain2d.m.

poly = cell(size(I_FG,2),1);
inclusionId = zeros(size(I_FG,2),1);

if isempty(I_FG), return; end

% for all grains
for k=1:size(I_FG,2)

  % inner and outer boundaries are circles in the face graph
  EC = EulerCycles(F(I_FG(:,k)>0,:));

  % the loop of largest area is the outer one, positive, all others negative
  a = cellfun(@(ec) polySgnArea(V(ec,1),V(ec,2)), EC);
  [~,o] = sort(-abs(a)); EC = EC(o);
  for c = 1:numel(EC)
    if xor(c==1, a(o(c))>0), EC{c} = fliplr(EC{c}); end
  end

  % this is needed
  for c=2:numel(EC), EC{c} = [EC{c} EC{1}(1)]; end

  poly{k} = [EC{:}];
  inclusionId(k) = numel(poly{k}) - numel(EC{1});

end

end