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
  if numel(T2) == 1

    T.M = T.M * T2;

  elseif size(T,2) == size(T2,1) % the matrix case

    s = size(T2);
    L = reshape(T1.M,[],s(1));
    T.M = reshape(L * T2,[repmat(3,1,T.rank),size(T1,1),s(2:end)]);

  end

elseif T1.rank ==2 && isa(T2,'vector3d')
 
  T = vector3d(EinsteinSum(T1,[1 -1],T2,-1,'keepClass'));
   
elseif T1.rank ==2 && isa(T2,'tensor') && T2.rank ==1
  
  T = EinsteinSum(T1,[1 -1],T2,-1);
  
elseif T1.rank ==2 && isa(T2,'tensor') && T2.rank ==2
  
  T = EinsteinSum(T1,[1 -1],T2,[-1 2]);
  
else

  error('For product between tensors use the command EinsteinSum!')
  
end
