function oi = piFindAndRemoveFireflies(oi,varargin)

% piFindAndRemoveFireflies - Find and remove "fireflies" from an optical
% image. 
%
%    oi = piFindAndRemoveFireflies(oi, ...)
%
% piFindAndRemoveFireflies scans an optical image for "fireflies," bright
% specular points within a scene that are a result of rendering noise. We
% assume that the OI given does indeed have a firefly (i.e. the user has
% checked with some prior method.) It will give a series of prompts
% highlighting the firefly and asking if the user wants to remove it. It
% removes the firefly by copying and pasting neighboring pixels onto the
% firefly. This may sometimes fail if the firefly is on an edge, which is
% why we give the user many prompts. 
%
% Once all fireflies have been removed, the image is saved as an OI with
% the same name. The original OI is also saved, but renamed xxx_RAW.mat.
% 
% Required inputs
%   oi - an optical image with a firefly/fireflies.
%
% Return
%   oi - an optical image with fireflies removes. 
%
%
% TL Scienstanford 2017

%%
p = inputParser;
p.addRequired('oi',@(x)(isstruct(x)));
p.parse(oi,varargin{:});

%%

continueFindingOutlier = true;
tempoi = oi;

while(continueFindingOutlier == true)
    
    rgbImage = oiGet(tempoi,'rgb');
    
    photons = oiGet(tempoi,'photons');
    meanPhotons = mean(photons,3);
    [~, indexMaxPhotons] = max(meanPhotons(:));
    
    % Show firefly to user
    figure(1); clf;
    [I,J] = ind2sub(size(rgbImage),indexMaxPhotons);
    sizeCrop = 2;
    imshow(rgbImage); hold on;
    rectangle('Position',[J-sizeCrop,I-sizeCrop, sizeCrop*2, sizeCrop*2]);
    title('Is this a firefly? You may have to zoom in to see.')
    
    str = input('Is this boxed location a firefly? (y/n) \n','s');
    
    if(strcmp(str,'y'))
        
        % Copy the next patch over to cover the firefly
        goodPhotons = photons((I-sizeCrop:I+sizeCrop),(J-sizeCrop:J+sizeCrop)-(sizeCrop*2),:);
        photons((I-sizeCrop:I+sizeCrop),(J-sizeCrop:J+sizeCrop),:) = goodPhotons;
        tempoi = oiSet(tempoi,'photons',photons);
        
        rgbImage = oiGet(tempoi,'rgb');
        figure(2); clf;
        imshow(rgbImage); hold on;
        rectangle('Position',[J-sizeCrop,I-sizeCrop, sizeCrop*2, sizeCrop*2]);
        title('Is the firefly gone now? If so press enter.')
        pause;
        
    end
    
    str = input('Continue looking for fireflies in this image? (y/n) \n','s');
    if(strcmp(str,'n'))
        oi = tempoi; 
        continueFindingOutlier = false;
    else
        continueFindingOutlier = true;
    end
    
end

end

