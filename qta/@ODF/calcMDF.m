function mdf = calcMDF(odf1,varargin)
% calculate the uncorrelated misorientation distribution function (MDF) from one or two ODF
%
%% Syntax
% mdf = calcMDF(odf)
% mdf = calcMDF(odf1,odf2,'bandwidth',32)
%
%% Input
%  odf  - @ODF
%  odf1, odf2 - @ODF
%
%% Options
% bandwidth - bandwidth for Fourier coefficients (default -- 32)
%
%% Output
%  mdf - @ODF
%
%% See also
% EBSD/calcODF

%% check input

if nargin > 1 && isa(varargin{1},'ODF')
  odf2 = varargin{1};
else
  odf2 = odf1;
end
cs1 = get(odf1,'CS');
cs2 = get(odf2,'CS');

%% Kernel method
if check_option(varargin,'kernelMethod')


  center1 = get(odf1,'center');
  center2 = get(odf2,'center');
  psi1 = get(odf1,'psi');
  psi2 = get(odf2,'psi');
  c1 = get(odf1,'c');
  c2 = get(odf2,'c');

  center = inverse(center1) * center2.';
  c = c1 * c2.';
  psi = psi1 * psi2;

  % remove small values
  ind = c > 0.1/numel(c);
  c = c(ind);
  center = center(ind);


  % approximation
  if numel(c1)*numel(c2) > 10000

    warning('not yet fully implemented');
    res = get_option(varargin,'resolution',1.25*degree);
    S3G = SO3Grid(res,cs2,cs1);

    % init variables
    d = zeros(1,numel(S3G));

    % iterate due to memory restrictions?
    maxiter = ceil(length(cs1) * length(cs2) * numel(center) /...
      getMTEXpref('memory',300 * 1024));
    if maxiter > 1, progress(0,maxiter);end

    for iter = 1:maxiter

      if maxiter > 1, progress(iter,maxiter); end

      dind = ceil(numel(center) / maxiter);
      sind = 1+(iter-1)*dind:min(numel(center),iter*dind);

      ind = find(S3G,center(sind));
      for i = 1:length(ind) % TODO -> make it faster
        d(ind(i)) = d(ind(i)) + c(sind(i));
      end

    end
    d = d ./ sum(d(:));

    %% eliminate spare rotations in grid
    del = d ~= 0;
    center = subGrid(S3G,del);
    c = d(del);


  end

  mdf = ODF(center,c,psi,get(odf2,'CS'),get(odf1,'CS'));

  %% Fourier method
else
  % first ODF
  L = get_option(varargin,'bandwidth',32);
  odf1 = calcFourier(odf1,L);

  % extract Fourier coefficients
  odf1_hat = Fourier(odf1,'bandwidth',L);
  L = min(bandwidth(odf1),L);

  if nargin > 1 && isa(varargin{1},'ODF')
    odf2 = calcFourier(odf2,L);
    odf2_hat = Fourier(odf2,'bandwidth',L);
    L = min(bandwidth(odf2),L);
  else
    odf2_hat = odf1_hat;
  end

  % compute Fourier coefficients of mdf
  odf_hat = [odf1_hat(1)*odf2_hat(1);zeros(deg2dim(L+1)-1,1)];
  for l = 1:L
    ind = deg2dim(l)+1:deg2dim(l+1);
    odf_hat(ind) = reshape(odf1_hat(ind),2*l+1,2*l+1)' * reshape(odf2_hat(ind),2*l+1,2*l+1) ./ (2*l+1);
  end

  % construct mdf
  mdf = FourierODF(odf_hat,get(odf2,'CS'),get(odf1,'CS'));

end
