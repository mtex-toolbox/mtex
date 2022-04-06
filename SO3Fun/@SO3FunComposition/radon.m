function out = radon(odf,h,varargin)
% radon transform of a SO3FunComposition
%
% Syntax
%   S2F = radon(SO3F,h)
%   S2F = radon(SO3F,[],r)
%   v = radon(SO3F,h,r)
%
% Input
%  SO3F - @SO3FunComposition
%  h    - @vector3d, @Miller
%  r    - @vector3d, @Miller
%
% Output
%  S2F  - @S2Fun
%  v    - double
%

% cycle through components
out = radon(odf.components{1},h,varargin{:});
for i = 2:length(odf.components)
  out = out + radon(odf.components{i},h,varargin{:});
end

end