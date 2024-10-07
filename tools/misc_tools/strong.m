function str = strong(str)
% makes a string strong

  if ~getMTEXpref("generatingHelpMode")
    str = "<strong>"+str+"</strong>";
  end

end