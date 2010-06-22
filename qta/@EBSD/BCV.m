function [psi,c] = BCV(ebsd,varargin)
% Least squares cross valiadation

%%

o = get(ebsd,'orientations');
N = length(o);


%% kernel based approach

%
psi = kernel('de la Vallee Poussin','halfwidth',10*degree);
sob = kernel('Sobolev',1,'bandwidth',64);
psi = psi * sob^(0.5);

% set up matrix
k = K(psi,o,o,get(o,'CS'),get(o,'SS'));

% remove diagonal
n = 1:N;
k((n-1).*N + n) = [];

sn = sqrt(sum(k))./N;

%% compute Fourier coefficients
L = 32;
odf_d = calcODF(ebsd,'kernel',kernel('Dirichlet',L),'Fourier','L',L,'silent');


%% compute Sobolev Norm
psi = kernel('Sobolev',1,'bandwidth',32);
eodf = conv(odf_d,psi);
sn = 2*sum(eval(eodf,o)) - eval(psi,0); %#ok<EVLC>
