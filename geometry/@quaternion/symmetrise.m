function varargout = symmetrise(q,CS,SS,varargin)
% symmetrcially equivalent orientations
%
% Input
%  q  - @quaternion
%  CS - crystal @symmetry
%  SS - specimen @symmetry
%
% Output
%  q - symmetrically equivalent orientations CS x SS x q
%
% See also
% CrystalSymmetries

q = mtimes(q, CS.rot, 0).'; % CS x M <- q * CS

if nargin>2 && length(SS.rot)>1
  q = mtimes(SS.rot, q, 1);     % SS x (CS X M)
  lSS = length(SS.rot);
else
  lSS = 1;
end

varargout{1} = reshape(q,length(CS.rot) * lSS,[]); % (CSxSS) x M
