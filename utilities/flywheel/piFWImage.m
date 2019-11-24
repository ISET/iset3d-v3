function rgb = piFWImage(ieObject)
% Make a JPG image from OI data stored on Flywheel
%
% Syntax
%    pwFWImage(???)
%
% Description
%  The JPG image is created and then placed in the acquisition where
%  the OI is stored on Flywheel.
%
% See also
%

%{
oiDat = fullfile(piRootPath,'local','city4_9_30_v0.0_f40.00front_o270_mesh.dat');

oiDat = fullfile(piRootPath,'local','city4_9_30_v0.0_f40.00front_o270_depth.dat'); 

% Chdir to the right place ...
ieObject = piDat2ISET(oiDat,...
    'label','radiance',...
    'recipe',thisR,...
    'scaleIlluminance',false);
oiWindow(ieObject);
%}

%% Open it up in the window???

% oiWindow(ieObject);
% ieObject = oiSet(ieObject,'displaymode','hdr');

% Maybe this is all we need to do.
img = oiGet(ieObject,'rgb');
% ieNewGraphWin; imagescRGB(img);

rgb = imresize(img,[480 640]);
rgb = hdrRender(rgb);
% ieNewGraphWin; imagescRGB(rgb);

%% Save it out and upload it
name = oiGet(ieObject,'name');
imwrite(rgb,[name,'.jpg']);

%% END
