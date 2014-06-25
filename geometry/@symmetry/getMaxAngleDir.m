function  omega = getMaxAngleDir(cs,axes)
% get the fundamental region for a crystal and specimen symmetry

h = getFundamentalRegionRodriguez(cs);

h = h ./ norm(h).^2;

q = rotation('axis',axes,'angle',10*degree);

rod = Rodrigues(q);
lambda = min(abs(abs(1./dot_outer(h,rod))));
    
omega = 2*atan(reshape(lambda,size(rod)).*norm(rod));
    


