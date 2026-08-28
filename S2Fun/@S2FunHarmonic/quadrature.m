function sF = quadrature(f, varargin)
% Compute the S2-Fourier/harmonic coefficients of an given @S2Fun or
% given evaluations on a specific quadrature grid.
%
% Therefore we obtain the Fourier coefficients with numerical integration
% (quadrature), i.e. we choose a quadrature scheme of meaningful quadrature 
% nodes $v_m$ and quadrature weights $\omega_m$ and compute
%
% $$ \hat f_n^{k} = \int_{S^2} f(v)\, \overline{Y_n^{k}(v)} \mathrm{d}\my(v) \approx \sum_{m=1}^M \omega_m \, f(v_m) \, \overline{Y_n^{k}(v_m)}, $$
%
% for all $n=0,\dots,N$ and $k=-n,\dots,n$. 
%
% Therefore this method evaluates the given S2Fun on the quadrature grid.
% Afterwards it uses the adjoint NFSFT (nonequispaced fast spherical 
% Fourier transform) to quickly compute the above sums.
%
% Syntax
%   sF = S2FunHarmonic.quadrature(nodes,values,'weights',w)
%   sF = S2FunHarmonic.quadrature(f)
%   sF = S2FunHarmonic.quadrature(f, 'bandwidth', bandwidth)
%   sF = S2FunHarmonic.quadrature(f, cs)
%
% Input
%  values - double (first dimension has to be the evaluations)
%  nodes - @vector3d
%  f - function handle in vector3d (first dimension has to be the evaluations)
%  cs - @crystalFrame or @specimenFrame the result is written in
%
% Output
%  sF - @S2FunHarmonic
%
% Options
%  bandwidth - minimal degree of the spherical harmonic (default: 128)
%  symmetrise - spread the nodes or the function over the group first
%
% See also
% S2FunHarmonic/approximate S2FunHarmonic S2FunHarmonic/symmetrise

% ------------- (0) A frame naming a group asks for a symmetric function --

% written in a frame that carries a group means symmetric under that group,
% so the coefficients are symmetrised below. Only a frame the caller names
% counts - the one f carries is the fallback of the adjoint and says
% nothing about the function being symmetric.
sym = S2Fun.extractFrame(varargin{:});
doSym = ~isempty(sym) && sym.id ~= 1;

if doSym

  % a Laue group is the proper one plus antipodal, and antipodal is cheap
  if sym.isLaue
    symX = sym.properSubGroup;
    varargin = [varargin,'antipodal'];
  else
    symX = sym;
  end

  % spread the input over the group
  if check_option(varargin,'symmetrise')
    [f,varargin] = spreadOverGroup(f,symX,varargin);
  end

end

% --------------------- (1) Input is (nodes,values) -----------------------

if isa(f,'vector3d')

  sF = S2FunHarmonic.adjoint(f,varargin{:});
  if doSym, sF = S2FunHarmonicSym(sF.fhat,sym); end
  return

end

% ---------- (2) Get nodes, values and weights in case of S2Fun ----------

if isa(f,'function_handle')
  % only hand over a symmetry that was given, extractSym would fabricate one
  f = S2FunHandle(f,getClass(varargin,'referenceFrame'));
end

% commented out - seems to be obsolete and leads to misbehaviour for S2FunMLS
% if f.antipodal
  % f.antipodal = 0;
  % varargin{end+1} = 'antipodal';
% end

bw = get_option(varargin,'bandwidth', 128);

if check_option(varargin,'S2Grid')
  S2G = get_option(varargin,'S2Grid');
else
  S2G = quadratureS2Grid(bw,varargin{:});
end

% evaluate on S2Grid
values = f.eval(S2G);

% ----------------------- (3) Do adjoint NSOFT ----------------------------

% the function's own frame is only the fallback - a frame or convention
% passed by the caller comes first in the list and wins
sF = S2FunHarmonic.adjoint(S2G,values,varargin{:},f.frame);
sF.bandwidth = bw;

% if antipodal consider only even coefficients
if check_option(varargin,'antipodal') || S2G.antipodal
  sF = sF.even;
end

if doSym, sF = S2FunHarmonicSym(sF.fhat,sym); end

end

% -------------------------------------------------------------------------
function [f,args] = spreadOverGroup(f,symX,args)
% repeat the input over the orbits of symX, so the quadrature sees the
% symmetric function rather than the one it was given

if isa(f,'vector3d') % nodes and values

  f = symX * f;

  args{1} = repmat(reshape(args{1},1,[]),numSym(symX),1);

  if check_option(args,'weights')
    w = get_option(args,'weights') ./ numSym(symX);
    if isscalar(w)
      w = w * ones(size(args{1}));
    else
      w = repmat(reshape(w,1,[]),numSym(symX),1);
    end
    args = set_option(args,'weights',w);
  else
    args = set_option(args,'weights',1/numSym(symX));
  end

else % function handle or S2Fun

  if isa(f,'S2Fun'), g = @(v) f.eval(v); else, g = f; end
  f = @(v) mean(reshape(g(symX*v),numSym(symX),[]),1);

end

end
