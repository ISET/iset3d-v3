function line = piReadLookAt(fName)
% Return a lookAt or ConcatTransform line from a read PBRT scene file.
%
% Syntax:
%   line = piReadLookAt(fName)
%
% Description:
%    Read a pbrt scene file and returns the entirety of the lookAt or
%    ConcatTransform line. (Note: Exits when encountering WorldBegin')
%
% Inputs:
%    fName - String. The full path to the pbrt scene file.
%
% Outputs:
%    line  - String. The relevant lookAt or ConcatTransform line from the
%            specified PBRT scene file.
%
% Optional key/value pairs:
%    None.
%
% Notes:
%    * Is ConcatTransform the same as world2Cam?
%

% History:
%    10/XX/17  AJ   Created Oct/2017
%    03/26/19  JNM  Documentation pass, pulled options to cell array.

% Examples:
%{
    fname = which('teapot-area-light.pbrt');
    piReadLookAt(fname)
%}

%%
line = [];
fid = fopen(fName);
tline = fgetl(fid);
opts = {'Transform', 'ConcatTransform'};

while ischar(tline)
    if piContains(tline, opts(1)) || piContains(tline, opts(2))
        line = tline;
    end
    if piContains(tline, 'WorldBegin'), break; end
    tline = fgetl(fid);
end

end