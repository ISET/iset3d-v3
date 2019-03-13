function thisR = recipeSet(thisR, param, val, varargin)
% Set a recipe class value
%
% Syntax
%   thisR = recipeSet(thisR, param, val, varargin)
%
% Description:
%   The recipe class manages the PBRT rendering parameters.  The class
%   has many fields specifying camera and rendering parameters. This
%   method is only capable of setting one parameter at a time.
%
% BW ISETBIO Team, 2017
%
% See also
%    recipeGet

% Examples
%{
  thisR.set('lensFile','dgauss.22deg.3.0mm.dat')
%}

%% Set up
if isequal(param,'help')
    doc('recipe.recipeSet');
    return;
end

p = inputParser;
p.KeepUnmatched = true;

vFunc = @(x)(isequal(class(x),'recipe'));
p.addRequired('thisR',vFunc);
p.addRequired('param',@ischar);
p.addRequired('val');

p.addParameter('lensfile','dgauss.22deg.12.5mm.dat',@(x)(exist(x,'file')));

p.parse(thisR, param, val, varargin{:});

param = ieParamFormat(p.Results.param);

%% Act 
switch param
    
    % Rendering and Docker related
    case {'outputfile'}
        % Is there already an output file set? If so, copy all directories
        % over to the new directory.
        if(~strcmp(thisR.outputFile,val) && strcmp(thisR.exporter,'C4D'))
            [dirsource,~,~] = fileparts(thisR.outputFile);
            [dirdest,~,~] = fileparts(val);
            fprintf('Output directory changed! Copying files from %s to %s \n',...
                dirsource,dirdest);
            if(~exist(dirdest,'dir'))
                % Sometimes the output directory has not been created yet.
                mkdir(dirdest);
            end
            if(~exist(dirsource,'dir'))
                warning('Source directory does not exist anymore.')
            elseif(~strcmp(dirsource,dirdest))
                copyfile(dirsource,dirdest);
                rmdir(dirsource,'s');
            end
        end
        thisR.outputFile = val;
        
    case {'inputfile'}
        thisR.inputFile = val;   
        % Scene
    case 'objectdistance'
        % Adjust the lookat 'from' field to match the distance in val
        objDirection = thisR.get('object direction');
        
        % Make the unit vector a val distance away and add
        newDirection = objDirection*val;
        thisR.lookAt.from = thisR.lookAt.to + newDirection;
        
        % Camera
    case 'camera'
        % Initialize a camera type with default parameters
        % To adjust the parameters use recipe.set() calls
        thisR.camera = piCameraCreate(val,'lensFile',p.Results.lensfile, ...
            'pbrtVersion',thisR.version);
        
        % If version number is 3, add the film diagonal into the Film
        if(thisR.version == 3)
            thisR.film.diagonal.value = 35;
            thisR.film.diagonal.type = 'float';
        end
        
    case 'cameratype'
        thisR.camera.subtype = val;
    case 'lensfile'
        if(thisR.version == 3)
            thisR.camera.lensfile.value = val;
            thisR.camera.lensfile.type = 'string';
        elseif(thisR.version == 2)
            thisR.camera.specfile.value = val;
            thisR.camera.specfile.type = 'string';
        end
    case {'aperture','aperturediameter'}
        if(thisR.version == 3)
            thisR.camera.aperturediameter.value = val;
            thisR.camera.aperturediameter.type = 'float';
        elseif(thisR.version == 2)
            thisR.camera.aperture_diameter.value = val;
            thisR.camera.aperture_diameter.type = 'float';
        end
    case {'filmdistance'}
            thisR.camera.filmdistance.value = val;
            thisR.camera.filmdistance.type = 'float';
    case {'focusdistance'}
        if(thisR.version == 3)
            thisR.camera.focusdistance.value = val;
            thisR.camera.focusdistance.type = 'float';
        else
            warning('focus distance parameter not applicable for version 2');
        end
    case 'lookat'
        % Includes the from, to and up in a struct
        if isstruct(val) &&  isfield(val,'from') && isfield(val,'to')
            thisR.lookAt = val; 
        end
    case 'fov'
        % We should check that this is a pinhole, I think
        thisR.camera.fov.value = val;
        thisR.camera.fov.type = 'float';
        
    case 'diffraction'
        if(thisR.version == 2)
            thisR.camera.diffractionEnabled.value = val;
            thisR.camera.diffractionEnabled.type = 'bool';
        elseif(thisR.version == 3)
            warning('diffraction parameter not applicable for version 3')
        end
        
    case 'chromaticaberration'
        if(thisR.version == 2)
            thisR.camera.chromaticAberrationEnabled.value = val;
            thisR.camera.chromaticAberrationEnabled.type = 'bool';
            
            % Set chromatic aberration correctly
            thisR.renderer.subtype = 'spectralrenderer';

        elseif(thisR.version == 3)
            thisR.camera.chromaticAberrationEnabled.value = val;
            thisR.camera.chromaticAberrationEnabled.type = 'bool';
            
            thisR.integrator.subtype = 'spectralpath';
            if(ischar(val))
                % User probably put in true or false, so let's just use a
                % default of 8 bands.
                warning('Using a default of 8 sampled bands for the chromatic aberration.');
                thisR.integrator.numCABands.value = 8;
                thisR.integrator.numCABands.type = 'integer';
            else
                thisR.integrator.numCABands.value = val;
                thisR.integrator.numCABands.type = 'integer';
            end
            
        end
    case 'from'
        thisR.lookAt.from = val;
    case 'to'
        thisR.lookAt.to = val;
    case 'up'
        thisR.lookAt.up = val;
        
    case 'autofocus'
        % thisR.set('autofocus',true);
        % Sets the film distance so the lookAt to point is in good focus
        if val
            fdist = thisR.get('focal distance');
            if isnan(fdist)
                error('Camera is probably too close (%f) to focus.',thisR.get('object distance'));
            end
            thisR.set('film distance',fdist);
        end
    case 'microlens'
        % Not sure about what this means.  It is on or off
        thisR.camera.microlens_enabled.value = val;
        thisR.camera.microlens_enabled.type = 'float';
    case 'nmicrolens'
        % Number of microlens/pinhole samples for a light field camera
        %
        if length(val) == 1, val(2) = val(1); end
        thisR.camera.num_pinholes_h.value = val(1);
        thisR.camera.num_pinholes_h.type = 'float';
        thisR.camera.num_pinholes_w.value = val(2);
        thisR.camera.num_pinholes_w.type = 'float';
    case 'lightfieldfilmresolution'
        % This is printed out in the pbrt scene file
        nMicrolens = thisR.get('n microlens');
        nSubpixels = thisR.get('n subpixels');
        thisR.set('film resolution', nMicrolens .* nSubpixels);
    case 'nsubpixels'
        % How many pixels behind each microlens/pinhole
        % The type is not included because this is not passed to pbrt.
        thisR.camera.subpixels_h = val(1);
        thisR.camera.subpixels_w = val(2);
        
        % Film
    case 'filmresolution'
        % This is printed out in the pbrt scene file
        if length(val) == 1, val(2) = val(1); end
        thisR.film.xresolution.value = val(1);
        thisR.film.yresolution.value = val(2);
    case {'filmdiagonal','diagonal'}
        if(thisR.version == 2)
            thisR.camera.filmdiag.value = val(1);
            thisR.camera.filmdiag.type = 'float';
        elseif(thisR.version == 3)
            thisR.film.diagonal.value = val(1);
            thisR.film.diagonal.type = 'float';
        end
    case {'pixelsamples','raysperpixel'}
        % Sampler
        thisR.sampler.pixelsamples.value = val;
    case{'cropwindow','crop window'}
        thisR.film.cropwindow.value = [val(1) val(2) val(3) val(4)];
        thisR.film.cropwindow.type = 'float';
    case{'maxdepth','bounces'}
        % Eliminated warning Nov. 11, 2018.
        if(~strcmp(thisR.integrator.subtype,'path'))
            % warning('Changing integrator sub type to "path"');
        end
        thisR.integrator.maxdepth.value = val(1);
        thisR.integrator.maxdepth.type = 'integer';
        % When there are multiple bounces, apply this integrator
        thisR.integrator.subtype = 'path';
    otherwise
        error('Unknown parameter %s\n',param);
end
 
