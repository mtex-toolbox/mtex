function fr = ownFrame
% the frame an image gets when it has none of its own
%
% Which specimen a picture is of is not derivable from the array, so an
% image that arrives on its own is given a frame that says exactly that: its
% axes are named iX, iY, iZ rather than X, Y, Z, so that every display shows
% at a glance that they are the image's axes and not the specimen's. The
% relation to anything else is left to transformReferenceFrame.
%
% A fresh, unregistered instance every time - two images that know nothing
% about each other must not end up sharing one by accident.
%
% See also
% mapImage mapImage/transformReferenceFrame specimenFrame

fr = specimenFrame('image','axesNames',{'iX','iY','iZ'},plottingConvention.ij);

end
