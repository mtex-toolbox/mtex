function g = grad(odf,ori,varargin)
% gradient of odf at orientation ori
%
%
% Input
%  odf - @ODF
%  ori - @orientation
%
% Output
%  g - gradient of the ODF at the orientations ori
%
% See also
% ODF/eval

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
