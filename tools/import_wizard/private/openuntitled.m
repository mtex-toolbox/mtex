function  openuntitled( str )

err = javachk('mwt','The MATLAB Editor');
if ~isempty(err)
  local_display_mcode(str,'cmdwindow');
end

try
  com.mathworks.mlservices.MLEditorServices.newDocument(str,true);
catch %#ok<CTCH>
  com.mathworks.mlservices.MLEditorServices.newDocument(str)
end
