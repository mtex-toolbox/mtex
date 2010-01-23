function q = symmetrise(q,CS,SS,varargin)
% symmetrcially equivalent orientations
%
%% Input
%  q  - @quaternion
%  CS - crystal @symmetry
%  SS - specimen @symmetry
%
%% Output
%  q - symmetrically equivalent orientations
%
%% See also

q = (q * CS).'; % CS x M
if length(SS)>1
  q = SS * q;     % SS x (CS X M)
end

q = reshape(q,length(CS) * max(1,length(SS)),[]); % (CSxSS) x M
