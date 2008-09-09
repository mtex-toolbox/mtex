function  openuntitled( str )

err = javachk('mwt','The MATLAB Editor');
if ~isempty(err)
  local_display_mcode(str,'cmdwindow');
end
com.mathworks.mlservices.MLEditorServices.newDocument(str,true);
