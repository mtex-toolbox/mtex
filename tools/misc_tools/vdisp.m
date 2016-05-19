function vdisp(s,varargin)

global prevCharCnt;

if ~check_option(varargin,'silent') && ~getMTEXpref('generatingHelpMode')
  fprintf(repmat('\b',1, prevCharCnt));
  prevCharCnt = 0;
  disp(s);
end
