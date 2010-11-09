function T = tensor(varargin)


T.M = varargin{1};

if numel(T.M) == 36,
  T.M = tensor24(T.M);
end

r = max([1,find(size(T.M)-1,1,'last')]);
T.rank    = get_option(varargin,'rank',r);

args = find(cellfun(@(s) isa(s,'symmetry'),varargin,'uniformoutput',true));

if ~isempty(args)
  T.CS = varargin{args};
else
  T.CS = symmetry;
end

T.units   = get_option(varargin,'Units','');
T.name    = get_option(varargin,'Name','');
T.comment = get_option(varargin,'comment','');

superiorto('quaternion','rotation','orientation')
T = class(T,'tensor');
