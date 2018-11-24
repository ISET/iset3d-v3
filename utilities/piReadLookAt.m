function line = piReadLookAt(fName)
% Read a pbrt scene file and returns the whole lookAt or ConcatTransform line
%
% Syntax
%   line = piReadLookAt(fName)
%
% Required
%   fName - full path to the pbrt scene file
% 
% Question:  Is ConcatTransform the same as world2Cam?
%
% Example
%{
fname = which('teapot-area-light.pbrt');
piReadLookAt(fname)
%}
% AJ Oct/2017

%%
line = [];
fid = fopen(fName);
tline = fgetl(fid);

while ischar(tline)    
    if piContains(tline, 'Transform') ||piContains(tline, 'ConcatTransform')
        line = tline;
    end
    if piContains(tline, 'WorldBegin')
        break;
    end
    tline = fgetl(fid);
end

end