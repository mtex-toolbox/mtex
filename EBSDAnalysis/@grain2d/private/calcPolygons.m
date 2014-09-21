function poly = calcPolygons(I_FG,F,V)
% Input:
%  I_FG - incidence matrix faces to grains

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
  
end

end
