function sFs = quadrature(varargin)
%
% Syntax
%  sF = S2FunHarmonicSym.quadrature(nodes,values,'weights',w,CS)
%  sF = S2FunHarmonicSym.quadrature(f,CS)
%  sF = S2FunHarmonicSym.quadrature(f, 'bandwidth', bandwidth,CS)
%
% Input
%  values - double (first dimension has to be the evaluations)
%  nodes - @vector3d
%  f - function handle in vector3d (first dimension has to be the evaluations)
%
% Output
%   sF - @S2FunHarmonic
%
% Options
%  bandwidth - minimal degree of the spherical harmonic (default: 128)
%

% extract symmetry
sym = getClass(varargin,'symmetry',specimenSymmetry);

if sym.isLaue
  symX = sym.properSubGroup;
  varargin = [varargin,'antipodal'];
else
  symX = sym;
end

% symmetrise the input
if isa(varargin{1},'vector3d') % nodes values
  
  % symmetrise nodes
  varargin{1} = symX * varargin{1};
  
  % symmetries values
  varargin{2} = repmat(reshape(varargin{2},1,[]),length(symX),1);
  
  % symmetrise weights
  if check_option(varargin,'weights')
    w = get_option(varargin,'weights') ./ length(symX);
    w = repmat(reshape(w,1,[]),length(symX),1);
    varargin = set_option(varargin,'weights',w);
  else
    varargin = set_option(varargin,'weights',1/length(symX));
  end
  
else % function handle

  % symmetrise function handle
  f = varargin{1};
  varargin{1} = @(v) mean(reshape(f(sym*v),length(symX),[]));
  
end

sF = S2FunHarmonic.quadrature(varargin{:});

sFs = S2FunHarmonicSym(sF.fhat,sym);

end
