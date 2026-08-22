function display(mg,varargin) %#ok<DISPLAY> every MTEX class overloads it
% standard output

displayClass(mg,inputname(1),varargin{:});
if length(mg) > 1, disp([' size: ' size2str(mg)]); end
disp(' ');

for k = 1:length(mg)

  d = {};
  sz = size(mg(k));

  d{end+1,1} = 'name';   d{end,2} = mg(k).name; %#ok<*AGROW>
  d{end+1,1} = 'size';   d{end,2} = sprintf('%d x %d',sz(1),sz(2));
  if mg(k).nChannel > 1
    d{end,2} = sprintf('%s x %d channels',d{end,2},mg(k).nChannel);
  end
  d{end+1,1} = 'step';   d{end,2} = sprintf('%.4g x %.4g',mg(k).dx,mg(k).dy);
  d{end+1,1} = 'frame';  d{end,2} = conventionChar(mg(k).frame);
  d{end+1,1} = 'layout'; d{end,2} = conventionChar(mg(k).arrayFrame);
  if ~isempty(mg(k).ebsd)
    d{end+1,1} = 'map';  d{end,2} = char(mg(k).ebsd.mineralList(:).');
  end

  cprintf(d,'-L','  ','-ic',true);
  disp(' ');

end

end
