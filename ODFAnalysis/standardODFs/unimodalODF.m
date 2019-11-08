function odf = unimodalODF(varargin)
% define a unimodal ODF
%
% Description
% *unimodalODF* defines a radially symmetric, unimodal ODF 
% with respect to a crystal orientation |mod|. The
% shape of the ODF is defined by a @kernel function.
%
% Syntax
%   mod = orientation.byEuler(phi1,Phi,phi2,CS,SS)
%   odf = unimodalODF(mod) % default halfwidth 10 degree 
%   odf = unimodalODF(mod,'halfwidth',15*degree) % specify halfwidth
%   odf = unimodalODF(mod,CS,SS)  % specify crystal and specimen symmetry
%   odf = unimodalODF(mod,kernel) % specify @kernel shape 
%   odf = unimodalODF(mod,'weights',weights) % specify weights for each component
%
% Input
%  mod    - @quaternion modal orientation
%  CS, SS - crystal, specimen @symmetry
%  hw     - halfwidth of the kernel (default -- 10°)
%  kernel - @kernel function (default -- de la Vallee Poussin)
%
%
% Output
%  odf - @ODF
%
% See also
% ODF/ODF uniformODF fibreODF

% get crystal and specimen symmetry
[CS,SS] = extractSymmetries(varargin);

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
psi = getClass(varargin,'kernel');
if isempty(psi)
  hw = get_option(varargin,'halfwidth',10*degree);
  psi = deLaValleePoussinKernel('halfwidth',hw);
end

% get weights
weights = get_option(varargin,'weights',ones(size(center))./length(center));
assert(numel(weights) == length(center),...
  'Number of orientations and weights must be equal!');

% remove to small values
id = weights./sum(weights(:)) > 1e-2 / psi.K(1) / numel(weights);
try
  center = center.subGrid(id);
catch
  center = center(id);
end
component = unimodalComponent(center,psi,weights(id));

odf = ODF(component,1);

end
