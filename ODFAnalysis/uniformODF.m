function odf = uniformODF(varargin)
% define a uniform ODF
%
% Description
% A *uniformODF* defines a constant ODF.
%
% Syntax
%   odf = uniformODF(CS,SS)
%
% Input
%  CS, SS - crystal, specimen @symmetry
%
%
% Output
%  odf - @SO3Fun
%
% See also
% FourierODF unimodalODF BinghamODF fibreODF

v = 1;
if nargin>0 && isnumeric(varargin{1}) && isscalar(varargin{1})
  v = varargin{1};
end

% get crystal and specimen symmetry
[CS,SS] = extractSym(varargin);
                      
odf = SO3FunRBF(orientation(CS,SS),SO3DeLaValleePoussinKernel,[],v);

end
