function odf = unimodalODF(varargin)
% define a unimodal ODF
%
% Description
% *unimodalODF* defines a radially symmetric, unimodal ODF
% with respect to a crystal orientation |mod|. The
% shape of the ODF is defined by a @SO3Kernel function.
%
% Syntax
%   mod = orientation.byEuler(phi1,Phi,phi2,CS,SS)
%   odf = unimodalODF(mod) % default halfwidth 10 degree
%   odf = unimodalODF(mod,'halfwidth',15*degree) % specify halfwidth
%   odf = unimodalODF(mod,CS,SS)  % specify crystal and specimen symmetry
%   odf = unimodalODF(mod,psi) % specify @SO3Kernel shape
%   odf = unimodalODF(mod,'weights',weights) % specify weights for each component
%
% Input
%  mod    - @quaternion modal orientation
%  CS, SS - crystal, specimen @symmetry
%  hw     - halfwidth of the kernel (default -- 10°)
%  psi    - @SO3Kernel function (default -- SO3 de la Vallee Poussin)
%
% Flags
%  nothinning - keep all nodes, otherwise small portions will be thinned out by default
%
% Output
%  odf - @SO3Fun
%
% See also
% FourierODF uniformODF BinghamODF fibreODF

% get crystal and specimen symmetry
[CS,SS] = extractSym(varargin);

% get center
if nargin > 0 && isa(varargin{1},'quaternion')

    center = varargin{1};

    if ~isa(center,'orientation')
        center = orientation(center,CS,SS);
    end
else
    center = orientation.id(CS,SS);
end

% get kernel
psi = getClass(varargin,'SO3Kernel');
if isempty(psi)
    hw = get_option(varargin,'halfwidth',10*degree);
    psi = SO3DeLaValleePoussinKernel('halfwidth',hw);
end

% get weights
weights = get_option(varargin,'weights',ones(numel(center),1)./length(center)./psi.A(1));
if numel(center) == numel(weights)
  weights = weights(:);
end
assert(size(weights,1) == numel(center),...
    'Number of orientations and weights must be matching!');


% remove to small values
if ~check_option(varargin,{'nothinning','-nothinning','exact'})
  sz = size(weights);
  weights = weights(:,:);
  id = weights./sum(weights,1) > 1e-2 / psi.eval(1) / numel(center);
  id = any(id,2);
  try
    center = center.subGrid(id);
  catch
    if ~all(id)
      center = center(id);
    end
  end
  ind = id.*(1:length(weights))';
  ind = ind(ind~=0);
  weights = weights(ind,:);
  weights = reshape(weights,[sum(id) sz(2:end)]);
end

odf = SO3FunRBF(center, psi, weights);

end
