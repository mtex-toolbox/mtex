function mtex_text(x,y,t,varargin)
% insert text depending on mtex_options

if isa(t,'Miller') || isa(t,'vector3d')
  if check_mtex_option('noLaTex')
    t = char(t,'Tex');
  else
    t = char(t,'LaTex');
  end
elseif ~ischar(t)
  t = char(t);
end

if check_mtex_option('noLaTex')
  text(x,y,t,'interpreter','tex',varargin{:});
else
  text(x,y,['$' t '$'],'interpreter','latex',varargin{:});
end
