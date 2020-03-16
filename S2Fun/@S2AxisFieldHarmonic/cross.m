function sAF1 = cross(sAF1,sAF2,varargin)
%
% syntax
%  f = cross(sAF,v)
%  f = cross(sAF1,sAF2)
%  f = cross(sAF,sVF)
%
% Input
%  sAF,sAF1,sAF2 - @S2AxisFieldHarmonic
%  sVF  - @S2VectorFieldHarmonic
%  v    - @vector3d
%
% Output
%  f - @S2AxisFieldHarmonic
%

% the simple case
if isa(sAF2,'vector3d')
  
  [x,y,z] = double(sAF2);
  v = [x*x,x*y,y*y,x*y,x*z,z*z];
    
  % [a,b,c] x [x,y,z] = [bz - cy, cx - az, ay - bx]
  % 
  % bbzz + ccyy -2 bcyz
  % 2bczx + 2acyz -2abzz -2ccxy 
  % ccxx + aazz -2acxz
  % 2abyz + 2bcyx - 2bbxz - 2acyy
  % 2acxy + 2abxz - 2bcxx - 2aayz
  % aayy + bbxx -2abxy
  
  M = [...
    [0  0  6  0  5  3 ]; ...                   
    [0  6  0  5  4  2 ]; ...
    [6  0  0  4  0  1 ]; ...
    [0  5  4  3  2  0 ]; ...
    [5  4  0  2  1  0 ]; ...
    [3  2  1  0  0  0 ]];
  %  aa ab bb ac bc cc
  
  M(M>0) = v(M(M>0));
  M = M .* [...
    [ 0  0  1  0 -2  1 ]; ...
    [ 0 -2  0  2  2 -2 ]; ...
    [ 1  0  0 -2  0  1 ]; ...
    [ 0  2 -2 -2  2  0 ]; ...
    [-2  2  0  2 -2  0 ]; ...
    [ 1 -2  1  0  0  0 ]];
 
 sAF1.sF.fhat = sAF1.sF.fhat * M.';
  
% implement a faster method if both are  S2AxisFieldHarmonic
%elseif isa(sAF2,'S2AxisFieldHarmonic')

%  sAF1.sF = S2FunHarmonic.quadrature(@(v) cross_localHarm(v),varargin{:});
  
else
  
  sAF1 = S2AxisFieldHarmonic.quadrature(...
    @(v) cross(sAF1.eval(v),sAF2.eval(v)),varargin{:});

end

end
