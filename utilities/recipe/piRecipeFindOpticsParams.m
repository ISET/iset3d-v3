function [focalLength, fNumber, metadata] = piRecipeFindOpticsParams(recipe)
% Search through a recipe for optics parameters to use in the ISET optical image.
%
% Syntax:
%    [focalLength, fNumber, metadata] = piRecipeFindOpticsParams(recipe)
%
% Despcription
%  We are trying to add a 'metadata' slot to the lens file and put
%  these values there.  Less reliably, we have some means for finding
%  them in the file name.
%
% Input
%  recipe
%
% Return
%    focalLength - meters
%    fNumber     - dimensionless
%    filmDiag    - meters
%
% TL, SCIEN Stanford, 2017
%
% See also:
%   piOICreate

focalLength = [];
fNumber     = [];
metadata    = false;

% Should check for pinhole
if(~isfield(recipe.camera,'lensfile'))
    warning('Recipe does not contain a lens file. Therefore, optics parameters cannot be found.')
    return;
end

% Now returns with the extension (json or dat)
lensName = recipe.get('lensfile');

% If we are using the realistic eye, we skip this step since the
% lens file is unique
if(strcmp(recipe.camera.subtype,'realisticEye'))
    return;
end

% Check for the metadata slot.  Mostly it should be there.
thisLens = jsonread(lensName);
if isfield(thisLens,'metadata')
    metadata = true;
    focalLength = thisLens.metadata.focalLength;
    fNumber     = thisLens.metadata.fNumber;
    return;
end

% If we get here, we try to extract from the file name. Not preferred.
try
    fprintf('Decoding lens parameters from lens file name %s\n',lensName);
    % Guess focal length (effective) from lens name
    focalLength = str2double(extractBetween(lensName,'deg.','mm'));
    focalLength = focalLength*10^-3; % meters
    
    % See if we have an aperture diameter set. If not, we'll have to
    % extract the maximum aperture value from the lens file, since PBRT
    % will default to the max aperture.
    if(isfield(recipe.camera,'aperturediameter') || isfield(recipe.camera,'aperture_diameter'))
        apertureDiameter = recipe.get('aperturediameter');
    else
        
        % These lines are directly from fileRead.m in isetlens. However
        % they are have been simplified so that we don't have to use a lens
        % class and don't require the user to have isetlens.
        
        % Read the lens file
        fid = fopen(recipe.camera.lensfile.value);
        import = textscan(fid, '%s%s%s%s', 'delimiter' , '\t');
        fclose(fid);
        
        % First find the start of the lens line, marked "#   radius"
        firstColumn = import{1};
        continueRead = true;
        dStart = 1;   % Row where the data entries begin
        while(continueRead && dStart <= length(firstColumn))
            compare = regexp(firstColumn(dStart), 'radius');
            if(~(isempty(compare{1})))
                continueRead = false;
            end
            dStart = dStart+1;
        end
        
        % Read the surface semi-diameters
        semiDiam = str2double(import{4});
        semiDiam = semiDiam(dStart:length(firstColumn));
        if sum(isnan(semiDiam)) > 0
            warning('Error reading lens file aperture');
            lst = find(isnan(semiDiam));
            fprintf('Bad indices %d\n',lst);
        end
        
        % Read the radii (aka 1/curvature)
        radius = str2double(import{1});
        radius = radius(dStart:length(firstColumn));
        if sum(isnan(radius)) > 0
            warning('Error reading lens file radius');
            lst = find(isnan(radius));
            fprintf('Bad indices %d\n',lst);
        end
        
        % Find the zero radius line. This is (probably) the aperture.
        zeroRadiusIndex = find(radius == 0);
        if(length(zeroRadiusIndex) ~= 1)
            error('Error finding max aperture size in lens file.');
        end
        apertureDiameter = semiDiam(zeroRadiusIndex);
    end
    
    fNumber = focalLength/(apertureDiameter*10^-3);
    
    %{
    % Try to get the film properties
    % Though is this the right idea when we have a lens???
    filmDiag = recipe.get('film diagonal')*10^-3;
    
    res = recipe.get('film resolution');
    x = res(1); y = res(2);
    
    d = sqrt(x^2 + y^2);         % Number of samples along the diagonal
    fwidth= (filmDiag / d) * x;  % Diagonal size by d gives us mm per step
    fov = 2 * atan2d(fwidth / 2, focalLength);
    
    success = 1;
    %}
    
catch
    warning('Could not determine optics parameters from recipe. Using OI default parameters.')
end

end