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
if ~isa(odf,'BinghamODF') && ~check_option(varargin,'quadrature')
  odf = FourierODF(odf,rank(T));
end

% more then one output -> also compute Reuss mean
if ~check_option(varargin,'Reuss'), varargin = [varargin,{'Voigt'}];end
if nargout > 1, varargin = [varargin,{'Reuss'}];end

% cycle through components
[TVoigt, TReuss] = doMeanTensor(odf,T,varargin{:});

for i = 2:numel(odf)

  [TV, TR] = doMeanTensor(odf,T,varargin{:});
  
  TVoigt = TVoigt + odf(i).weight * TV;
  TReuss = TReuss + odf(i).weight * TR;

end

% Hill is just the average between Voigt and Reuss
THill = 0.5*(TVoigt + TReuss);


% if type is specified only return this type
if nargout <= 1
  if check_option(varargin,'Reuss'), TVoigt = TReuss;end
  if check_option(varargin,'Hill'), TVoigt = THill;end
end
