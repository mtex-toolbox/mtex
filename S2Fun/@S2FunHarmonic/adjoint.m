function sF = adjoint(vec,values, varargin)
% Compute the adjoint S2-Fourier transform of given evaluations on a 
% specific quadrature grid, by using the NFSFT-method 
% (nonequispaced fast spherical fourier transform).
%
% Syntax
%   sF = S2FunHarmonic.adjoint(vec,values)
%   sF = S2FunHarmonic.adjoint(vec,values,'bandwidth',32,'weights',w)
%   sF = S2FunHarmonic.adjoint(f)
%
% Input
%  vec    - @vector3d
%  values - double
%
% Output
%  sF - @S2FunHarmonic
%
% Options
%  bandwidth - maximal harmonic degree (default: 128)
%  weights   - quadrature weights
%
% See also
% S2FunHarmonic/quadrature S2FunHarmonic/approximate
% S2FunHarmonic/interpolate


  persistent keepPlanNSFT;

% kill plan
if check_option(varargin,'killPlan')
  nfsftmex('finalize',keepPlanNSFT);
  keepPlanNSFT = [];
  return
end

% Multivariate functions
if length(vec)~=numel(values)
  s = size(values); s = s(2:end);
  values = reshape(values,length(vec),[]);
  S2FunHarmonic.adjoint(vec,values(:,1),'createPlan',varargin{:});
  sF=[];
  for ind = 1:prod(size(values, 2))
    G = S2FunHarmonic.adjoint(vec,values(:,ind),'keepPlan',varargin{:});
    sF = [sF,G];
  end
  S2FunHarmonic.adjoint(zvector,1,'killPlan');
  sF = reshape(sF, s); 
  return
end

sz = size(values);
len = prod(sz(2:end)); % multivariate case
values = reshape(values, [], len);


% --------------- (1) get weights and values for quadrature ---------------

if isa(vec,'quadratureS2Grid')
  bw = vec.bandwidth;
  nodes = vec(:);
  W = vec.weights;
else
  bw = get_option(varargin,'bandwidth', 128);
  nodes = vec(:);
  nodes.how2plot = getClass(varargin,'plottingConvention',nodes.how2plot);
  W = get_option(varargin,'weights',1);
  % if length(nodes)>100000 && length(values) == length(nodes) && isscalar(W)
  %   % TODO: use a regular grid here and a faster search
  %   n2 = equispacedS2Grid('resolution',0.5*degree);
  %   id = find(n2,nodes);
  %   values = accumarray(id,values,[length(n2),1]);
  % 
  %   id = values>0;
  %   nodes = reshape(n2.subGrid(id),[],1);
  %   values = values(id);
  %   nodes.antipodal = f.antipodal;
  % end
end

% check for Inf-values (quadrature fails)
if any(isinf(values))
  error('There are poles at some quadrature nodes.')
end
if any(isnan(values))
  warning('There are Nan values in some nodes. They are set to 0.')
  values(isnan(values)) = 0;
end

if isempty(nodes)
  sF = S2FunHarmonic(0);
  return
end
if bw==0
  sF = S2FunHarmonic(mean(values)*sqrt(4*pi));
  return
end

% -------------------------- (2-4) Adjoint NFSFT --------------------------

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlanNSFT;
else
  plan = [];
end

% initialize nfsft
if isempty(plan)
  nfsftmex('precompute', bw, 1000, 1, 0);
  plan = nfsftmex('init_advanced', bw, length(nodes), 1);
  nfsftmex('set_x', plan, [nodes.rho'; nodes.theta']); % set vertices
  nfsftmex('precompute_x', plan);
end

if check_option(varargin,'createPlan')
  keepPlanNSFT = plan;
  sF=[];
  return
end

% adjoint nfsft
nfsftmex('set_f', plan, W(:) .* values(:));
nfsftmex('adjoint', plan);
fhat = nfsftmex('get_f_hat_linear', plan);

% kill plan
if check_option(varargin,'keepPlan')
  keepPlanNSFT = plan;
else
  nfsftmex('finalize', plan);
end

% -------------------- (5) Construct S2FunHarmonic ------------------------

sF = S2FunHarmonic(fhat);
sF.bandwidth = min([bw,sF.bandwidth]);

% if antipodal consider only even coefficients
if check_option(varargin,'antipodal') || nodes.antipodal 
  sF = sF.even;
end

sF.how2plot = nodes.how2plot;

end
