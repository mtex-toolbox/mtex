function T = mpower(T,n)
% implements T ^ n

if isa(n,'double') && T.rank == 2
  
  T = expm(n*logm(T));
 
else

  error('Do not know what to do here!')
  
end
