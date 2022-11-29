function f = dubna(varargin)
% Construct the odf from the dubna data set as example for an SO3Fun.

f=load('dubna_SO3Fun.mat').SO3F;

if nargin > 0 && isa(varargin{1},'rotation')
  ori = varargin{1};
  f = f.eval(ori);
end


end