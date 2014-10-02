function rot = symAxis(v,n)

rot = rotation('axis',v,'angle',2*pi/n*(0:n-1));

end
