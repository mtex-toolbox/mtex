function f = eval(odf,g,varargin)
% evaluate an odf at quaternions g
%
%
%% Input
%  odf - @ODF
%  g   - @quaternion or @SO3Grid
%
%% Flags
%  DISTMATRIX - use precomputed distmatrix in @SO3Grid g if exists
%  EVEN       - calculate even portion only
%
%% Output
%  f   - values of the ODF at the orientations g
%

gg = quaternion(g);

f = zeros(size(gg));

for i = 1:length(odf)
  
  if check_option(odf(i),'UNIFORM') % uniform portion
    
    f = f + odf(i).c;
  
  elseif check_option(varargin,'FOURIER')
    
    f = f + eval_fourier(odf(i),gg,varargin{:});
    
  elseif check_option(odf(i),'FIBRE') % fibre symmetric portion
     
    f = f + reshape(RK(odf(i).psi,reshape(gg,[],1),...
      vector3d(odf(i).center{1}),odf(i).center{2},...
      odf(i).c,odf(i).CS,odf(i).SS,1),size(f));
    
  elseif check_option(varargin,'DISTMATRIX') % use precalculated distmatrix
    
    evalmatrix = K(odf(i).psi,g,[],odf(i).CS,odf(i).SS);
    f = f + evalmatrix * odf(i).c(:);
    
  elseif check_option(varargin,'EVEN')
    
    M = GK(odf(i).psi,reshape(gg,[],1),...
      quaternion(odf(i).center),odf(i).CS,odf(i).SS);
    f = f + M * odf(i).c(:);
       
  else % radially symmetric portion
      
    gg  = reshape(gg,[],1);
    lg = length(gg);
    
    ind = 1:numel(odf(i).c);
    ges = length(ind) * lg;
    maxiter = ceil(ges / 1000000);
    dc = ceil(length(ind) / maxiter);
    if maxiter > 1, progress(0,maxiter);end
    
    for iter = 1:maxiter
      if maxiter > 1, progress(iter,maxiter); end
      
      iind = ind(1+(iter-1)*dc:min(length(ind),iter*dc));
      q = quaternion(odf(i).center,iind);
      M = K(odf(i).psi,gg,q,odf(i).CS,odf(i).SS,varargin{:});
      f = f + reshape(M * reshape(odf(i).c(iind),[],1),size(f));
    end
    
  end
end
