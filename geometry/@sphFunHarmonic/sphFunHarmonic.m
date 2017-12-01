classdef sphFunHarmonic < sphFun
% a class represeneting a function on the sphere

properties
	fhat = [] % harmonic coefficients
end
properties(Dependent)
	M
end

methods
	function sF = sphFunHarmonic(fhat)
	% initialize a spherical function
		fhat = fhat(:);
		M = ceil(sqrt(length(fhat))-1); % make (M+1)^2 entries
		fhat = [fhat; zeros((M+1)^2-length(fhat), 1)];

		cutoff = eps; ii = 0; % truncate neglectable coefficients
		while sum(abs(fhat((M-ii)^2+1:(M+1)^2))) <= cutoff & M > 0
			ii = ii+1; 
		end
		sF.fhat = fhat(1:(M+1-ii)^2);
	end
	function M = get.M(sF)
		M = sqrt(length(sF.fhat))-1;
	end
end

methods (Static = true)
	sF = approximation(v, y, varargin);
	sF = quadrature(f, varargin);
end

end
