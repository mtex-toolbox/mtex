function h = hkl(h)
% change crystal direction convention to hkl coordinates if not done yet
%
%% See also
% Miller/uvw

if check_option(h,'uvw')
  h = delete_option(h,'uvw');
end

if ~check_option(h,'hkl')
  h = set_option(h,'hkl');
end