classdef sphFunHarmonic < sphFun
% a class represeneting a function on the sphere

properties
	fhat = [] % harmonic coefficients
	w = @(v) 1
end

methods
	function sF = sphFunHarmonic(fhat, varargin)
	% initialize a spherical function
		sF.fhat = fhat;
		if check_option(varargin, 'w')
			sF.w = get_option(varargin, 'w');
		end
	end
end

methods (Static = true)
	sF = approximation(v, y, varargin);
	sF = quadrature(f, varargin);
end

end
