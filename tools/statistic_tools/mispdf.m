function mispdf(o)
% random misorientation and kernel density estimated
%
%% Input
%  o  - @orientation | @ebsd | @cs
%
%% Reference
% A. Morawiec - Misorientation-Angle Distribution of Randomly Oriented
% Symmetric Objects
%
%% 

if isa(o,'ebsd') || isa(o,'orientation')
  if isa(o,'ebsd')
    o = get(o,'orientations');   
  end
  CS = get(o,'CS');
  
  %% kernel density ?
  [a omegas] = project2FundamentalRegion(o);
  
  %gaussian kernel
  k = @(t) 1./sqrt(2*pi) .* exp(-1/2.*t.^2);
  
  nn = length(omegas);
  
    
  h = 1*degree; % bandwidth

  nodes = 0:h/5:max_cs(CS);
  pf = zeros(size(nodes));
  
  for l=1:length(nodes)
    t = nodes(l)-omegas;
    pf(l) =  sum( k(  t(abs(t) < h*5)./h ) );     
  end
  pf = pf./trapz(nodes/degree,pf);

  hold on
  plot(nodes/degree,pf,'b')
else
  CS = o;
end



%% S functions

S1 = @(alpha) 2*pi.*(1-cos(alpha));

C = @(alpha, beta, gamma) acos( (cos(gamma)- cos(alpha).*cos(beta))./(sin(alpha).*sin(beta)) );

S2 = @(alpha, beta, gamma) 2*(pi - C(alpha,beta,gamma) - ...
    cos(alpha).* C(gamma, alpha, beta) - cos(beta).* C(beta,gamma,alpha));

%%
if strcmp(Laue(CS),'m-3m') % octahedral O
    n=1;

    h4 = 2^(1/2)-1;
    h3 = 3^(1/2)/3;

    alpha1 = @(r) acos( h4./r );
    alpha2 = @(r) acos( h3./r);

    delta1 = pi/2;
    delta2 = acos(h3);

    chi1 = @(r) 4*pi*ones(size(r));
    chi2 = @(r) chi1(r) - 6*S1( alpha1(r) );
    chi3 = @(r) chi2(r) - 8*S1( alpha2(r) );
    chi4 = @(r) chi3(r) + 12*S2( alpha1(r), alpha1(r), delta1 ) ...
      + 24*S2( alpha1(r), alpha2(r), delta2 );

    l1 = @(r) r(r <= h4 );
    l2 = @(r) r(h4 < r & r <= h3);
    l3 = @(r) r(h3 < r & r <= 1-h4);
    l4 = @(r) r(1-h4 < r & r <= h4*(5-2* 2^(1/2))^(1/2)  );
    z =  @(r) zeros(1,length(r)-length([l1(r) l2(r) l3(r) l4(r)]) );

    chi = @(r) [chi1(l1(r)) chi2(l2(r)) ...
      chi3(l3(r)) chi4(l4(r)) z(r)];
else
  switch Laue(CS)
    case {'2/m','mmm'}
      n = 2;
    case {'-3','-3m'}
      n = 3;
    case {'4/m','4/mmm'}
      n = 4;
    case {'6/m','6/mmm'}
      n = 6;
    otherwise %'-1'
      n = 1;
  end
  
  h = tan(pi/2/n);
  
  alpha1 = @(r)  acos(h./r);

  chi1 = @(r) 4*pi*ones(size(r));
  chi2 = @(r) chi1(r) - 2*S1( alpha1(r) );
  
  switch Laue(CS)
    case {'-1','-3','4/m','6/m'}   % Cyclic groups C
      % TODO check '2/m'
      chi = @(r) [chi1(r(r<=h)) chi2(r(r>h))];
    case '2/m'
      warning('not yet')
      return
    case {'mmm','-3m','4/mmm','6/mmm'}  % Dihedral groups D
      alpha2 = @(r) acos(1./r);

      delta1 = pi/2;
      delta2 = 2*pi/(2*n);

      chi3 = @(r) chi2(r) - 2*n.* S1( alpha2(r) );
      chi4 = @(r) chi3(r) +  4*n*S2(alpha1(r),alpha2(r),delta1) ...
          + 2*n*S2(alpha2(r),alpha2(r),delta2);

      l1 = @(r) r(r < h);
      l2 = @(r) r(h <= r & r < 1);
      l3 = @(r) r(1 < r & r <= (1+h^2).^(1/2));
      l4 = @(r) r((1+h^2).^(1/2) < r & r <= (1+2*h^2).^(1/2));
      z =  @(r) zeros(1,length(r)-length([l1(r) l2(r) l3(r) l4(r)]) );

      chi = @(r) [chi1(l1(r)) chi2(l2(r))  chi3(l3(r)) chi4(l4(r)) z(r)];
  end
end


%% density function

% r = tan(omega./2)

p = @(omega) n./(2*pi^2) .* sin(omega./2).^2 .* chi( tan(omega./2) );


%% density
% hold on

w = @(omega) (pi/180).*p(omega*pi/180);

degrees = (0:1*degree/5:max_cs(CS))/degree; % discretisation

pd =  w(degrees);
pd = pd./trapz(degrees, pd);
plot(degrees, pd,'g')


if exist('o','var')
% do some test
%   sum( ((pf-pd).^2) )
end


return



function m = max_cs(CS)

switch Laue(CS)
  case {'mmm','4/mmm','6/mmm','-3m'}
    m = pi*2/3;
  case {'m-3m'}
    m = pi/2;
  otherwise
    m = pi;
end





%% tetrahedral T

alpha = @(r) acos( 3.^(1/2)./(3*r) );
delta = acos(1/3);

chi1 = @(r) 4*pi*ones(size(r));
chi2 = @(r) chi1(r) - 8*S1(alpha(r));
chi3 = @(r) chi2(r) + 12*S2(alpha(r),alpha(r),delta);

l1 = @(r) r(r < 3.^(1/2)/3);
l2 = @(r) r(3.^(1/2)/3 < r & r <= 2.^(1/2)/2);
l3 = @(r) r(2.^(1/2)/2 < r & r <= 1);
z =  @(r) zeros(1,length(r)-length([l1(r) l2(r) l3(r)]) );

chi = @(r) [chi1(l1(r)) chi2(l2(r)) chi3(l3(r)) z(r) ];


%% icosahedral Y

h5 = tan(pi/2/5);

alpha = @(r) acos(h5./r);
delta = atan(2);

chi1 = @(r) 4*pi*ones(size(r));
chi2 = @(r) chi1(r) - 12*S1( alpha(r) );
chi3 = @(r) chi2(r) + 30*S2( alpha(r), alpha(r), delta);

r0 = tan(pi/10)*tan(pi/5)*tan(pi/3);
r1 = tan(pi/10)*sin(pi/5)*sec(pi/3);

l1 = @(r) r(r <= h5);
l2 = @(r) r( h5 < r & r <= r1 );
l3 = @(r) r( r1 < r & r <= r0 );
z =  @(r) zeros(1,length(r)-length([l1(r) l2(r) l3(r)]) );

chi = @(r) [chi1(l1(r)) chi2(l2(r)) chi3(l3(r)) z(r) ];
