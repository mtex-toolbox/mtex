function x = DebugFunc(phi, theta)

persistent E EO1 EO2

if length(E) == 0
    % create ONB
    
    E = [1 2 3];
    %E = [-3 1 -2];
    E = E / norm(E, 2);

    EO1 = [-5 1 1];
    EO1 = EO1 / norm(EO1, 2);
    
    A = [1 1 1];
    EO2 = A - (A * E.') * E - (A * EO1.') * EO1;
    EO2 = EO2 / norm(EO2, 2);
    
    % Here, E, EO1 and EO2 should be orthonormal basis
end

rho = 1;
    
r = rho * sin(phi);
V = [r * cos(theta), r * sin(theta), rho * cos(phi)];

[phase, r] = cart2pol(sum(V .* EO1), sum(V .* EO2));

%x = sin(2 * pi * 3 * sum(V .* E));
%x = sum(V .* E);

arg = acos(sum(V .* E));
x = sin(12 * arg + phase);  % Vortex
%x = sin(12 * arg);  % concentric circle
