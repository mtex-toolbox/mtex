function m = nanmean(v,varargin)
% computes the mean vector, sets nan vectors to 0
%
% Syntax
%
%   % average direction with respect to the first nonsingleton dimension
%   m = nanmean(v)
%
%   % average direction along dimension d
%   m = nanmean(v,d)
%
%   % average axis
%   m = nanmean(v,'antipodal')
%
% Input
%  v - @vector3d
%
% Output
%  m - @vector3d
%
% Options
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%  robust    - robust mean (with respect to outliers)
%  weights   - weights of the vectors, the weights of NaN vectors are set to 0
%

% take care of nans
badpos = isnan(v);
v.x(badpos) =0;
v.y(badpos) =0;
v.z(badpos) =0;

if check_option(varargin,'weights')
    w = get_option(varargin,'weights');
    w(badpos) = 0;
    varargin = set_option(varargin,'weights',w);
end

 m = mean(v,varargin{:});

end