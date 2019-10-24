% HEALPIX Border

clear

n = 2;
n = 4;
n = 16;

% sampling interval on the unit sphere
interval = pi / 90;

hold on
axis equal

% polar cap area

for k = 1:n
    start_phi = pi * k / (2 * n);    
    end_phi = pi / 2;
    S = HealpixBorderLinePC(n, k, interval, start_phi, end_phi, 0);        
    for m = 0:3
        % Northern Hemisphere
        C = SphToCart([S(:, 1), S(:, 2) + pi * m / 2]);
        plot3(C(:,1),C(:,2),C(:,3), 'g-')
        % Southern Hemisphere
        C = SphToCart([pi - S(:, 1), S(:, 2) + pi * m / 2]);
        plot3(C(:,1),C(:,2),C(:,3), 'r-')
    end

    start_phi = 0;
    end_phi = pi / 2 - pi * k / (2 * n);
    S = HealpixBorderLinePC(n, k, interval, start_phi, end_phi, 1);        
    for m = 0:3
        % Northern Hemisphere
        C = SphToCart([S(:, 1), S(:, 2) + pi * m / 2]);
        plot3(C(:,1),C(:,2),C(:,3), 'g-')
        % Southern Hemisphere
        C = SphToCart([pi - S(:, 1), S(:, 2) + pi * m / 2]);
        plot3(C(:,1),C(:,2),C(:,3), 'r-')
    end
end

for k = 0:3
    % Northern Hemisphere
    PHI = 0:interval:acos(2 / 3);
    if PHI(end) ~= acos(2 / 3)  % if the end edge point was not included
        PHI = [PHI acos(2 / 3)];    % add the end edge
    end
    S = [PHI.', ones(size(PHI, 2), 1) * k * pi / 2];
    C = SphToCart(S);
    plot3(C(:,1),C(:,2),C(:,3), 'm-')
    
    % Southern Hemisphere
    PHI = acos(-2 / 3):interval:pi;
    if PHI(end) ~= pi  % if the end edge point was not included
        PHI = [PHI pi];    % add the end edge
    end
    S = [PHI.', ones(size(PHI, 2), 1) * k * pi / 2];
    C = SphToCart(S);
    plot3(C(:,1),C(:,2),C(:,3), 'm-')
end

% equatorial belt area

for k = (-3 * n):(n - 1)
    start_theta = acos(-2 / 3);
    start_phi = (-4 / 3 + 4 * k / (3 * n)) * 3 * pi / 8;    
    end_phi = 4 * k / (3 * n) * 3 * pi / 8;
    S = HealpixBorderLineEB(n, k, interval, start_phi, end_phi, start_theta);        
    C = SphToCart(S);
    plot3(C(:,1),C(:,2),C(:,3), '-')
    
    start_theta = acos(2 / 3);
    temp = -start_phi;
    start_phi = -end_phi;
    end_phi = temp;
    S = HealpixBorderLineEB(n, k, interval, start_phi, end_phi, start_theta);        
    C = SphToCart(S);
    plot3(C(:,1),C(:,2),C(:,3), '-')
end

