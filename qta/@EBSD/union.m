function ebsd_union = union(varargin)
%union of ebsd set according to same phase

ebsd = [varargin{:}];
phases = get(ebsd,'phase');
uphase = unique(phases);
ebsd_union(1:numel(uphase)) = ebsd(1);

% comment = strcat({ebsd.comment},{', '});

for k=1:numel(uphase)
  ebsd_sel = ebsd(phases == uphase(k));
%   ebsd_union(k).comment = ['union of data' strcat({ebsd_sel.comment},{','})]
  ebsd_union(k).orientations = vertcat(ebsd_sel.orientations);
  ebsd_union(k).xy = vertcat(ebsd_sel.xy);
    
  opts = vertcat(ebsd_sel.options);
  opt = opts(1);
  for field = fieldnames(opts)'    
    opt.(field{:}) = vertcat(opts.(field{:}));
  end
  ebsd_union(k).options = opt;
end



