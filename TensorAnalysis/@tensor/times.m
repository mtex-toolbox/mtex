function T1 = times(T1,T2)
% multiply a tensor by a scalar

if isa(T2,'double')

  T2 = reshape(T2,[ones(1,T1.rank) size(T2)]);
  
  % TODO: later use T1.M = T1.M .*T2;
  T1.M = bsxfun(@times,T1.M, T2);

elseif isa(T1,'double')
  
  T1 = times(T2,T1);

elseif isa(T1,'tensor') && isa(T2,'tensor')
  
  assert(T1.rank == T2.rank,'Rank of the tensors should be the same.');
  
  % TODO: later use T1.M = T1.M .*T2.M;
  T1.M = bsxfun(@times,T1.M, T2.M);

else
  
  error('I don''t know what to do.')
  
end
