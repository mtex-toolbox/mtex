function [m, vmin] = min(sF)

N = 10;
MAXIT = 10;
TOL = 1e-3;

v = equispacedS2Grid('points', N);
G = sF.grad;
Gx = G.sF_x.grad;
Gy = G.sF_y.grad;
Gz = G.sF_z.grad;

for step = 1:MAXIT
	% step direction
	if step == 1
		d = -G.eval(v).xyz';
	else
		dtilde = (v-vold);
		dtilde = dtilde.xyz';
		g = -G.eval(v).xyz';
		beta = zeros(1, length(v));
		for ii = 1:length(v)
			H = [Gx.eval(v(ii)).xyz; Gy.eval(v(ii)).xyz; Gz.eval(v(ii)).xyz];
			beta(ii) = (g(:, ii)'*H*dtilde(:, ii))/(dtilde(:, ii)'*H*dtilde(:, ii));
		end
		d = g+[1; 1; 1]*beta.*dtilde;
	end

	% steplength
	normd = [1; 1; 1]*sqrt(sum(d.^2));
	alpha = 0../normd;
	
	% update v
	vold = v;
	v = vector3d(cos(alpha.*normd).*v.xyz'+sin(alpha.*normd).*d./normd);
	line(vold, v);
	v = unique(v);
end

m = min(sF.eval(v));
vmin = v(abs(sF.eval(v)-m) < TOL);

end
