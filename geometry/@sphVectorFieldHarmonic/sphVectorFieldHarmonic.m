classdef sphVectorFieldHarmonic < sphVectorField
% a class represeneting a function on the sphere

properties
	sF_x
	sF_y
	sF_z
end

methods

	function sVF = sphVectorFieldHarmonic(sF_x, sF_y, sF_z)
	% initialize a spherical vector field

	sVF.sF_x = sF_x;
	sVF.sF_y = sF_y;
	sVF.sF_z = sF_z;

	end

end

end
