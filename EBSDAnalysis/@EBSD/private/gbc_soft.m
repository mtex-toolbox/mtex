function criterion = gbc_soft(q,CS,Dl,Dr,threshold,varargin)

o_Dl = orientation(q(Dl),CS);
o_Dr = orientation(q(Dr),CS);

if length(threshold) == 1
  threshold(2) = 0.5 * threshold;
end

%criterion = 0.5 * (1 + erf(2*(angle(o_Dl,o_Dr) - threshold(1))./threshold(2)));
criterion = 1 - 0.5 * (1 + erf(2*(angle(o_Dl,o_Dr) - threshold(1))./threshold(2)));

end

function test

threshold = [10,2.5]*degree;
misAngle = linspace(0,20*degree);

criterion = 1-0.5 * (1 + erf(2*(misAngle - threshold(1))./threshold(2)));

plot(misAngle./degree,criterion,'linewidth',2);

hold on
%criterion = 1-cdf('Burr',misAngle./degree,10,5,1);
plot(misAngle./degree,criterion);
hold off

end
