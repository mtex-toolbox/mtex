function h = uvw(h)
% change crystal direction convention to uvw coordinates if not done yet
%
%% See also
% Miller/hkl

if check_option(h,'hkl')
  h = delete_option(h,'hkl');
end

if ~check_option(h,'uvw')
  h = set_option(h,'uvw');
end