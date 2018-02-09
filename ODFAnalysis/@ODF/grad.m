function g = grad(odf,ori,varargin)
% gradient of odf at orientation ori
%
% Syntax
%
%   g = odf.grad(ori) % compute the gradient
%
%   % go 5 degree in direction of the gradient
%   ori_new = exp(ori,5*degree*normalize(g)) 
%
% Input
%  odf - @ODF
%  ori - @orientation
%
% Output
%  g - @vector3d gradient of the ODF at the orientations ori
%
% See also
% ODF/eval orientation/exp

if isa(ori,'orientation') && (odf.CS.Laue ~= ori.CS.Laue || ...
    odf.SS.Laue ~= ori.SS.Laue)
  warning('symmetry missmatch'); %#ok<WNTAG>
end

% evaluate components
g = vector3d.zeros(size(ori));

if isempty(ori), return; end

% compute the gradient for each component seperately
for i = 1:numel(odf.components)
  g = g + odf.weights(i) * odf.components{i}.grad(ori,varargin{:});
end
