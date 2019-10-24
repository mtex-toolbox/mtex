% •½–Ê‚Ö‚ÌË‰e‚ÌÛ‚Épolar cap•”•ª‚Ì˜c‚İ‚ğ•â³‚µ‚ÄŒ©‚¹‚é

function [ox, oy] = HealpixPlanePoleDistort(x, y)

ox = x;
oy = y;

if pi / 4 < abs(y)
    partition = fix(2 * x / pi);
    x_t = x - partition * pi / 2;   % = mod(x, pi / 2);
    if pi / 2 <= abs(y) || abs(x_t - pi / 4) >= pi / 2 - abs(y)
        % out of range
        ox = -1;
        oy = -1;
    else
        d0 = pi / 2 - abs(y);
        d1 = pi / 4;
        if d0 == 0
            ox = x;
        else
            x_c = x_t - pi / 4;
            ox = x_c * d1 / d0 + (x - x_t + pi / 4);
        end
    end 
end
