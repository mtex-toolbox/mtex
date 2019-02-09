function cg = sphericalClebschGordan(l,L,varargin)

% use global wigner3j
global w3j;

% compute Wigner3j (l,l,L,0,0,0) and ensure its precomputed
w3j000 = (2*L + 1) * Wigner3jPrecomputed(l,L,0,0);

cg = w3j000 * w3j{1+l}(:,:,L+1);

A = correctionMatrix(l);
cg = cg .* A;

end

function A = correctionMatrix(l)

global cMatrix;

try
  A = cMatrix{l+1};
  assert(size(A,1)==2*l+1);
  return
end

% correction matrix
A = zeros(2*l+1,2*l+1);
[x,y] = find(~A);
A(x+y>=2*l+2 & x <=l+1 & rem(x-l-1,2)) =1;
A = or(A,A');
A = or(A,fliplr(fliplr(A)'));
A = 1 - 2*A;

% multiply by (-1)^(m1+m2)
A(2:2:end) = -A(2:2:end);

cMatrix{l+1} = A;

end


%% testing code:

function test

% compute products of spherical harmonics
% for a certain position 
theta = 45*degree;
rho = 10*degree;
v = vector3d.byPolar(theta,rho)
l = 30;

Y = sphericalY(l,v);

YYref = Y.'* Y;

%% 


YY = zeros(size(YYref));

for L = 0:2*l
  
  %cg = sphericalClebschGordan(l,L,'plusConvention');
  cg = sphericalClebschGordan(l,L);
  cg = (2*l+1) ./ sqrt(4*pi*(2*L+1)) * cg;
  Y = repmat(sphericalY(L,v),2*l+1,1);
  
  % generate the matrix Y_l^(k+k')
  DY = flipud(full(spdiags(Y,-L:L,2*l+1,2*l+1)));
  
  YY = YY + cg .* DY;
end

er = max(abs(YYref(:)-YY(:)))./max(abs(YYref(:)));

assert(er<1e-10,['Error was: ',num2str(er)]);

disp('Everything ist ok')

%%
end
