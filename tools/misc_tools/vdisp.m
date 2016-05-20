function vdisp(s,varargin)

global prevCharCnt;
if isempty(prevCharCnt), prevCharCnt = 0; end

if ~check_option(varargin,'silent') && ~getMTEXpref('generatingHelpMode')
  fprintf(repmat('\b',1, prevCharCnt));
  prevCharCnt = 0;
  disp(s);
end
