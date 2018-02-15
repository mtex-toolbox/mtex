function [TVoigt, TReuss, THill] = calcTensor(odf,T,varargin)
% compute the average tensor for an ODF
%
% Syntax
%   [TVoigt, TReuss, THill] = calcTensor(odf,T)
%   THill = calcTensor(odf,T,'Hill')
%
% Input
%  odf - @ODF
%  T   - @tensor
%
% Output
%  T    - @tensor
%
% Options
%  voigt - voigt mean
%  reuss - reuss mean
%  hill  - hill mean
%
% See also
%
 
% convert to FourierODF
if ~any(cellfun(@(x) isa(x,'BinghamComponent'),odf.components)) ...
    && ~check_option(varargin,'quadrature')
  odf = FourierODF(odf,T.rank);
end

% more then one output -> also compute Reuss mean
if ~check_option(varargin,'Reuss'), varargin = [varargin,{'Voigt'}];end
if nargout > 1, varargin = [varargin,{'Reuss'}];end

% cycle through components
[TVoigt, TReuss] = calcTensor(odf.components{1},T,varargin{:});

for i = 2:numel(odf.components)
  
  [TV, TR] = calcTensor(odf.components{i},T,varargin{:});
  
  TVoigt = TVoigt + odf.weights(i) * TV;
  TReuss = TReuss + odf.weights(i) * TR;

end

% Hill is just the average between Voigt and Reuss
THill = 0.5*(TVoigt + TReuss);


% if type is specified only return this type
if nargout <= 1
  if check_option(varargin,'Reuss'), TVoigt = TReuss;end
  if check_option(varargin,'Hill'), TVoigt = THill;end
end
