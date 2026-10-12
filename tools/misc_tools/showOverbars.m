function good = showOverbars(varargin)
% check whether the command window font centres the overbars
%
% Negative Miller indices and point groups are printed with a combining
% overline, e.g. 1̅. Only some fonts place this bar centred above the digit.
% The fonts known to do so are listed in the MTEX preference overbarFonts.
%
% Syntax
%
%   % print a sample in the current command window font
%   showOverbars
%
%   % cycle through all installed monospaced fonts
%   good = showOverbars('cycle')
%
%   % hint at showOverbars if the font is not in overbarFonts
%   showOverbars('check')
%
% Output
%  good - fonts marked as centred, added to the preference overbarFonts
%
% Description
% With the option 'cycle' every installed monospaced font is made the
% command window font in turn, and the sample is printed. Variants such as
% Light or Bold are skipped, as overbarFonts matches by prefix. Press Enter
% to go on, |y| to mark the font as centred, |k| to keep it as the command
% window font or |q| to quit. Unless a font is kept, the initial font is
% restored at the end.
%

ov = char(773);
sample = ['[11' ov '0]  {2' ov '11}  <1' ov '1' ov '1' ov '>  3' ov 'm  6' ov 'm2'];
[name,setFont] = commandWindowFont;

if check_option(varargin,'check')
  if usejava('desktop') && getMTEXpref('UTF8Output') && ...
      ~any(startsWith(name,getMTEXpref('overbarFonts',{}),'IgnoreCase',true))
    fprintf(['The command window font %s may not centre the bar in 1%s. ' ...
      'Try showOverbars(''cycle'') to find one that does, or set UTF8Output ' ...
      'to false in mtex_settings.m.\n'],name,ov);
  end
  return
elseif ~check_option(varargin,'cycle')
  fprintf('%-28s %s\n',name,sample);
  return
end

f = figure('Visible','off'); t = text(axes(f),0,0,'','Units','pixels');
closeFigure = onCleanup(@() close(f));
restore = onCleanup(@() setFont([]));
good = {}; keep = ''; shown = '';
for n = setdiff(listfonts,'Symbol').'
  % skip the variants of the font just shown and proportional fonts
  if startsWith(n{1},[shown ' ']) || ...
      textWidth(t,n{1},'iiii') ~= textWidth(t,n{1},'WWWW'), continue; end
  shown = n{1};
  setFont(n{1});
  fprintf('%-28s %s\n',n{1},sample);
  key = [lower(input('  Enter next, y centred, k keep this font, q quit: ','s')) ' '];
  if any(key(1) == 'yk'), good{end+1} = n{1}; end %#ok<AGROW>
  if key(1) == 'k', keep = n{1}; end
  if any(key(1) == 'kq'), break; end
end
clear restore
if ~isempty(keep), setFont(keep); end

if isempty(good), return; end
setMTEXpref('overbarFonts',unique([getMTEXpref('overbarFonts',{}),good],'stable'));
fprintf('\nTo keep these fonts in the list, put into mtex_settings.m\n  setMTEXpref(''overbarFonts'',{%s});\n',...
  strjoin(strcat('''',getMTEXpref('overbarFonts'),''''),','));

end


function [name,setFont] = commandWindowFont
% name of the command window font and a function setting it, [] restores it

FP = 'com.mathworks.services.FontPrefs';
isCW = false;
if usejava('desktop') && usejava('jvm')
  % the Java desktop keeps the command window font in a font item of its own
  items = cell(javaMethod('getRegisteredComponents',FP).toArray);
  isCW = cellfun(@(it) strcmp(char(it.getPrefsTag),'Desktop.Font.CommandWindow'),items);
end

if any(isCW)
  font = javaMethod('getFontForComponent',FP,items{isCW}.getComponentName);
  name = char(font.getFamily);
  type0 = items{isCW}.getFontType; custom0 = items{isCW}.getCustomFont;
  custom = javaMethod('valueOf',[FP '$FontType'],'CUSTOM');
  setFont = @setItem;
else
  s = settings; code = s.matlab.fonts.codefont.Name;
  name = code.ActiveValue;
  setFont = @setCode;
end

  function setItem(n)
    if isempty(n)
      saveItems(custom,custom0); saveItems(type0,custom0);
    else
      saveItems(custom,java.awt.Font(n,font.getStyle,font.getSize));
    end
  end

  function saveItems(type,f)
    % hand over copies of all font items, as the preferences dialog does
    v = java.util.Vector;
    for k = 1:numel(items)
      c = javaObject([FP '$FontItem'],items{k}.getComponentName,items{k}.getPrefsTag,...
        items{k}.getFontType,items{k}.getCustomFont);
      if isCW(k), c.setFontType(type); c.setCustomFont(f); end
      v.add(c);
    end
    javaMethod('saveCustomFonts',FP,v);
  end

  function setCode(n)
    if isempty(n), n = name; end
    code.PersonalValue = n;
  end

end


function w = textWidth(t,name,str)
% width of str in the font name

set(t,'FontName',name,'String',str);
w = t.Extent(3);

end
