classdef S1Fun
% an abstract class representing functions on the 1-sphere
%
% S1Fun is the common interface of all representations of a function
% defined on the circle, e.g. the distribution of an angle. Deriving
% classes only have to implement the method eval, everything else -
% arithmetics, plotting, integration - is inherited from here.
%
% Class Properties
%  antipodal - f(x) = f(x + pi)
%  bandwidth - maximum harmonic degree
%
% Derived Classes
%  @S1FunHarmonic - Fourier series on the circle
%  @S1FunHandle   - function given by a function handle
%
% See also
% S1FunHarmonic S1FunHandle

  properties (Abstract = true)
    antipodal
    bandwidth %
  end

  methods (Abstract = true)
    
    f = eval(sF,v,varargin)
    
  end

end
