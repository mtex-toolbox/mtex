function SO3F = quadrature(f, varargin)
%
% Syntax
%   SO3F = SO3FunHarmonic.quadrature(nodes,values,'weights',w)
%   SO3F = SO3FunHarmonic.quadrature(f)
%   SO3F = SO3FunHarmonic.quadrature(f, 'bandwidth', bandwidth)
%
% Input
%  values - double (first dimension has to be the evaluations)
%  nodes  - @rotation, @orientation
%  f - function handle in @orientation (first dimension has to be the evaluations)
%
% Output
%  SO3F - @SO3FunHarmonic
%
% Options
%  bandwidth - minimal harmonic degree (default: 64)
%

if ~check_option(varargin,'nfsoft')
  SO3F = SO3FunHarmonic.quadratureV2(f,varargin{:});
  return
end


persistent keepPlanNSOFT;

% kill plan
if check_option(varargin,'killPlan')
  nfsoftmex('finalize',keepPlanNSOFT);
  keepPlanNSOFT = [];
  return
end

bw = get_option(varargin,'bandwidth', getMTEXpref('maxSO3Bandwidth'));


if isa(f,'function_handle')
  [SRight,SLeft] = extractSym(varargin);
  f = SO3FunHandle(f,SRight,SLeft);
end

try
  if f.antipodal
    f.antipodal = 0;
    varargin{end+1} = 'antipodal';
  end
end

% 1) compute/get weights and values for quadrature

if isa(f,'SO3Fun')
  
  SLeft = f.SLeft; SRight = f.SRight;

  % Use crystal and specimen symmetries by only evaluating at Clenshaw Curtis 
  % quadrature grid in fundamental region. 
  % Therefore adjust the bandwidth to crystal and specimen symmetry.
  bw = AdjustBandwidth(bw,SRight,SLeft);
  [values,nodes,W] = evalOnCCGridUseSymmetries(f,bw,SRight,SLeft);

else

  nodes = f(:);
  values = varargin{1}(:);
  W = get_option(varargin,'weights',1);
  W = W(:);

  if isa(nodes,'orientation')
    SRight = nodes.CS; SLeft = nodes.SS;
  else
    [SRight,SLeft] = extractSym(varargin);
    nodes = orientation(nodes,SRight,SLeft);
  end

  % Speed up for a high number of nodes, by transforming the nodes to an 
  % equispaced Clenshaw Curtis grid.
  if length(nodes)>1e7 && length(values) == length(nodes) && length(W)==1
    warning('There are to many input nodes. Thatswhy an inexact rounded quadrature is used.')
    [nodes,values] = Round2equispacedGrid(nodes,values,bw,SRight,SLeft);
  end
 
end


if isempty(nodes)
  SO3F = SO3FunHarmonic(0,SRight,SLeft);
  return
end


% 2) Inverse NFSOFT

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlanNSOFT;
else
  plan = [];
end

% initialize nfsoft
if isempty(plan)
  
  % 2^4 -> nfsoft-represent
  % 2^2 -> nfsoft-use-DPT
  % 2^0 -> use normalized Wigner-D functions and fourier coefficients
  nfsoft_flags = bitor(2^4,2^0)+2^2;
  % nfft cutoff - 4
  % fpt kappa - 1000
  % fftw_size -> 2*ceil(1.5*L)
  % initialize nfsoft plan
  plan = nfsoftmex('init',bw,length(nodes),nfsoft_flags,0,4,1000,2*ceil(1.5*bw));
  
  % set rotations in Euler angles (nodes)
  nfsoftmex('set_x',plan,Euler(nodes,'nfft').');
  
  % node-dependent precomputation
  nfsoftmex('precompute',plan);

end

if check_option(varargin,'createPlan')
  keepPlanNSOFT = plan;
  return
end

s = size(values);
values = reshape(values, length(nodes), []);
num = size(values, 2);

fhat = zeros(deg2dim(bw+1), num);
for index = 1:num
  % adjoint nfsoft

  values(isnan(values)) = 0;

  nfsoftmex('set_f', plan, W(:) .* values(:, index));
  nfsoftmex('adjoint', plan);
  % get fourier coefficients from plan and normalize
  fhat(:, index) = nfsoftmex('get_f_hat', plan)*(sqrt(8)*pi);
end

% kill plan
if check_option(varargin,'keepPlan')
  keepPlanNSOFT = plan;
else
  nfsoftmex('finalize', plan);
end


% maybe we have a multivariate function
try
  fhat = reshape(fhat, [deg2dim(bw+1) s(2:end)]);
end

SO3F = SO3FunHarmonic(fhat,SRight,SLeft);
SO3F.bandwidth = bw;

% if antipodal consider only even coefficients
SO3F.antipodal = check_option(varargin,'antipodal');

end





% --------------------------- functions -----------------------------------

function bw = AdjustBandwidth(bw,SRight,SLeft)
  t1=1; t2=2; 
  if SRight.multiplicityPerpZ==1 || SLeft.multiplicityPerpZ==1, t2=1; end
  if SLeft.id==22,  t2=4; end     % 2 | (N+1)
  if SRight.id==22, t1=4; end     % 2 | (N+1)
  while (mod(2*bw+2,SRight.multiplicityZ*t1) ~= 0 || mod(2*bw+2,SLeft.multiplicityZ*t2) ~= 0)
    bw = bw+1;
  end
end


function [nodes,values] = Round2equispacedGrid(nodes,values,bw,SRight,SLeft)

  % Use crystal and specimen symmetries by only evaluating in fundamental
  % region. Therefore adjust the bandwidth to crystal and specimen symmetry.
  bw = AdjustBandwidth(bw,SRight,SLeft);

  grid_nodes = quadratureSO3Grid(2*bw,'ClenshawCurtis',SRight,SLeft);
  % in some special cases we need to evaluate the function handle in additional nodes
  if SRight.multiplicityPerpZ~=1 && SLeft.multiplicityPerpZ~=1
    warning('off')
    if (SLeft.id==19 && mod(N+1,2)==0) || (SLeft.id==22 && mod(N+1,12)==0) || (SLeft.id~=19 && SLeft.id~=22)
      grid_nodes = cat(3,grid_nodes,rotation.byEuler(pi/(bw+1),0,0).*grid_nodes(:,:,end));
    end
    warning('on')
  end
  [a,b,c] = nodes.project2EulerFR('nfft');
  ori = [a,b,c];

  I = zeros(length(values),3);
  I(:,2) = round(ori(:,2).*(2*bw/pi));

  % work on cases beta = 0 or pi
  ind_beta0 = I(:,2)==0;
  ind_betapi = I(:,2)==2*bw;
  ori(ind_beta0,1) = mod(ori(ind_beta0,1) + ori(ind_beta0,3),2*pi);
  ori(ind_beta0,3) = 0;
  ori(ind_betapi,1) = mod(ori(ind_betapi,1) - ori(ind_betapi,3),2*pi);
  ori(ind_betapi,3) = 0;

  % get 1st and 3rd Euler angles
  I(:,[1,3]) = round(ori(:,[1,3])*((bw+1)/pi));
  I(:,[1,3]) = mod(I(:,[1,3]),(2*bw+2)./[SLeft.multiplicityZ,SRight.multiplicityZ]);

  % get grid indices
  ind = I * [size(grid_nodes,1)*size(grid_nodes,2); size(grid_nodes,1); 1] + 1;

  % add grid values with same indices
  grid_values = zeros(size(grid_nodes));
  B = accumarray(ind,values);
  grid_values(1:length(B)) = B;

  % set the equivalent nodes for beta=0 /pi
  grid_values(:,1,:) = repmat(hankel(grid_values(:,1,1),circshift(grid_values(:,1,1),1)),SLeft.multiplicityZ,SRight.multiplicityZ);
  if size(grid_values,2)==2*bw+1
    grid_values(:,end,:) = toeplitz(grid_values(:,end,1),circshift(flip(grid_values(:,end,1)),1));
  end
  nodes = grid_nodes(grid_values~=0);
  values = grid_values(grid_values~=0);


% Alternatively split the values to all neigborhood nodes weighted by the distance
% TODO: Special cases beta = 0 , pi/(2N) , pi*(1-1/(2N)) , pi do not work yet.
%   bw=71;
%   grid_nodes = quadratureSO3Grid(2*bw,'ClenshawCurtis',SRight,SLeft);
%   % in some special cases we need to evaluate the function handle in additional nodes
%   if SRight.multiplicityPerpZ~=1 && SLeft.multiplicityPerpZ~=1
%     warning('off')
%     if (SLeft.id==19 && mod(N+1,2)==0) || (SLeft.id==22 && mod(N+1,12)==0) || (SLeft.id~=19 && SLeft.id~=22)
%       grid_nodes = cat(3,grid_nodes,rotation.byEuler(pi/(bw+1),0,0).*grid_nodes(:,:,end));
%     end
%     warning('on')
%   end
%   [a,b,c] = nodes.project2EulerFR('nfft');
%   ori = [a,b,c];
%     
%   I = permute(floor(ori.*[bw+1,2*bw,bw+1]/pi),[1,3,2]) ...
%       + permute([0,0,0;0,0,1;0,1,0;0,1,1;1,0,0;1,0,1;1,1,0;1,1,1],[3,1,2]);
% 
%   I(:,[1,3]) = mod(I(:,[1,3]),(2*bw+2)./[SLeft.multiplicityZ,SRight.multiplicityZ]);
%   ind = sum(I .* permute([size(grid_nodes,1)*size(grid_nodes,2); size(grid_nodes,1); 1],[2,3,1]),3) + 1;
% 
%   grid_values = zeros(size(grid_nodes));
% 
%   % get the neighbor grid nodes for every single node
%   d = nan(length(values),8);
%   for m=1:8
%     if m==1 || m==3 || m==7
%       ZZZ = ~isnan(ind(:,m));
%     end
%     d(ZZZ,m) = angle(grid_nodes(ind(ZZZ,m)),nodes(ZZZ));
%   end
%   d = 1./d;
%   v = d.*(values./sum(d,2,'omitnan'));
% 
%   B = accumarray(id,v);
%   grid_values(1:length(B)) = B;
% 
%   nodes = grid_nodes(grid_values~=0);
%   values = grid_values(grid_values~=0);

end