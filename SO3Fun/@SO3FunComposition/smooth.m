function SO3F = smooth(SO3F,varargin)
% smooth SO3FunComposition
%
% Input
%  SO3F - @SO3FunComposition
%  psi - @SO3Kernel (smoothing kernel)
%
% Options
%  halfwidth
%
% Output
%  SO3F - smoothed @SO3Fun
%
% See also
% SO3Fun/smooth

% smooth components
for i = 1:length(SO3F.components)
  SO3F.components{i} = SO3F.components{i}.smooth(varargin{:});
end

end