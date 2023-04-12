function varargout = symmetricDecomposition(T,varargin)
% decomposes the tensor into 
%
% Syntax
%   % decompose into symmetric portions
%   [T1, T2, T3] = symmetricDecomposition(T,cs1,cs2,cs3)
%
% Input
%  T  - @tensor
%  cs1, cs2, cs3 - @symmetry
%
% Output
%  T1, T2, T3  - @tensor
%
% Example
%
% T = stiffnessTensor([
%    225 54 72 0 0 0
%    54 214 53 0 0 0
%    72 53 178 0 0 0
%    0 0 0 78 0 0
%    0 0 0 0 82 0
%    0 0 0 0 0 76]);
%
% csHex = crystalSymmetry('622');
% csTet = crystalSymmetry('422');
% csOrt = crystalSymmetry('222');
% csMon = crystalSymmetry('2');
%
% [Tiso, THex, TTet, TOrt, TMon] = symmetricDecomposition(T,csHex,csTet,csOrt,csMon)
%
% References
%
% * <https://doi.org/10.1111/j.1365-246X.2004.02415.x Decomposition of the
% elastic tensor and geophysical applications> J.T. Browaeys, S. Chevrot,
% Geophysical Journal International (2004).
%

csList = varargin(cellfun(@(x) isa(x,'symmetry'),varargin));

varargout{1} = symmetrise(T,'iso');
T = T - varargout{1};

for k = 1:length(csList)
  varargout{k+1} = mean(csList{k}.rot * T);
  T = T - varargout{k+1};

end
varargout{k+2} = T;