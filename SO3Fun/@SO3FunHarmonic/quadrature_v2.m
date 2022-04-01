function SO3F = quadrature_v2(f, varargin)
%
% Syntax
%   SO3F = SO3FunHarmonic.quadrature_v2(nodes,values,'weights',w)
%   SO3F = SO3FunHarmonic.quadrature_v2(f)
%   SO3F = SO3FunHarmonic.quadrature_v2(f, 'bandwidth', bandwidth)
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
%  bandwidth      - minimal harmonic degree (default: 64)
%  ClenshawCurtis - use Clenshaw Curtis quadrature nodes and weights
%

persistent keepPlanNFFT;

% kill plan
if check_option(varargin,'killPlan')
  nfftmex('finalize',keepPlanNFFT);
  keepPlanNFFT = [];
  return
end

bw = get_option(varargin,'bandwidth', getMTEXpref('maxSO3Bandwidth'));


% 1) compute/get weights and values for quadrature

[SRight,SLeft] = extractSym(varargin);
if isa(f,'SO3Fun')
  SLeft = f.SLeft; SRight = f.SRight;
  f = @(v) f.eval(v);
end

if isa(f,'function_handle')
  if check_option(varargin,'gauss')
    % possilbly use symmetries and evaluate in fundamental region
    [nodes, W] = quadratureSO3Grid(2*bw,'gauss',SRight,SLeft,'complete');
    values = f(nodes(:));
  else
% TODO: Usage of symmetries only implemented for SRight = crystalSymmetry('1') and 
% SLeft = specimenSymmetry('1') with default symmetries 1, 2, 3, 4, 6, 112, 222, 422, 622, 23, 423, 312, 321
% others are not tested yet
    if SRight.id~=1 || SLeft.id~=1
      % Use crystal and specimen symmetries by only evaluating in fundamental
      % region. Therefore adjust the bandwidth to crystal and specimen symmetry.
      t1=1; t2=2; 
      if SRight.multiplicityPerpZ==1 || SLeft.multiplicityPerpZ==1, t2=1; end
      if SLeft.id==22,  t2=4; end     % 2 | (N+1)
      if SRight.id==22, t1=4; end     % 2 | (N+1)
      while (mod(2*bw+2,SRight.multiplicityZ*t1) ~= 0 || mod(2*bw+2,SLeft.multiplicityZ*t2) ~= 0)
        bw = bw+1;
      end

      % evaluate function handle f at Clenshaw Curtis quadrature grid by
      % using crystal and specimen symmetry
      [values,nodes,W] = eval_onCCGrid_useSym(f,bw,SRight,SLeft);
    else
      % ignore symmetry by using 'complete' grid
      [nodes,W] = quadratureSO3Grid(2*bw,'ClenshawCurtis',SRight,SLeft,'complete');
      values = f(nodes(:));
    end
    varargin{end+1} = 'ClenshawCurtis';
  end

else
  nodes = f(:);
  values = varargin{1}(:);
  W = get_option(varargin,'weights',1);

  if isa(nodes,'orientation')
    SRight = nodes.CS; SLeft = nodes.SS;
  else
    [SRight,SLeft] = extractSym(varargin);
  end

  
  if length(nodes)>1e7 && length(values) == length(nodes) && length(W)==1
      
    % Use crystal and specimen symmetries by only evaluating in fundamental
    % region. Therefore adjust the bandwidth to crystal and specimen symmetry.
    t1=1; t2=2;
    if SRight.multiplicityPerpZ==1 || SLeft.multiplicityPerpZ==1, t2=1; end
    if SLeft.id==22,  t2=4; end     % 2 | (N+1)
    if SRight.id==22, t1=4; end     % 2 | (N+1)
    while (mod(2*bw+2,SRight.multiplicityZ*t1) ~= 0 || mod(2*bw+2,SLeft.multiplicityZ*t2) ~= 0)
      bw = bw+1;
    end

    grid_nodes = quadratureSO3Grid(2*bw,'ClenshawCurtis',SRight,SLeft);
    % in some special cases we need to evaluate the function handle in additional nodes
    if SRight.multiplicityPerpZ~=1 && SLeft.multiplicityPerpZ~=1
      warning('off')
      if (SS.id==19 && mod(N+1,2)==0) || (SS.id==22 && mod(N+1,12)==0) || (SS.id~=19 && SS.id~=22)
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
    nodes = grid_nodes;
    values = grid_values;


% Alternatively split the values to all neigborhood nodes weighted by the distance
% TODO: Special cases beta = 0 , pi/(2N) , pi*(1-1/(2N)) , pi do not work yet.
%     bw=71;
%     grid_nodes = quadratureSO3Grid(2*bw,'ClenshawCurtis',SRight,SLeft);
%     % in some special cases we need to evaluate the function handle in additional nodes
%     if SRight.multiplicityPerpZ~=1 && SLeft.multiplicityPerpZ~=1
%       warning('off')
%       if (SS.id==19 && mod(N+1,2)==0) || (SS.id==22 && mod(N+1,12)==0) || (SS.id~=19 && SS.id~=22)
%         grid_nodes = cat(3,grid_nodes,rotation.byEuler(pi/(bw+1),0,0).*grid_nodes(:,:,end));
%       end
%       warning('on')
%     end
%     [a,b,c] = nodes.project2EulerFR('nfft');
%     ori = [a,b,c];
%     
%     I = permute(floor(ori.*[bw+1,2*bw,bw+1]/pi),[1,3,2]) ...
%         + permute([0,0,0;0,0,1;0,1,0;0,1,1;1,0,0;1,0,1;1,1,0;1,1,1],[3,1,2]);
% 
%     I(:,[1,3]) = mod(I(:,[1,3]),(2*bw+2)./[SLeft.multiplicityZ,SRight.multiplicityZ]);
%     ind = sum(I .* permute([size(grid_nodes,1)*size(grid_nodes,2); size(grid_nodes,1); 1],[2,3,1]),3) + 1;
% 
%     grid_values = zeros(size(grid_nodes));
% 
%     % get the neighbor grid nodes for every single node
%     d = nan(length(values),8);
%     for m=1:8
%       if m==1 || m==3 || m==7
%         ZZZ = ~isnan(ind(:,m));
%       end
%       d(ZZZ,m) = angle(grid_nodes(ind(ZZZ,m)),nodes(ZZZ));
%     end
%     d = 1./d;
%     v = d.*(values./sum(d,2,'omitnan'));
% 
%     B = accumarray(id,v);
%     grid_values(1:length(B)) = B;
% 
%     nodes = grid_nodes(grid_values~=0);
%     values = grid_values(grid_values~=0);


    nodes.antipodal = f.antipodal;
    varargin{end+1} = 'ClenshawCurtis';
  end

end



if isempty(nodes)
  SO3F = SO3FunHarmonic(0,SRight,SLeft);
  return
end


% 2) Inverse trivariate NFFT/FFT and representation based wigner transform

% create plan
if check_option(varargin,'keepPlan')
  plan = keepPlanNFFT;
else
  plan = [];
end

% initialize nfft plan
if isempty(plan) && ~check_option(varargin,'ClenshawCurtis')

  %plan = nfftmex('init_3d',2*N+2,2*N+2,2*N+2,M);
  NN = 2*bw+2;
  FN = ceil(1.5*NN);
  % {FFTW_ESTIMATE} or 64 - Specifies that, instead of actual measurements of different algorithms, 
  %                         a simple heuristic is used to pick a (probably sub-optimal) plan quickly. 
  %                         It is the default value
  % {FFTW_MEASURE} or 0   - tells FFTW to find an optimized plan by actually computing several FFTs and 
  %                         measuring their execution time. This can take some time (often a few seconds).
  fftw_flag = int8(64);
  plan = nfftmex('init_guru',{3,NN,NN,NN,length(nodes),FN,FN,FN,4,int8(0),fftw_flag});

  % set rotations as nodes in plan
  nfftmex('set_x',plan,(Euler(nodes,'nfft').')/(2*pi));
  % node-dependent precomputation
  nfftmex('precompute_psi',plan);

end

s = size(values);
values = reshape(values, length(nodes), []);
num = size(values, 2);

fhat = zeros(deg2dim(bw+1), num);
for index = 1:num
  
  % use trivariate inverse equispaced fft in case of Clenshaw Curtis
  % quadrature grid and nfft otherwise 
  if check_option(varargin,'ClenshawCurtis')

    ghat = ifftn( W.* reshape(values(:, index),size(nodes)) ,[2*bw+2,4*bw,2*bw+2]);
    ghat = ifftshift(ghat);
    ghat = 16*bw*(bw+1)^2 * ghat(2:end,bw+1:3*bw+1,2:end);

  else
    
    % adjoint nfft
    nfftmex('set_f', plan, W(:) .* values(:, index));
    nfftmex('adjoint', plan);
    % adjoint fourier transform
    ghat = nfftmex('get_f_hat', plan);
    ghat = reshape(ghat,2*bw+2,2*bw+2,2*bw+2);
    ghat = ghat(2:end,2:end,2:end);

  end

  % shift rotational grid
  [~,k,l] = meshgrid(-bw:bw,-bw:bw,-bw:bw);
  ghat = (1i).^(l-k).*ghat;

  % set flags and symmetry axis
  flags = 2^0+2^4;  % use L2-normalized Wigner-D functions and symmetry properties
  % TODO: Probably use limit 1e-5 because this is precision m of nfft
  if sum(abs(imag(values(:,index)))) <= (1e-10)*sum(abs(real(values(:,index))))  % real valued
    flags = flags+2^2;
  end
  if check_option(varargin,'antipodal') || (isa(nodes,'orientation') && nodes.antipodal) % antipodal
    flags = flags+2^3;
  end
  sym = [min(SRight.multiplicityPerpZ,2),SRight.multiplicityZ,...
         min(SLeft.multiplicityPerpZ,2),SLeft.multiplicityZ];
  
  % use adjoint representation based coefficient transform
  % if random samples the symmetry properties do not fit
  if ~isa(f,'function_handle') && sym(1)+sym(3)~=2
    sym([1,3])=1;
  end
  fhat(:,index) = adjoint_representationbased_coefficient_transform(bw,ghat,flags,sym);
  fhat(:,index) = symmetrise_fouriercoefficients_aRBWT(fhat(:,index),flags,SRight,SLeft,sym);
%   fhat(:,index) = adjoint_representationbased_coefficient_transform_old(bw,ghat,flags);

end

% kill plan
if check_option(varargin,'keepPlan')
  keepPlanNFFT = plan;
elseif ~check_option(varargin, 'ClenshawCurtis')
  nfftmex('finalize', plan);
end

try
  fhat = reshape(fhat, [deg2dim(bw+1) s(2:end)]);
end

SO3F = SO3FunHarmonic(fhat,SRight,SLeft);
%SO3F.bandwidth = bw;
% if antipodal consider only even coefficients
SO3F.antipodal = check_option(varargin,'antipodal') || (isa(nodes,'orientation') && nodes.antipodal);

end
