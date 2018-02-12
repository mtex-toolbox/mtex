function S = sym(T,varargin)
% the symmetric part S = 0.5(T + T.') of a tensor
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
S.M = S.M .* 0;

switch  T.rank
  case {4,6,8}
    allP = perms(1:T.rank);
    for p = allP.'
      S.M = S.M + permute(T.M,p);
    end
    S.M = S.M ./ size(allP,1);
  case 2
    S = 0.5*(T + T');
  otherwise
    T.M = T.M .* 0;
    S = T;
end
