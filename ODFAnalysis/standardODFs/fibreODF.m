function odf = fibreODF(varargin)
% defines an fibre symmetric ODF
%
% Description
% *fibreODF* defines a fibre symmetric ODF with respect to 
% a crystal direction |h| and a specimen directions |r|. The
% shape of the ODF is defined by a @kernel function.
%
% Syntax
%   h = Miller(h,k,l,CS)
%   r = vector3d(x,y,z);
%   odf = fibreODF(h,r) % default halfwith 10*degree
%   odf = fibreODF(h,r,'halfwidth',15*degree) % specify halfwidth
%   odf = fibreODF(h,r,kernel) % specify @kernel shape
%   odf = fibreODF(h,r,SS)  % specify crystal and specimen symmetry
%
% Input
%  h      - @Miller / @vector3d crystal direction
%  r      - @vector3d specimen direction
%  CS, SS - crystal, specimen @symmetry
%  hw     - halfwidth of the kernel (default -- 10°)
%  kernel - @kernel function (default -- de la Vallee Poussin)
%
% Output
%  odf - @ODF
%
% See also
% ODF/ODF uniformODF unimodalODF

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
psi = getClass(varargin,'kernel',[]);
if isempty(psi)
  hw = get_option(varargin,'halfwidth',10*degree);
  psi = deLaValleePoussinKernel('halfwidth',hw); % todo: replace with S2DeLaValleePoussin
end

% get weights
weights = get_option(varargin,'weights',ones(size(h)));
assert(numel(weights) == length(h),...
  'Number of fibres and weights must be equal!');

component = fibreComponent(h,r,weights,psi,SS);

odf = ODF(component,1);

end
