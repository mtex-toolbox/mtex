function T = sym(T,varargin)
% the symmetric part S = 0.5*(T + T') of a tensor
%
% Description
% This function can also be used to fill NaN values to generate a symmetric
% tensor
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

S = T;

switch T.rank

  case 0 % nothing to do
  case 1 % nothing to do
  case 2 
  
    if any(isnan(T.M(:)))
      S.M = max(S.M, permute(S.M,[2 1 3:ndims(S.M)]));
    else
      S.M = 0.5 * (S.M + permute(S.M,[2 1 3:ndims(S.M)]));
    end
    
  otherwise

    dims = (T.rank+1 : ndims(T.M)).';
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
end
 
end
