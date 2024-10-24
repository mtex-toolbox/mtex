function sF = volume(sF1,center,radius)
% Integrates an S2Fun on the region of all vector3d's that are close to a 
% specified vector3d (center) by a tolerance (radius), i.e.
%
% $$ \int_{\angle(g,c)<r} f(g) \, dg.$$
%
% Description
% The function 'volume' returns the ratio of the volume of an S2Fun on the 
% region (of all vector3d's that are close to a specified vector3d (center) 
% by a tolerance (radius)) to the volume of the entire spherical function.
%
% Note that if the S2Fun $f$ is 'antipodal' the volume in any center with
% radius 90° will return the mean value of the S2Fun, which is infact the 
% volume of the whole sphere.
%
% Syntax
%   v = volume(sF,center,radius)
%
% Input
%  sF     - @S2FunTri
%  center - @vector3d
%  radius - double
%
% Options
%  resolution - resolution of discretization
%
% See also
% S2FunHarmonic/volume S2Fun/sum S2Fun/mean
    
sF = sF1;
   
sF.values = sF1.values;
   
sF = volume(sF.values, center, radius);

end