function odf = smooth(odf,varargin)
% smooth ODF
%
%% Input
%  odf - @ODF
%  res - resolution
%
%% Output
%  odf - smoothed @ODF
%
%% See also
% loadEBSD_generic, SO3Grid/smooth

if nargin >= 2 && isa(varargin{1},'kernel')
  psi = varargin{1};
else
  psi = kernel('de la Vallee Poussin','halfwidth',...
    get_option(varargin,'halfwidth',5*degree));
end
hw = get(psi,'halfwidth');

for iodf = 1:length(odf)
  
  %% Uniform portion
  if check_option(odf(iodf),'uniform')
  
  
  %% Fourier portion
  elseif check_option(odf(iodf),'Fourier')
    
    A = get(psi,'A');
    L = min(bandwidth(odf),find(A,1,'last')-1);

    odf(iodf).c_hat=odf(iodf).c_hat(1:deg2dim(L+1));
    for l = 0:L
      odf(iodf).c_hat(deg2dim(l)+1:deg2dim(l+1)) = odf(iodf).c_hat(deg2dim(l)+1:deg2dim(l+1)) * A(l+1);
    end
    
  elseif check_option(odf(iodf),'fibre')
    
  %% unimodal portion
  else
    
    % generate grid
    S3G = SO3Grid(hw,odf(1).CS,odf(1).SS);
    
    % restrict single orientations to this grid

    % init variables
    g = quaternion(odf(iodf).center);
    d = zeros(1,numel(S3G));

    % iterate due to memory restrictions?
    maxiter = ceil(length(odf(1).CS)*length(odf(1).SS)*numel(g) /...
      get_mtex_option('memory',300 * 1024));
    if maxiter > 1, progress(0,maxiter);end

    for iter = 1:maxiter
   
      if maxiter > 1, progress(iter,maxiter); end
   
      dind = ceil(numel(g) / maxiter);
      sind = 1+(iter-1)*dind:min(numel(g),iter*dind);
      
      ind = find(S3G,g(sind));
      for i = 1:length(ind)
        d(ind(i)) = d(ind(i)) + odf(iodf).c(sind(i));
      end

    end
    d = d ./ sum(odf(iodf).c);
    
    % eliminate spare rotations in grid
    S3G = subGrid(S3G,d ~= 0);
    d = d(d~=0);

    odf(iodf).center = S3G;
    odf(iodf).c = d;
    psi_old = odf(iodf).psi;
    odf(iodf).psi = kernel(get(psi_old,'name'),'halfwidth',hw + get(psi_old,'halfwidth'));
        
  end  
end
