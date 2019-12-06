function varargout = calcTensor(odf,T,varargin)
% compute the average tensor for an ODF
%
% Syntax
%   [TVoigt, TReuss, THill] = calcTensor(odf,T)
%   THill = calcTensor(odf,T,'Hill')
%   TGeo = calcTensor(odf,T,'geometric')
%
% Input
%  odf - @ODF
%  T   - @tensor
%
% Output
%  T    - @tensor
%
% Options
%  Voigt     - Boigt mean
%  Reuss     - Reuss mean
%  Hill      - Hill mean
%  geometric - geometric mean
%
% See also
% tensor/mean EBSD/calcTensor

% decide between the quadrature based method and the harmonic method
if ~any(cellfun(@(x) isa(x,'BinghamComponent'),odf.components)) ...
    && ~check_option(varargin,'quadrature')

  % the harmonic route is directly implemented into tensor/mean
  [varargout{1:nargout}] = mean(T,odf,varargin{:});

else % quadrature based method

  % define a grid
  res = get_option(varargin,'resolution',2.5*degree);
  S3G = equispacedSO3Grid(odf.CS,odf.SS,'resolution',res);

  % evaluate the ODF
  f = eval(odf,S3G,varargin{:});
  f = f ./ sum(f(:));

  % compute the means
  [varargout{1:nargout}] = mean(S3G*T,'weights',f(:),varargin{:});

end

end
