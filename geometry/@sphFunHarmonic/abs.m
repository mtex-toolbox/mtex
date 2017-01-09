function sF = abs(sF)
% absolute value of a function
   
S2G = sF.grid;
v = abs(sF.eval(S2G));

sF = interp(S2G,v,[],'harmonic',sF.degree);
    
end