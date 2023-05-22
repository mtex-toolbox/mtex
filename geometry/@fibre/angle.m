function omega = angle(f,ori,varargin)
% angle fibre to orientation or fibre to fibre
%
% Syntax
% 
%   omega = angle(f,ori) % angle orientation to fibre 
%   omega = angle(f1,f2) % angle fibre to fibre
%
% Input
%  f, f1, f2 - @fibre
%  ori - @orientation
%
% Output
%  omega - double
%
% See also 
% orientation/angle

if isa(ori,'orientation')
  omega = angle(ori .\ f.r,f.h,varargin{:});

else
  omega = max(angle(f,orientation(ori),varargin{:}));

  % in the non symmetric case we have also
  %omega = min(angle(f.h,ori.h) + angle(f.r,ori.r), angle(f.h,-ori.h) + angle(f.r,-ori.r));

end

end
