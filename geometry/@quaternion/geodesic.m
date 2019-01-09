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
