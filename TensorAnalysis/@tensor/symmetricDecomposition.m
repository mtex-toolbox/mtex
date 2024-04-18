function varargout = symmetricDecomposition(T,varargin)
% decomposes the tensor into 
%
% Syntax
%   % decompose into symmetric portions
%   [Tiso, T1, T2, T3] = symmetricDecomposition(T,cs1,cs2,cs3)
%
% Input
%  T  - @tensor
%  cs1, cs2, cs3 - @symmetry
%
% Output
%  T1, T2, T3 - @tensor
%
% Example
%
%   cs = crystalSymmetry('222',[18 8.8 5.2],'mineral','Enstatite');
%
%   T = stiffnessTensor([
%    225 54 72 0 0 0
%    54 214 53 0 0 0
%    72 53 178 0 0 0
%    0 0 0 78 0 0
%    0 0 0 0 82 0
%    0 0 0 0 0 76],cs);
%
%   csHex = crystalSymmetry('622','mineral','Enstatite');
%   csTet = crystalSymmetry('422','mineral','Enstatite');
%
%   [Tiso, THex, TTet, TOrt] = symmetricDecomposition(T,csHex,csTet)
%
% References
%
% * <https://doi.org/10.1111/j.1365-246X.2004.02415.x Decomposition of the
% elastic tensor and geophysical applications> J.T. Browaeys, S. Chevrot,
% Geophysical Journal International (2004).
%

csList = varargin(cellfun(@(x) isa(x,'symmetry'),varargin));

varargout{1} = symmetrise(T,'iso');
if check_option(varargin,'ensureSPD')
  alpha = fzero(@(alpha) min(eig(T - alpha * varargout{1})),0);
  varargout{1} = alpha * varargout{1};
end
T = T - varargout{1};

for k = 1:length(csList)
  varargout{k+1} = mean(csList{k}.rot * T); %#ok<AGROW>
  T = T - varargout{k+1};

end
varargout{k+2} = T;