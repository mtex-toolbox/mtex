function openuntitled( str, fname )

err = javachk('mwt','The MATLAB Editor');
if ~isempty(err)
  local_display_mcode(str,'cmdwindow');  %??
end

if ~getpref('mtex','SaveToFile')
  try
    EditorServices = com.mathworks.mlservices.MLEditorServices;
    if ~verLessThan('matlab','7.11')
      EditorServices.getEditorApplication.newEditor(str);
    else
      EditorServices.newDocument(str,true);
    end
  catch %#ok<CTCH>
    setpref('mtex','SaveToFile',true);
    openuntitled( str, fname );
  end
else
  [file path] = uiputfile([fname '.m']);
  if ischar(file)
    fname = fullfile(path,file);
    fid = fopen(fname,'w');
    fwrite(fid,str);
    fclose(fid);
    edit(fname);
  else
    error('no data file specified')
  end
end