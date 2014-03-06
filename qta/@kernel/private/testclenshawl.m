function testclenshawl(kappa,maxl);

l = 1:maxl;
AL = exp(log(kappa)*l).*(2*l+1).*l.*(l+1);

omega = linspace(0,pi/5,100);

f = ClenshawL(AL,cos(omega));
plot(f);