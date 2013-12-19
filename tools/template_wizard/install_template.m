function install_template(varargin)

url = get_option(varargin,'url','http://mtex.googlecode.com/svn/trunk/templates/');
template = get_option(varargin,'template',[]);

%install template
if ~isempty(template)
  template_file = urlread([url template]);

  fname = fullfile(mtex_path,'templates',template);
  
  if exist(fname)
   choice = questdlg('File already exists, overwrite it?:','Overwrite','Yes','No','Cancel','No');
   if ~strcmpi(choice,'Yes'),
     edit(fname);
     return;
   end
  end
  
  fid = fopen(fname,'w');
  fwrite(fid,template_file);
  fclose(fid); 

  view_link = ['successfully installed: <a href="matlab:edit '  fname '">' template '</a>'];
  disp(view_link)
  
  edit(fname);
end



