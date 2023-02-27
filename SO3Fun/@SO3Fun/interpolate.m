function [SO3F,resvec] = interpolate(ori,values,varargin)
% compute an ODF by interpolating orientations and weights
%
% Syntax
%
%   odf = SO3Fun.interpolate(ori,values)
%
% Input
%  ori - @orientation
%  values - double
%
% Flags
%  lsqr      - least squares (Matlab)
%  lsqnonneg - non negative least squares (Matlab, fast)
%  lsqlin    - interior point non negative least squares (optimization toolbox, slow)
%  nnls      - non negative least squares (W.Whiten)
% 
% 
% Output
%  SO3F - @SO3Fun
%

if length(ori) ~= numel(values)
  error('Interpolation is only possible for univariate functions.')
end

ori = orientation(ori);

% construct the uniform portion first
values = values(:);
m = min(values);
values = values - m;

SO3F = m * uniformODF(ori.CS,ori.SS);

% grid for representing the ODF
res = get_option(varargin,'resolution',5*degree);

if check_option(varargin,'exact')
  S3G=ori;
else
  S3G = equispacedSO3Grid(ori.CS,ori.SS,'resolution',res);
end

% kernel for representing the ODF
psi = get_option(varargin,'kernel',SO3DeLaValleePoussinKernel('halfwidth',res));

% system matrix
M = psi.K_symmetrised(S3G,ori,ori.CS,ori.SS);


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