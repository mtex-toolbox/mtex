function g0 = modalorientation(odf,varargin)
% caclulate the modal orientation of the odf
%
%% Input
%  odf - @ODF 
%
%% Output
%  g0 - @quaternion
%
%% See also
%

g0 = quaternion;
for i = 1:length(odf)

  data = getdata(odf(i));
  ind = find(max(data(:)) == data);
  
  if isa(odf(i).center,'SO3Grid'), g0 = [g0,getgrid(odf(i),ind)];
  elseif isa(odf(i).center,'quaternion'), g0 = [g0,odf(i).center(ind)];end
  
end
