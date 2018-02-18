function r0 = equivalentStrain(epsilon)
% equivalent strain of a strain tensor

[r12,r23] = axisRatios(epsilon);

r0 = 2/3*sqrt(r12.^2 + r12.*r23 + r23.^2);
