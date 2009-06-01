function q = symmetriceQuat(CS,SS,q,varargin)
% symmetrcially equivalent orientations
%
%% Input
%  CS - crystal @symmetry
%  SS - specimen @symmetry
%  q  - @quaternion
%
%% Output
%  q - symmetrically equivalent orientations
%
%% See also

q = (q(:) * CS).'; % CS x M
if ~isempty(SS)
  q = SS * q(:).';     % SS x (CS X M)
end
q = reshape(q,length(CS)*max(1,length(SS)),[]).'; % M x (CSxSS)
