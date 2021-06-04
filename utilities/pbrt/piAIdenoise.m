function [object, results] = piAIdenoise(object,varargin)
% A denoising method (AI based) that applies to scene photons
%
% Synopsis
%   [object, results] = piAIdenoise(object)
%
% Inputs
%   object:  An ISETCam scene or oi
%
% Optional key/value
%   quiet - Do not show the waitbar
%
% Returns
%   object: The ISETCam object (scene or optical image) with the photons
%           denoised is returned 
%
% Description
%   This routine is to run a denoiser (oidn_pth) on rendered images when
%   we only use a small number of rays.  This denoiser makes the images
%   look better.  It is not used for true simulations of sensor data.
%
%   This is a Monte Carlo denoiser based on a trained model from intel open
%   image denoise: 'https://www.openimagedenoise.org/'. 
%
%   Ultimately, this will become a docker image that can integrate with
%   PBRT. 
%
% See also
%   sceneWindow, oiWindow

%% Parse
p = inputParser;
p.addRequired('object',@(x)(isequal(x.type,'scene') || isequal(x.type,'opticalimage')));
p.addParameter('quiet',false,@islogical);

p.parse(object,varargin{:});

quiet = p.Results.quiet;

%%  Get the data

% [rows, cols, chs] = size(object.data.photons);
switch object.type
    case 'opticalimage'
        wave = oiGet(object,'wave');
        photons = oiGet(object,'photons');
        [rows,cols,chs] = size(photons);
    case 'scene'
        wave = sceneGet(object,'wave');
        photons = sceneGet(object,'photons');
        [rows,cols,chs] = size(photons);
    otherwise
        error('Should never get here.  %s\n',object.type);
end

% Not sure why ZL does this?  Also, Why the normalization?  Probablyl a
% requirement of the denoiser, which needs the data between 0 and 1?
% Could we do this in photon space and save the conversion? (BW).
energy = Quanta2Energy(wave, photons);

%% Set up the denoiser path information

oidn_pth  = fullfile(piRootPath, 'external', 'oidn-1.3.0.x86_64.macos', 'bin');
outputTmp = fullfile(piRootPath,'local','tmp_input.pfm');
DNImg_pth = fullfile(piRootPath,'local','tmp_dn.pfm');
NewEnergy = zeros(rows, cols, chs);

if ~quiet, h = waitbar(0,'Denoising multispectral data...','Name','Intel denoiser'); end
for ii = 1:chs
    img_sp(:,:,1) = energy(:,:,ii)/max2(energy(:,:,ii));
    img_sp(:,:,2) = img_sp(:,:,1);
    img_sp(:,:,3) = img_sp(:,:,1);
    writePFM(img_sp, outputTmp);
    cmd  = [oidn_pth, '/oidnDenoise --hdr ', outputTmp, ' -o ',DNImg_pth];
    [~, results] = system(cmd);
    DNImg = readPFM(DNImg_pth);
    NewEnergy(:,:,ii) = DNImg(:,:,1).* max2(energy(:,:,ii));
    if ~quiet, waitbar(ii/chs, h,sprintf('Spectral channel: %d nm \n', wave(ii))); end
end
if ~quiet, close(h); end

object.data.photons = Energy2Quanta(wave, NewEnergy);

if exist(DNImg_pth,'file'), delete(DNImg_pth); end
if exist(outputTmp,'file'), delete(outputTmp); end

end
