function object = piAIdenoise(object)
% This is a monte carlo denoiser based on a trained model from intel open
% image denoise: 'url here'
% This will become a docker image
%
%
if ~strcmp(object.type, 'opticalimage') && ...
        ~strcmp(object.type, 'scene')
    error('not a valid input, only support opticalimage and scene.')
end
[rows, cols, chs] = size(object.data.photons);
wave = 400:10:700; 
energy = Quanta2Energy(wave, object.data.photons);
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
    waitbar(ii/chs, h,sprintf('Denoise Spectral Plane: %d \n', 400+(ii-1)*10));
end
close(h);
object.data.photons = Energy2Quanta(wave, NewEnergy);
end