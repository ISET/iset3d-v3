function object = piAIdenoise(object)
% A denoising method (AI based) that applies to scene photons
%
% Synopsis
%
% Inputs
%   object:  Either a scene or oi from ISETCam
%
% Optional key/value
%   N/A
%
% Returns
%   object: The object with the photons denoised is returned
%
% Description
%   This routine is to run a denoiser (oidn_pth) on rendered images when
%   we only use a small number of rays.  This denoiser makes the images
%   look better.  It is not used for true simulations of sensor data.
%
%   This is a Monte Carlo denoiser based on a trained model from intel open
%   image denoise: 'url here'. This will become a docker image that can
%   integrate with PBRT.
%
% See also

%%
if ~strcmp(object.type, 'opticalimage') && ...
        ~strcmp(object.type, 'scene')
    error('not a valid input, only support opticalimage and scene.')
end

%%
[rows, cols, chs] = size(object.data.photons);
wave = 400:10:700; 
energy = Quanta2Energy(wave, object.data.photons);

%% Set up the denoiser

oidn_pth = fullfile(piRootPath, 'external', 'oidn-1.3.0.x86_64.macos', 'bin');
outputTmp = fullfile(piRootPath,'local','tmp_input.pfm');
DNImg_pth = fullfile(piRootPath,'local','tmp_dn.pfm');
NewEnergy = zeros(rows, cols, chs);

h = waitbar(0,'Denoising multispectral data...');
for ii = 1:chs
    img_sp(:,:,1) = energy(:,:,ii)/max2(energy(:,:,ii));
    img_sp(:,:,2) = img_sp(:,:,1);
    img_sp(:,:,3) = img_sp(:,:,1);
    writePFM(img_sp, outputTmp);
    cmd  = [oidn_pth, '/oidnDenoise --hdr ', outputTmp, ' -o ',DNImg_pth];
    [status, results]=system(cmd);
    DNImg = readPFM(DNImg_pth);
    NewEnergy(:,:,ii) = DNImg(:,:,1).* max2(energy(:,:,ii));
    waitbar(ii/chs, h,sprintf('Denoise Spectral Plane: %d nm \n', 400+(ii-1)*10));
end

close(h);
object.data.photons = Energy2Quanta(wave, NewEnergy);

end