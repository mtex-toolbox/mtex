function varargout = getgrid(odf,ind)
% get mods of the components
%
%% Input
%  odf - @ODF
%  ind - [double] indece to specific components (optional)
%
%% Output
%  G   - @SO3Grid of modal orientations

varargout{1} = [];
for i = 1:length(odf)
  if isa(odf(i).center,'SO3Grid'),varargout{i} = odf(i).center;end
end

if nargin == 2
  varargout{1} = varargout{1}(ind);
end
