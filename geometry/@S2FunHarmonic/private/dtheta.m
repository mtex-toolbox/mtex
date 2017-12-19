function sF = dtheta(sF)

fhat = zeros((sF.bandwidth+2)^2, 1);
for m = 0:sF.bandwidth+1
  for l = -m:m
    a = (m-1)*sqrt((m^2-l^2)/((2*m-1)*(2*m+1)));
    b = (m+2)*sqrt(((m+1)^2-l^2)/((2*m+1)*(2*m+3)));
    if ( ( m-1 == 0 ) || ( m-1 == -1 ) ) && ( l == 0 )
      a = 0;
    end
    if ( m+1 == 0 ) && ( l == 0 )
      b = 0;
    end
    fhat(m*(m+1)+l+1) = a*sF.get_fhat(m-1, l)-b*sF.get_fhat(m+1, l);
  end
end

sF = S2FunHarmonic(fhat);
f = @(v) sF.eval(v)./max(sin(v.theta), 0.01);
sF = S2FunHarmonic.quadrature(f, 'm', max(2*sF.bandwidth, 100));

end
