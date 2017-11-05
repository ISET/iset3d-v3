%% Light field tool examples
%
% These are from the Dansereau toolbox.  They are in CISET/utility.
% 
% Convert the OI to an IP and then

% nPinholes = recipe.get('npinholes');
nPinholes = [thisR.camera.num_pinholes_h.value,thisR.camera.num_pinholes_w.value];
lightfield = ip2lightfield(ip,'pinholes',nPinholes,'colorspace','srgb');

superPixels(1) = size(lightfield,1);
superPixels(2) = size(lightfield,2);

%% Display the image from the center pixel of each microlens
img = squeeze(lightfield(3,3,:,:,:));
vcNewGraphWin; imagesc(img); truesize; axis off

%% Display the light field

% Need to add the lightfield toolbox for this to work
%
LFDispVidCirc(lightfield)

%% Display individual images

% This is a large aperture
vcNewGraphWin;
img = squeeze(sum(sum(lightfield,2),1));
imagescRGB(img);
title('Image at microlens plane')

% Now narrow the aperture, which increase the depth of field
vcNewGraphWin;
tmp = lightfield(4:6,4:6,:,:,:);
img = squeeze(sum(sum(tmp,2),1));
imagescRGB(img);
title('Image at microlens plane')
% 
% Single pixel aperture
vcNewGraphWin;
tmp = lightfield(5,5,:,:,:);
img = squeeze(sum(sum(tmp,2),1));
imagescRGB(img);
title('Image at microlens plane')
% 
%% Now what if we move the sensor forward?
% 
% This corresponds to selecting a slightly different plane for the image sensor
% by shifting the images first, and then summing.  The amount of the shift is in
% the 'Slope' parameter. Use different Slopes for the benchLF and metronomeLF
% pictures This is for metronome: Slope = -0.5:0.2:1.0;
%{
Shift = -0.5:0.5:3.0;  % BenchLF

vcNewGraphWin([],'wide');
for ii = 1:length(Shift)
    ShiftImg = LFFiltShiftSum(lightfield, Shift(ii) );
    subplot(1,length(Shift),ii);
    imagescRGB(lrgb2srgb(ShiftImg(:,:,1:3)));
    axis image;
    title(sprintf('%0.2f',Shift(ii)))
end
%}

%% The white image

% What is this fourth plane?  I think it is an overall intensity estimate.
% We need to calculate this for our simulation.  At present, it is just
% arbitrary.
wImage = ShiftImg(:,:,4);
vcNewGraphWin;
imagesc(wImage);

%%  Interact with the lightfield using the toolbox

% In this case, we use the srgb representation because we are just
% visualizing
LFDispMousePan(lightfield)


%%