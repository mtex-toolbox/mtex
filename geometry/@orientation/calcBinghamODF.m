function odf = calcBinghamODF(ori,varargin)
% calculate ODF from individual orientations via kernel density estimation
%
% Input
%  ori  - @orientation
%
% Output
%  odf - @SO3FunBingham
%
% See also
% EBSD2odf EBSD/load

% maybe there is nothing to do
if isempty(ori), odf = ODF; return, end

% estimate Bingham parameters
[~,~,lambda,ev] = mean(ori,varargin{:});
kappa = evalkappa(lambda,varargin{:});

% set up Bingham ODF
odf = BinghamODF(kappa,ev,ori.CS,ori.SS);
