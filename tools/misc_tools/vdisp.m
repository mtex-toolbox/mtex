function vdisp(s,varargin)

if ~check_option(varargin,'silent') && ~getMTEXpref('generatingHelpMode')
  disp(s);
end
