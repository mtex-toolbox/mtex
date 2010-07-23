function mst = file2mst(file)
% file

switch fileext(file)
	case '.m'
    fid = fopen(file);  
    mst = m2struct(char(fread(fid))');
    fclose(fid);
  case '.html'
    docr = xmlread(file);
    title = docr.getElementsByTagName('title');
    intro = docr.getElementsByTagName('introduction');
      
    mst(1).title = char(title.item(0).getFirstChild.getNodeValue());
    mst(1).text = {char(intro.item(0).getFirstChild.getNodeValue)};
end

function extension = fileext(fname)
extension = fname(find(fname == '.', 1, 'last'):end);