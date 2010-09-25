function T = tensor(varargin)


T.M = varargin{1};

args = find(cellfun(@(s) isa(s,'symmetry'),varargin,'uniformoutput',true));

if ~isempty(args)
  T.CS = varargin{args};
else
  T.CS = symmetry;
end

T.units   = get_option(varargin,'Units','');
T.name    = get_option(varargin,'Name','');
T.comment = get_option(varargin,'comment','');


T.rank    = round(log(numel(T.M))/log(3));

superiorto('quaternion','rotation','orientation')
T = class(T,'tensor');
