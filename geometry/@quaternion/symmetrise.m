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

q = (q * CS).'; % CS x M
if nargin>2 && length(SS)>1
  q = SS * q;     % SS x (CS X M)
  lSS = length(SS);
else
  lSS = 1;
end

varargout{1} = reshape(q,length(CS) * lSS,[]); % (CSxSS) x M
