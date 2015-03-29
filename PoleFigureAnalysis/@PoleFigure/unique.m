function pf = unique(pf,varargin)
% remove dublicated points in a polefigure

for ip = 1:pf.numPF
  
  v = symmetrise(pf.allR{ip},pf.SS);

  [~,~,pos] = unique(v,varargin{:});

  [~,ndx,pos] = unique(min(reshape(pos,size(v)),[],1));

  pf.allR{ip} = pf.allR{ip}.subSet(ndx);

  A = sparse(1:numel(pos),pos,1);
  A = A * spdiags(1./sum(A).',0,size(A,2),size(A,2));
  
  pf.allI{ip} = A.' * pf.allI{ip}(:);
    
end
