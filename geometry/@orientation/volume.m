function v = volume(ori,center,radius,varargin)
% ratio of orientations with a certain orientation
%
% Description
% returns the ratio of mass of the ebsd that is close to 
% one of the orientations as radius
%
% Syntax
%   v = volume(ebsd,center,radius)
%
% Input
%  ebsd   - @EBSD
%  center - @quaternion
%  radius - double
%
% See also
% ODF/volume

if isa(center,'fibre')
  v = fibreVolume(ori,center.h,center.r,radius,varargin{:});
  return
end

% compute volume
if isempty(ori)
  v = 0;
elseif check_option(varargin,'weights')
  weights = get_option(varargin,'weights');
  v = sum(weights(find(ori,center,radius,varargin{:})));
else
  v = nnz(angle(ori,center,varargin{:})<=radius) ./ length(ori);
end
