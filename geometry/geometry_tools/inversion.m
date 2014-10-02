function i = inversion(varargin)
% the inversion - reflection at the origin

i = -rotation(idquaternion(varargin{:}));
  
