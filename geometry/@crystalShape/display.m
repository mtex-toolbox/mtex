function display(cS,varargin)
% standard output

displayClass(cS,inputname(1),varargin{:});

if length(cS)>1, disp([' size: ' num2str(length(cS))]); end

% display symmetry
if ~isempty(cS.CS.mineral)
  disp([' mineral: ',char(cS.CS,'verbose')]);
else
  disp([' symmetry: ',char(cS.CS,'verbose')]);
end

% display vertices
disp([' ' varlink([inputname(1),'.V'],'vertices') ': ',num2str(size(cS.V,1))]);

% display faces
disp([' faces: ',num2str(size(cS.F,1)./length(cS))]);