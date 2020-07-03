function v = nan2zero(v)

ind = isnan(v.x);
v.x(ind) = 0;
v.y(ind) = 0;
v.z(ind) = 0;

end