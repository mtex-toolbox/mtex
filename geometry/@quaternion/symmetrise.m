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

if nargin>2 && ~isempty(SS) && numSym(SS)>1
  q = mtimes(SS.rot, q, 1);     % SS x (CS X M)
  lSS = numSym(SS);
else
  lSS = 1;
end

varargout{1} = reshape(q,numSym(CS) * lSS,[]); % (CSxSS) x M
