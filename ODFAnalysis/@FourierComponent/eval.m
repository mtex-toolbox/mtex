function f = eval(component,ori,varargin)
% evaluate odf using NSOFT
%
% Input
%  odf - @ODF
%  ori - @orientation
% 
% Output
%  f - double
%

persistent keepPlan;

% kill plan
if check_option(varargin,'killPlan')
  nfsoftmex('finalize',keepPlan);
  keepPlan = [];
  return
end

if isempty(ori), f = []; return; end

% maybe we should set antipodal
component.antipodal = check_option(varargin,'antipodal') || (isa(ori,'orientation') && ori.antipodal);

% extract bandwidth
L = min(component.bandwidth,get_option(varargin,'bandwidth',inf));
Ldim = deg2dim(double(L+1));

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlan;
else
  plan = [];
end
if isempty(plan)

  % 2^4 -> nfsoft-represent
  % 2^2 -> nfsoft-use-DPT
  nfsoft_flags = bitor(2^4,4);
  plan = nfsoftmex('init',L,length(ori),nfsoft_flags,0,4,1000,2*ceil(1.5*L));

  % set nodes
  nfsoftmex('set_x',plan,Euler(ori,'nfft').');

  % node-dependent precomputation
  nfsoftmex('precompute',plan);

end
 
% set Fourier coefficients
nfsoftmex('set_f_hat',plan,reshape(component.f_hat(1:Ldim),[],1));
  
% transform
nfsoftmex('trafo',plan);

% get function values
f = real(nfsoftmex('get_f',plan));

% kill plan
if check_option(varargin,'keepPlan')
  keepPlan = plan;
else
  nfsoftmex('finalize',plan);  
end
  
end
