function [gB ,IA, IC] = cat(dim, varargin)

  gB = cat@dynProp(dim,varargin{:});

  for k = 2:numel(varargin)
    ngB = varargin{k};

    gB.V = [gB.V , ngB.V];
    [gB.V, ~ , IC] = unique(gB.V, 'stable');

    gB.poly = [gB.poly ; ngB.poly];

    for j = (size(gB.poly,1)-size(ngB.poly,1)):size(gB.poly,1)
      poly=gB.poly{j};
      for i = size(ngB.V,1):size(gB.V,1)
        poly(i)=IC(poly(i));
      end
      gB.poly{j}=poly;
    end

    % TO DO: unique does not work for cell arrays
    %[gB.poly, IA, IC] = unique(gB.poly, 'stable');
    IA = 1:length(gB.poly);
    IC = IA;

  end

end
