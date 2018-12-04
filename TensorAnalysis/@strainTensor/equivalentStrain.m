function epsilonEq = equivalentStrain(epsilon)
% von Mises equivalent strain

e = epsilon.deviatoricStrain;
epsilonEq = sqrt(2/3 * e:e);

% this does work only in specific cases
%[r12,r23] = axisRatios(epsilon);
%epsilonEq = 2/3 * sqrt(r12.^2 + r12.*r23 + r23.^2)