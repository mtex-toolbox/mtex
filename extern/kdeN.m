function [pdf,X1,X2] = kdeN(X,grid,gam,varargin)
%% adaptive kernel density estimation in high dimensions;
%  optimal accuracy/speed tradeoff, controlled via parameter "gam";
% INPUTS:   X  - data as a 'n' by 'd' vector;
%
%         grid - 'm' points of dimension 'd' over which pdf is computed;
%                default provided only for 2-dimensional data;
%                see example on how to construct it in higher dimensions
%
%          gam - cost/accuracy tradeoff parameter, where gam<n;
%                default value is gam=ceil(n^(1/2)); larger values
%                may result in better accuracy, but always reduce speed;
%                to speedup the code, reduce the value of "gam"; 
%
% OUTPUT: pdf   - the value of the estimated density at 'grid'
%         X1,X2 - grid only for 2 dimensional data
%
%%  EXAMPLE in 2 dimensions:
%   L=chol([1,-0.999;-0.999,1],'lower');L1=chol([1,0.999;0.999,1],'lower');
%   data=[(L1*randn(10^3,2)')';(L*randn(10^3,2)')'*2;rand(10^4,2)*5-2.5];
%   [pdf,X1,X2]=akde(data);pdf=reshape(pdf,size(X1));contour(X1,X2,pdf,20)
%
%%  EXAMPLE in 3 dimensions:
%  data=[randn(10^3,3);randn(10^3,3)/2+2]; % three dimensional data
%  [n,d]=size(data); ng=100; % total grid points = ng^d
%  MAX=max(data,[],1); MIN=min(data,[],1); scaling=MAX-MIN;
%  % create meshgrid in 3-dimensions
%  [X1,X2,X3]=meshgrid(MIN(1):scaling(1)/(ng-1):MAX(1),...
%      MIN(2):scaling(2)/(ng-1):MAX(2),MIN(3):scaling(3)/(ng-1):MAX(3));
%  grid=reshape([X1(:),X2(:),X3(:)],ng^d,d); % create points for plotting
%  pdf=akde(data,grid); % run adaptive kde
%  pdf=reshape(pdf,size(X1)); % reshape pdf for use with meshgrid
%  for iso=[0.005:0.005:0.015] % isosurfaces with pdf = 0.005,0.01,0.015
%      isosurface(X1,X2,X3,pdf,iso),view(3),alpha(.3),box on,hold on
%      colormap cool
%  end
%
%%  Reference:
%  Kernel density estimation via diffusion
%  Z. I. Botev, J. F. Grotowski, and D. P. Kroese (2010)
%  Annals of Statistics, Volume 38, Number 5, pages 2916-2957.

% remove nan lines
id = ~any(isnan(X),2);
X = X(id,:);

[n,d]=size(X);
% begin scaling preprocessing
MAX=max(X,[],1);MIN=min(X,[],1);scaling=MAX-MIN;
MAX=MAX+scaling/10;MIN=MIN-scaling/10;scaling=MAX-MIN;
X=bsxfun(@minus,X,MIN);X=bsxfun(@rdivide,X,scaling);
if (nargin<2)|isempty(grid) % failing to provide grid
    warning('Assuming data is 2 dimensional. For higher dimensions, provide a grid as in example.')
    % create meshgrid in 2-dimensions
    [X1,X2]=meshgrid(MIN(1):scaling(1)/(2^7-1):MAX(1),...
           MIN(2):scaling(2)/(2^7-1):MAX(2));
    grid=reshape([X1(:),X2(:)],2^14,d); % create grid for plotting
end
mesh=bsxfun(@minus,grid,MIN);mesh=bsxfun(@rdivide,mesh,scaling);
if nargin<3 % failing to provide speed/accuracy tradeoff
    gam=ceil(n^(1/2));
end
% end preprocessing
% algorithm initialization
del=.1/n^(d/(d+4));perm=randperm(n);mu=X(perm(1:gam),:);w=rand(1,gam);
w=w/sum(w);Sig=bsxfun(@times,rand(d,d,gam),eye(d)*del);ent=-Inf;
for iter=1:1500 % begin algorithm
    Eold=ent;
    [w,mu,Sig,del,ent]=regEM(w,mu,Sig,del,X); % update parameters
    err=abs((ent-Eold)/ent); % stopping condition
    if check_option(varargin,'verbose')
      fprintf('Iter.    Tol.      Bandwidth \n');
      fprintf('%4i    %8.2e   %8.2e\n',iter,err,del);
      fprintf('----------------------------\n');
    end
    if (err<10^-4)||(iter>200), break, end
end
% now output density values at grid
pdf = probfun(mesh,w,mu,Sig)/prod(scaling); % evaluate density
del=del*scaling; % adjust bandwidth for scaling

try
  pdf = reshape(pdf,size(X1));
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pdf=probfun(x,w,mu,Sig)
[gam,d]=size(mu);
pdf=0;
for k=1:gam
    L=chol(Sig(:,:,k));s=diag(L);
    logpdf=-.5*sum(( bsxfun(@minus,x,mu(k,:))/L).^2,2)+log(w(k))...
        -sum(log(s))-d*log(2*pi)/2;
    pdf=pdf+exp(logpdf);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [w,mu,Sig,del,ent]=regEM(w,mu,Sig,del,X)
[gam,d]=size(mu);[n,d]=size(X);
log_lh=zeros(n,gam); log_sig=log_lh; 
for i=1:gam
    L=chol(Sig(:,:,i));
    Xcentered = bsxfun(@minus, X, mu(i,:));
    xRinv = Xcentered /L; xSig = sum((xRinv /L').^2,2)+eps;
    log_lh(:,i)=-.5*sum(xRinv.^2, 2)-sum(log(diag(L)))...
        +log(w(i))-d*log(2*pi)/2-.5*del^2*trace((eye(d)/L)/L');
    log_sig(:,i)=log_lh(:,i)+log(xSig);
end
maxll = max (log_lh,[],2); maxlsig = max (log_sig,[],2);
p= exp(bsxfun(@minus, log_lh, maxll));
psig=exp(bsxfun(@minus, log_sig, maxlsig));
density = sum(p,2);  psigd=sum(psig,2);
logpdf=log(density)+maxll; logpsigd=log(psigd)+maxlsig;
p = bsxfun(@rdivide, p, density);
ent=sum(logpdf); w=sum(p,1);
for i=find(w>0)
    mu(i,:)=p(:,i)'*X/w(i);  %compute mu's
    Xcentered = bsxfun(@minus, X,mu(i,:));
    Xcentered = bsxfun(@times,sqrt(p(:,i)),Xcentered);
    Sig(:,:,i)=Xcentered'*Xcentered/w(i)+del^2*eye(d); % compute sigmas;
end
w=w/sum(w);curv=mean(exp(logpsigd-logpdf)); % estimate curvature
del=1/(4*n*(4*pi)^(d/2)*curv)^(1/(d+2));
end