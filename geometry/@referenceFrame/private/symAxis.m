function rot = symAxis(v,n)

rot = rotation.byAxisAngle(v,2*pi/n*(0:n-1));

end
