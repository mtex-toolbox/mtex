function s = vertcat(varargin)
% overloads [v1;v2;v3..]

s = varargin{1};

v = cell(size(varargin));
res = 2*pi;
for k=1:numel(varargin)
  if isa(varargin{k},'S2Grid'),res = min(res,varargin{k}.res);end
  v{k} = vector3d(varargin{k});
end

try
  s.vector3d = vertcat(v{:});
catch %#ok<CTCH>
  for k=1:numel(varargin)
    v{k} = reshape(v{k},[],1);
  end
  s.vector3d = vertcat(v{:});
end

s.res = res;
s = delete_option(s,'indexed');
