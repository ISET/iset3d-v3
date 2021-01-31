function [name, sz] = piParseObjectName(txt)
% Parse an ObjectName string in 'txt' to extract the object name and size.
%
% Cinema4D produces a line with #ObjectName in it. The format of the
% #ObjectName line appears to be something like this:
%
%   #ObjectName Plane:Vector(5000, 0, 5000)
%
% The only cases we have seen are NAME:Vector(X,Z,Y).  Someone seems to
% know the meaning of these three values which are read into 'res' below.
% The length is 2*X, width is 2*Y and height is 2*Z.
% 
% Perhaps these numbers should always be treated as in meters or maybe
% centimeters?  We need to figure this out.  For the slantedBar scene we
% had the example above, and we think the scene might be about 100 meters,
% so this would make sense.
%
% We do not have a routine to fill in these values for non-Cinema4D
% objects.


% Find the location of #ObjectName in the string
pattern = '#ObjectName';
loc = strfind(txt,pattern);

% Look for a colon
pos = strfind(txt,':');
name = txt(loc(1)+length(pattern) + 1:max(pos(1)-1, 1));

posA = strfind(txt,'(');
posB = strfind(txt,')');
res = sscanf(txt(posA(1)+1:posB(1)-1),'%f, %f, %f');

% Position minimima and maxima for lower left (X,Y), upper right.
sz.pmin = [-res(1) -res(3)];
sz.pmax = [res(1) res(3)];

% We are not really sure what these coordinates represent with respect to
% the scene or the camera direction.  For one case we analyzed (a plane)
% this is what the values meant.
sz.l = 2*res(1);   % length (X)
sz.w = 2*res(2);   % depth (Z)
sz.h = 2*res(3);   % height (Y)

end