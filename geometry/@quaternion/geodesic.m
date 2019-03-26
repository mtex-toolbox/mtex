function rot = geodesic(rot1,rot2,t)
% Calculats the rotation, which is described by the geodesic 
% gamma(t)_{rot1,rot2} from rot1 to rot2 at the location t,
% for vectors of n rotations.
%
% Input
%  rot1 - n dimensional vector of rotations
%  rot2 - n dimensional vector of rotations
%  t    - n dimensional vector in [0,1]^n
%
% Output
%  rot  - n dimensional vector of rotations
%
    
rot = exp( t .* log(rot2,rot1), rot1);

r1IsNaN = isnan(rot1);
rot.a(r1IsNaN) = rot2.a(r1IsNaN);
rot.b(r1IsNaN) = rot2.b(r1IsNaN);
rot.c(r1IsNaN) = rot2.c(r1IsNaN);
rot.d(r1IsNaN) = rot2.d(r1IsNaN);

r2IsNaN = isnan(rot2);
rot.a(r2IsNaN) = rot1.a(r2IsNaN);
rot.b(r2IsNaN) = rot1.b(r2IsNaN);
rot.c(r2IsNaN) = rot1.c(r2IsNaN);
rot.d(r2IsNaN) = rot1.d(r2IsNaN);