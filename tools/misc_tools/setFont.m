function setFont(s)

%FontName = "Consolas";
%FontName = "Nimbus Mono PS";
FontName = "Monospaced"; % most condensed
%FontName = "Noto Sans Mono Light";
%FontName = "Source Code Pro ExtraLight";
%FontName = "Source Code Pro Light";
javaLangString = java.lang.String(FontName);
javaAwtFont = java.awt.Font(javaLangString,0,s);

%com.mathworks.services.Prefs.setFontPref('Desktop.Font.Code2',javaAwtFont);
com.mathworks.services.FontPrefs.setCodeFont(javaAwtFont)

end