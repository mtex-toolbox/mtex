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

% g0 = quaternion;
% for i = 1:length(odf)
% 
%   data = getdata(odf(i));
%   ind = find(max(data(:)) == data);
%   
%   if isa(odf(i).center,'SO3Grid'), g0 = [g0,getgrid(odf(i),ind)];
%   elseif isa(odf(i).center,'quaternion'), g0 = [g0,odf(i).center(ind)];end
%   
% end

res = 5*degree;
resmax = get_option(varargin,'resolution',...
  max(0.5*degree,get(odf,'resolution')/2));

% initial gues
S3G = SO3Grid(2*res,odf(1).CS,odf(1).SS);
f = eval(odf,S3G);

g0 = quaternion(S3G,find(f>0.8*max(f)));

f0 = max(f);

while res >= resmax || (0.95 * max(f) > f0)

  f0 = max(f);
  S3G = g0*SO3Grid(res,odf(1).CS,odf(1).SS,'max_angle',2*res);
  f = eval(odf,S3G);
  g0 = quaternion(S3G,find(f(:)==max(f(:))));
  res = res / 2;
end

