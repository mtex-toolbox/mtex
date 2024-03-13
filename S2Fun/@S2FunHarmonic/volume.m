function sF = volume(sF1, center, radius)
% fraction of directions within a given cone
%
% Description
% The function 'volume' returns the ratio of directions that are
% within a cone with a given radius around a center relative to the
% of the entire spherical function.
%
% Syntax
%   v = volume(sF,center,radius)
%
% Input
%  sF     - @S2Fun
%  center - @vector3d
%  radius - double
%
% Options
%  resolution - resolution of discretization
%

% should sf be normalized?
sF = sF ./ sF.mean;

res = get_option(varargin,'resolution',1*degree);

if sF.antipodal
    g = equispacedS2Grid('resolution',res,'antipodal');
else
    g = equispacedS2Grid('resolution',res);
end

% what is inside the cone
inside = angle(center.project2FundamentalRegion,g)<=radius;

v = sum(eval(sF,g(inside))) / sum(eval(sF,g)); 

end


end
