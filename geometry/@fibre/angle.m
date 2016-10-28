function omega = angle(f,ori,varargin)
% angle fibre to orientation or fibre to fibre
%
%

if isa(ori,'orientation')
  omega = angle(ori .\ f.r,f.h,varargin{:});
else
  error('not yet implemented')
end

end