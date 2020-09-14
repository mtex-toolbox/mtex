function S = sym(T,varargin)
% the symmetric part S = 0.5*(T + T') of a tensor
%
% Syntax
%   S = sym(T)
%
% Input
%  T - @tensor
%
% Output
%  S - @tensor
%

if T.rank < 2
  S = T;
  return;
elseif T.rank < 2
  S = 0.5 * (T + T');
  return
end

S = T;
dims = T.rank+1 : ndims(T.M);
allP = perms(1:T.rank);

if any(isnan(S.M(:)))
  
  % take the mean over all permutations of the dimensions
  for p = allP.'
    S.M = max(S.M, permute(T.M,[p;dims]),'omitnan');
  end
  
else
  S.M = S.M .* 0;

  % take the mean over all permutations of the dimensions
  for p = allP.'
    S.M = S.M + permute(T.M,[p;dims]);
  end
  S.M = S.M ./ size(allP,1);
  
end
