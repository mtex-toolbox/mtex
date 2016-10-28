function linkText = varlink(var,name)
% link to a variable

if getMTEXpref('generatingHelpMode')
  linkText = name;
else
  %linkText = ['<a href="matlab:display(' var ')">' name '</a>'];
  linkText = ['<a href="matlab:' var '">' name '</a>'];
end