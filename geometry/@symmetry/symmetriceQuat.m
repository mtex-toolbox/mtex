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
q = SS * q(:).';     % SS x (CS X M)
q = reshape(q,length(CS)*length(SS),[]).'; % M x (CSxSS)
