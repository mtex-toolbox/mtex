function omega = angle(f,ori,varargin)
% angle fibre to orientation or fibre to fibre
%
%

if isa(ori,'orientation')
  omega = angle(ori .\ f.r,f.h,varargin{:});
else
  %omega = max(min(angle_outer(orientation(f),orientation(ori))));
  omega = min(angle(f.h,ori.h) + angle(f.r,ori.r), ...
          angle(f.h,-ori.h) + angle(f.r,-ori.r));
end

end