function odf = fibreODF(varargin)
% defines an fibre symmetric ODF
%
% Description
% *fibreODF* defines a fibre symmetric ODF with respect to 
% a crystal direction |h| and a specimen directions |r|. The
% shape of the ODF is defined by a @S2Kernel function.
%
% Syntax
%   h = Miller(h,k,l,CS)
%   r = vector3d(x,y,z);
%   odf = fibreODF(h,r) % default halfwith 10*degree
%   odf = fibreODF(h,r,'halfwidth',15*degree) % specify halfwidth
%   odf = fibreODF(h,r,psi) % specify @S2Kernel shape
%   odf = fibreODF(h,r,SS)  % specify crystal and specimen symmetry
%
% Input
%  h      - @Miller / @vector3d crystal direction
%  r      - @vector3d specimen direction
%  CS, SS - crystal, specimen @symmetry
%  hw     - halfwidth of the kernel (default -- 10°)
%  psi    - @S2Kernel function (default -- S2 de la Vallee Poussin)
%
% Output
%  odf - @SO3Fun
%
% See also
% FourierODF uniformODF unimodalODF BinghamODF

% get fibre
if isa(varargin{1},'fibre')
  h = varargin{1}.h;
  r = varargin{1}.r;
  SS = varargin{1}.SS;
  varargin(1) = [];
else
  h = argin_check(varargin{1},'Miller');
  r = argin_check(varargin{2},'vector3d');
  
  % get specimen symmetry
  if isa(r,'Miller')
    SS = r.CS;
  else
    SS = getClass(varargin,'specimenSymmetry',specimenSymmetry);
  end
end

% get kernel
psi = getClass(varargin,'S2Kernel',[]);
if isempty(psi)
  hw = get_option(varargin,'halfwidth',10*degree);
  psi = S2DeLaValleePoussinKernel('halfwidth',hw);
end

% get weights
weights = get_option(varargin,'weights',ones(size(h)));
assert(numel(weights) == length(h),...
  'Number of fibres and weights must be equal!');

odf = SO3FunCBF(h,r,weights,psi,SS);

end
