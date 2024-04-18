function [SO3F,resvec] = interpolate(ori,values,varargin)
% compute an ODF by interpolating orientations and weights
%
% Syntax
%   odf = SO3Fun.interpolate(ori,values)
%
% Input
%  ori - @orientation
%  values - double
%
% Flags
%  lsqr      - least squares (MATLAB)
%  lsqnonneg - non negative least squares (MATLAB, fast)
%  lsqlin    - interior point non negative least squares (optimization toolbox, slow)
%  nnls      - non negative least squares (W.Whiten)
% 
% Output
%  SO3F - @SO3FunRBF
%

if length(ori) ~= numel(values)
  error('Interpolation is only possible for univariate functions.')
end

if ~isa(ori,'orientation') % preserve SO3Grid structure
  ori = orientation(ori);
end

% construct the uniform portion first
values = values(:);
m = min(values);
values = values - m;

SO3F = m * uniformODF(ori.CS,ori.SS);

% grid for representing the ODF
res = get_option(varargin,'resolution',5*degree);

if check_option(varargin,'exact')
  S3G = ori;
else
  S3G = equispacedSO3Grid(ori.CS,ori.SS,'resolution',res);
end

% kernel for representing the ODF
psi = get_option(varargin,'kernel',SO3DeLaValleePoussinKernel('halfwidth',res));


% system matrix
if check_option(varargin,'exact') 
  epsilon = pi; 
else 
  epsilon = min(pi,get_option(varargin,'epsilon',psi.halfwidth*3.5)); 
end
if epsilon>2*pi/ori.CS.Laue.multiplicityZ % compute full matrix
  M = psi.K_symmetrised(S3G,ori,ori.CS,ori.SS);
else % compute sparse matrix
  M = splitSummationMatrix(psi,S3G,ori);
end


switch get_flag(varargin,{'lsqr','lsqlin','lsqnonneg','nnls'},'lsqr')

  case 'lsqlin'

    tolCon = get_option(varargin,'lsqlin_tolCon',1e-10);
    tolX = get_option(varargin,'lsqlin_tolX',1e-14);
    tolFun = get_option(varargin,'lsqlin_tolFun',1e-10);
  
    options = optimoptions('lsqlin','Algorithm','interior-point',...
      'Display','iter','TolCon',tolCon,'TolX',tolX,'TolFun',tolFun);
  
    n2 = size(M,1);
  
    w = lsqlin(M',values,-eye(n2,n2),zeros(n2,1),[],[],[],[],[],options);
  
  case 'nnls'
    
    w = nnls(full(M).',values,struct('Iter',1000));        
    
  case 'lsqnonneg'
    
    w = lsqnonneg(M',values);
    
  case 'lsqr'

    tol = get_option(varargin,'tol',1e-2);
    iters = get_option(varargin,'iters',30);
    [w,flag,~,~,resvec] = lsqr(M',values,tol,iters);
  
    %In case a user wants the best possible tolerence, just keep increasing
    %tolerance
    cnt=0;
    while flag > 0
      tol = tol*1.3;
      disp(['   lsqr tolerance cut back: ',xnum2str(max(tol))])
      [w,flag,~,~,resvec] = lsqr(M',values,tol,50);
      cnt=cnt+1;
      if cnt > 5
        disp('   more than 5 lsqr tolerance cut backs')
        disp('   consider using a larger tolerance')
        break
      end
    end
end
%norm(M' * w - values) ./ norm(values)

if check_option(varargin,'ODFstats')
 err = abs(M'*w - values);
 disp(['   Minimum weight: ',xnum2str(min(w))]);
 disp(['   Maximum weight:  : ',xnum2str(max(w))]);
 disp(['   Maximum error during interpolating ODF: ',xnum2str(max(err))]);
 disp(['   Mean error during interpolating ODF   : ',xnum2str(mean(err))]);
end

SO3F = SO3F + sum(w).*unimodalODF(S3G,psi,'weights',w./sum(w));

% ensure normalization to 1 if we are sufficiently close to 1
if abs(sum(SO3F.weights)-1)<0.1
  SO3F.weights = SO3F.weights ./ sum(SO3F.weights);
end

end





function M = splitSummationMatrix(psi,S3G,ori,varargin)

% decide along which dimension to split the summation matrix
if isa(S3G,'SO3Grid')
  lg1 = length(S3G); 
else
  lg1 = -length(S3G);
end
if isa(ori,'SO3Grid')
  lg2 = length(ori);
else
  lg2 = -length(ori);
end

along = (lg1 > lg2 && lg1 > 0) || (abs(lg1) > abs(lg2) && lg2 < 0);
if along
  num = abs(lg2);
else
  num = abs(lg1);
end

% init variables
iter = 0; numiter = 1; ind = 1; %for first run
M = sparse(abs(lg1),abs(lg2));

% now iterate along the splitting
while iter <= numiter
  if iter > 0% split
    ind = 1 + (1+(iter-1)*diter:min(num-1,iter*diter));
    if isempty(ind), return; end
  end

  %eval the kernel
  if along
    m = psi.K_symmetrised(S3G,ori(ind),ori.CS,ori.SS,varargin{:});
    M(:,ind) = M(:,ind) + m;
  else
    m = psi.K_symmetrised(S3G(ind),ori,ori.CS,ori.SS,varargin{:});
    M(ind,:) = M(ind,:) + m;
  end

  if num == 1
    return
  elseif iter == 0 % iterate due to memory restrictions?
    numiter = ceil( max(1,nnz(M))*num / getMTEXpref('memory',512 * 1024) / 256 );
    diter = ceil(num / numiter);
  end

  if numiter > 1 && ~check_option(varargin,'silent'), progress(iter,numiter); end

  iter = iter + 1;
end

end