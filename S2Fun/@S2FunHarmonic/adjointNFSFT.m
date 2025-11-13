function sF = adjointNFSFT(nodes,values, varargin)
% Compute the adjoint S2-Fourier transform of given evaluations on a 
% specific quadrature grid, by using the NFSFT-method 
% (nonequispaced fast spherical fourier transform).
%
% Syntax
%   sF = S2FunHarmonic.adjoint(nodes,values)
%   sF = S2FunHarmonic.adjoint(nodes,values,'bandwidth',32,'weights',w)
%   sF = S2FunHarmonic.adjoint(f)
%
% Input
%  nodes  - @vector3d
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
  sF = [];
  return
end

% multivariate functions
if numel(nodes)~=numel(values)
  s = size(values); s = s(2:end);
  values = reshape(values,numel(nodes),[]);
  S2FunHarmonic.adjoint(nodes,values(:,1),'createPlan',varargin{:});
  sF=[];
  for ind = 1:prod(size(values, 2))
    G = S2FunHarmonic.adjoint(nodes,values(:,ind),'keepPlan',varargin{:});
    sF = [sF,G];
  end
  S2FunHarmonic.adjoint(zvector,1,'killPlan');
  sF = reshape(sF, s); 
  return
end

% get plotting convention
how2plot = getClass(varargin,'plottingConvention',nodes.how2plot);

sz = size(values);
len = prod(sz(2:end)); % multivariate case
values = reshape(values, [], len);
keepPlan = check_option(varargin,'keepPlan');

% --------------- (1) get weights and values for quadrature ---------------

if isa(nodes,'quadratureS2Grid')
  bw = nodes.bandwidth;
  W = nodes.weights;
else
  bw = get_option(varargin,'bandwidth', 128);

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
if any(isinf(values(:)))
  ind = isinf(values);
  m = max( abs(values(~ind)) ,[],'all')*1e+10;
  values(ind) = sign(values(ind)) .* m;
  warning(['There are poles at some quadrature nodes. They are set to +-',num2str(m,3),'.'])
  % error('There are poles at some quadrature nodes.')
end
if any(isnan(values(:)))
  warning('There are Nan values in some nodes. They are set to 0.')
  values(isnan(values)) = 0;
end

if isempty(nodes)
  sF = S2FunHarmonic(0);
  sF.how2plot = how2plot;
  return
end
if bw==0
  sF = S2FunHarmonic(mean(values)*sqrt(4*pi));
  sF.how2plot = how2plot;
  return
end

% -------------------------- (2-4) Adjoint NFSFT --------------------------

% create plan
if keepPlan
  plan = keepPlanNSFT;
else
  plan = [];
end

% initialize nfsft
if isempty(plan)
  nfsftmex('precompute', bw, 1000, 1, 0);
  plan = nfsftmex('init_advanced', bw, numel(nodes), 1);
  [theta,rho] = polar(nodes); %#ok<POLAR>
  nfsftmex('set_x', plan, [rho(:).'; theta(:).']); % set vertices
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
if keepPlan
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

if ~keepPlan, sF.how2plot = how2plot; end

end
