function sFs = quadrature(varargin)
%
% Syntax
%   sF = S2FunHarmonicSym.quadrature(nodes,values,'weights',w,CS)
%   sF = S2FunHarmonicSym.quadrature(f,CS)
%   sF = S2FunHarmonicSym.quadrature(f, 'bandwidth', bandwidth,CS)
%
% Input
%  values - double (first dimension has to be the evaluations)
%  nodes - @vector3d
%  w - double quadrature weights
%  f - function handle in vector3d (first dimension has to be the evaluations)
%
% Output
%   sF - @S2FunHarmonic
%
% Options
%  symmetrise - apply symmetrisation, only required if the function is not yet symmetric
%  bandwidth - harmonic cut off degree
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
if check_option(varargin,'symmetrise')
  if isa(varargin{1},'vector3d') % nodes values
  
    % symmetrise nodes
    varargin{1} = symX * varargin{1};
  
    % symmetries values
    varargin{2} = repmat(reshape(varargin{2},1,[]),numSym(symX),1);
  
    % symmetrise weights
    if check_option(varargin,'weights')
      w = get_option(varargin,'weights') ./ numSym(symX);
      if length(w) == 1
        w = w * ones(size(varargin{2}));
      else
        w = repmat(reshape(w,1,[]),numSym(symX),1);
      end
      varargin = set_option(varargin,'weights',w);
    else
      varargin = set_option(varargin,'weights',1/numSym(symX));
    end
  
  else % function handle

    % symmetrise function handle
    if isa(varargin{1},'S2Fun')
      f = @(v) varargin{1}.eval(v);
    else
      f = varargin{1};
    end
    varargin{1} = @(v) mean(reshape(f(symX*v),numSym(symX),[]),1);
  
  end
end

% TODO: this should be done much better!
% for symmetric function we shall not require so many function
% evaluations!!!
sF = S2FunHarmonic.quadrature(varargin{:});

sFs = S2FunHarmonicSym(sF.fhat,sym);

end
