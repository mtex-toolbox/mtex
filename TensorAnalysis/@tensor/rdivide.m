function out = rdivide(T,S)
% T1 ./ T2

if isa(S,'double') 
  
  if numel(S)>1
    S = repmat(reshape(S,[ones(1,T.rank) size(T)]), [3*ones(1,T.rank),1,1]); 
  end
  
  T.M = T.M ./ S;
  out = T;
    
elseif isa(S,'tensor')
  
  T.M = T.M ./ S.M;
  out = T;
  
end
