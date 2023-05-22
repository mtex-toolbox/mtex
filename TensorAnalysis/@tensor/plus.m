function T = plus(T1,T2)
% add two tensors

if ~isa(T1,'tensor'), [T1,T2] = deal(T1,T2); end

T = T1;
if isa(T2,'tensor')
  T.M = T.M + T2.M;

  if isfield(T1.opt,'density') && isfield(T2.opt,'density') ...
      && any(T1.opt.density ~= T2.opt.density)
    
    warning(['Tensors with different density have been summed! I have ' ...
      'removed the density information from the resulting tensor. ' ...
      'You need to reset the density your own by \n\n%s'], ...
      '  T.density = (fak1 * T1.density + fak2 * T2.density) / (fak1 + fak2).')
    T.opt = rmfield(T.opt,'density');

  end

else
  
  if T1.rank == 4 && size(T2,1) == 6 && size(T2,2) == 6
    T.M = tensor24(matrix(T1,'Voigt') + T2,T1.doubleConvention);
  else
    T.M = T.M + reshape(T2,[ones(1,T1.rank),size(T2)]);
  end
end

end