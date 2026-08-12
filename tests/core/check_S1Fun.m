function check_S1Fun
% check basic arithmetic of S1Fun
%
% The plotting option half of this file is plotting/check_S1FunPlot.
%
% See also
% S1FunHarmonic check_S1FunPlot

f = S1FunHandle(@(x) cos(2*x) + 0.5*sin(x) + 0.3);
F = S1FunHarmonic(f);
x = linspace(0,2*pi,13).';
ref = f.eval(x);

%% adding a constant

% the constant is stored in the middle of fhat as it runs from -N to N
A = F + 3; B = 3 + F; C = F - 1.5;

assertAlmostEqual(eval(A,x),ref+3,'sF + a is wrong')
assertAlmostEqual(eval(B,x),ref+3,'a + sF is wrong')
assertAlmostEqual(eval(C,x),ref-1.5,'sF - a is wrong')
assertAlmostEqual(mean(A),mean(F)+3,'mean(sF + a) is wrong')

if ~A.isReal, error('sF + a is not real anymore'); end

% vector valued S1Fun plus a vector of constants
G = [F;2*F] + [1;2];
assertAlmostEqual(eval(G,x),ref*[1 2] + [1 2],'sF + a is wrong for vector valued sF')

% constant function, i.e. bandwidth 0
assertAlmostEqual(eval(S1FunHarmonic(2) + 5,x),7,'sF + a is wrong for bandwidth 0')

disp('check_S1Fun: everything ok!')

end

function assertAlmostEqual(a,b,msg)

if max(abs(a(:)-b(:))) > 1e-10, error(msg); end

end
