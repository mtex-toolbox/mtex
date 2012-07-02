function cg = sphericalClebschGordan(l,L)

%% maybe the tensors are stored in a global variable
global sphericalCG;

try
  cg = sphericalCG{l+1,L+1};
  assert(~isempty(cg));
  return;
catch
end

%% maybe the tensors are stored in a file
fname1 = [mtexDataPath '/ClebschGordan.mat'];
if exist(fname1,'file') && isempty(sphericalCG)
  load(fname1,'sphericalCG');  
  try
    cg = sphericalCG{l+1,L+1};
    assert(~isempty(cg));
    return  
  catch
  end  
end

%% calculate values myself
% correction matrix
A = zeros(2*l+1,2*l+1);
[x,y] = find(~A);
A(x+y>=2*l+2 & x <=l+1 & rem(x-l-1,2)) =1;
A = or(A,A');
A = or(A,fliplr(fliplr(A)'));
A = 1 - 2*A;

% compute Wigner3j (l,l,L,0,0,0)
w3j000 = (2*L + 1) * Wigner3jPrecomputed(l,L,0,0);

% compute Clebsch Gordan coefficients
cg = zeros(2*l+1,2*l+1);
for m1 = -l:l
  for m2 = -l:l
    
    % Wigner3j([l,l,L],[m1,m2,-m1-m2])
    w3jm1m2 = Wigner3jPrecomputed(l,L,m1,m2);
    cg(l+1+m1,l+1+m2)...
      = (-1)^(m1+m2) * w3j000 * A(l+1+m1,l+1+m2) * w3jm1m2;
  end
end

% % compute Wigner3j (l,l,L,0,0,0)
% w3j000 = (2*L + 1) * Wigner3j([l,l,L],[0,0,0]);
% 
% % compute Clebsch Gordan coefficients
% cg = zeros(2*l+1,2*l+1);
% for m1 = -l:l
%   for m2 = -l:l
%     
%     % Wigner3j([l,l,L],[m1,m2,-m1-m2])
%     w3jm1m2 = Wigner3j([l,l,L],[m1,m2,-m1-m2]);
%     cg(l+1+m1,l+1+m2)...
%       = (-1)^(m1+m2) * w3j000 * A(l+1+m1,l+1+m2) * w3jm1m2;
%   end
% end

cg = flipud(cg);

%save(fname,'cg');
sphericalCG{l+1,L+1} = cg;
%save(fname1,'sphericalCG');

return

%% testin code:

% compute products of spherical harmonics
% for a certain position 
theta = 15*degree;
rho = 10*degree;
l = 20;

Y = sphericalY(l,theta,rho);

YYref = Y' * Y;
%YYref = Y.' * Y;

%% 


YY = zeros(size(YYref));

for L = 0:2*l
  
  cg = (2*l+1) ./ sqrt(4*pi*(2*L+1)) * sphericalClebschGordan(l,L);
  Y = repmat(sphericalY(L,theta,rho),2*l+1,1);
  
  DY = full(spdiags(Y,-L:L,2*l+1,2*l+1));
  
  YY = YY + cg .* DY;
  
end

er = max(abs(YYref(:)-YY(:)))./max(abs(YYref(:)));

assert(er<1e-10,['Error was: ',num2str(er)]);
disp('Everythink is ok!')

%%

