function r = checkEulerAngleConvention(conv1,conv2)


conventions = {'Matthies nfft ZYZ ABG Roe','Bunge ZXZ','Kocks' 'Canova'};

r = all(cellfun(@isempty,strfind(conventions,conv2)) == ...
  cellfun(@isempty,strfind(conventions,conv1)));
