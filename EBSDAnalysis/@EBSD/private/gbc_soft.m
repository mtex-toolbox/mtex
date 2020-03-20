function criterion = gbc_soft(q,CS,Dl,Dr,threshold,varargin)

o_Dl = orientation(q(Dl),CS);
o_Dr = orientation(q(Dr),CS);

criterion = 0.5 * (1 + erf(4*(angle(o_Dl,o_Dr) - threshold)./threshold));

end

function test

threshold = 10*degree;
misAngle = linspace(0,20*degree);

criterion = 0.5 * (1 + erf(4*(misAngle - threshold)./threshold));

plot(misAngle./degree,criterion);

end
