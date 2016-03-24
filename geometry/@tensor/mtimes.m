function T = mtimes(T1,T2)
% implements T1 * T2

if isa(T1,'double')
  
  T = T2;
  
  % the simple case
  if numel(T1) == 1
    
    T.M = T1 * T.M;
    
  else % the matrix case
    
    R = reshape(T2.M,[],length(T2));
  
    % T1 * R = (R.' * T1.').'
    T.M = reshape((R * T1.'),[repmat(3,1,T.rank),size(T1,1)]);
  end
    
elseif isa(T2,'double')
  
  T = T1;
  % the simple case
  if numel(T1) == 1
    
    T.M = T.M * T2;
    
  else
    
    error('not yet implemented')
    
  end
  
else
  
  error('Wrong type! For tensor product use the command EinsteinSum!')
  
end
