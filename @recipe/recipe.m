classdef recipe < matlab.mixin.Copyable
% The recipe class contains essential information to render PBRT files
%
% Syntax
%   thisR = recipe;
%
% Default version is PBRT version 3.
%
% TL Scien Stanford, 2017

%% PROGRAMMING TODO
%
%  Perhaps this class should be piRecipe.m
%
%  I think we should align the words here with the terms in PBRT.  So, for
%  example, integrator should be SurfaceIntegrator.  Then we should have
%  the permissible list of terms included.  Again, for SurfaceIntegrator in
%  V2 these appear to be described in http://www.pbrt.org/fileformat.html

%%
    properties (GetAccess=public, SetAccess=public)
        % Can be set by user
        %
        % These are all structs that contain the parameters necessary
        % for piWrite to convert the structs to text output in the
        % scene.pbrt file.
        
        % CAMERA - struct of camera parameters, including the lens
        % file
        camera;     
        sampler;     % Sampling algorithm.  Only a few are allowed
        film;        % Equivalent to ISET sensor
        filter;      % Usually pixel filter
        integrator;  % Usually SurfaceIntegrator
        renderer;    %
        lookAt;      % from/to/up struct
        scale;       % Optional scale factor to flip handedness
        world;       % A cell array with all the WorldBegin/End contents
        lights;       % Light sources
        transformTimes; % Transform start and end time
        
        % INPUTFILE -  
        inputFile = '';    % Original PBRT input file
        outputFile = '';   % Where outputFile = piWrite(recipe);
        renderedFile = ''; % Where piRender puts the radiance
        version = 3;     % A PBRTv2 file or a PBRTv3 file
        materials;       % struct containing info about the materials, parsed from *_material.pbrt file
        textures;        % struct containing info about the textures used in the scene
        assets;          % assets list parsed from *_geometry.pbrt file
        exporter = '';
        media;           % Volumetric rendering media.
        metadata;
        recipeVer = 2;
        
        verbose = 2;    % default for how much debugging output to emit.
    end
    
    properties (Dependent)
    end
    
    methods
        % Constructor
        function obj = recipe(varargin)
            % Who knows what we will do in the future.
        end
        
        function val = get(obj,varargin)
            % Returns derived parameters of the recipe that require some
            % computation
            val = recipeGet(obj,varargin{:});
        end
        
        function [obj, val] = set(obj,varargin)
            % Sets parameters of the recipe.  Shortens the set call, mainly, and
            % does some parameter value checking.
            [obj, val] = recipeSet(obj,varargin{:});
        end
        
        function oFile = save(thisR,varargin)
            % Save the recipe in a mat-file.
            % By default, save it as sceneName-recipe.mat  in the input
            % directory. 
            %
            % recipe.save('recipeFileName');
            
            if ~isempty(varargin)
                oFile = varargin{1};
            else                
                oFile = thisR.get('input basename');
                oFile = sprintf('%s-recipe',oFile);
                
                oDir = thisR.get('input dir');
                oFile = fullfile(oDir,oFile);
            end
            
            save(oFile,'thisR');
        end
        
        function jsonFile = savejson(thisR,varargin)
            % Save the recipe in a mat-file.
            % By default, save it as sceneName-recipe.mat  in the input
            % directory. 
            %
            % recipe.save('recipeFileName');
            
            if ~isempty(varargin)
                jsonFile = varargin{1};
            else                
                jsonFile = thisR.get('input basename');
                jsonFile = sprintf('%s-recipe',jsonFile);
                
                oDir = thisR.get('input dir');
                jsonFile = fullfile(oDir,jsonFile);
            end

            [p,n,e] = fileparts(jsonFile);
            if ~isequal(e,'.json')
                disp('Adding json extension to file name');
                jsonFile = fullfile(p,[n,'.json']);
            end
            jsonwrite(jsonFile,thisR);
        end
        
        function T = show(obj,varargin)
            %
            % thisR.show('assets) - Brings up a window
            % thisR.show('object materials') - Prints a table (returns T,
            %              too)
            %
            % Optional 
            %   assets (or nodes)
            %   node names
            %   object materials
            %   object positions
            %   object sizes
            %   materials
            %   lights
 
            if isempty(varargin), showType = 'assets';
            else,                 showType = varargin{1};
            end
            
            T = [];
            
            % We should probably use nodes and objects/assets distinctly
            switch ieParamFormat(showType)
                case {'assets','nodes'}
                    % Brings up the window that you can click through
                    % showing all the nodes.
                    if isempty(obj.assets), disp('No assets in this recipe');
                    else, obj.assets.show;
                    end
                case 'nodenames'
                    % List all the nodes, not just the objects
                    names = obj.get('asset names')';
                    rows = cell(numel(names),1);
                    for ii=1:numel(names), rows{ii} = sprintf('%d',ii); end
                    T = table(categorical(names),'VariableNames',{'assetName'}, 'RowNames',rows);
                    disp(T);
                case {'objects'}
                    % Tabular summary of object materials, positions, sizes
                    names = obj.get('object names')';
                    matT   = obj.get('object materials');
                    coords = obj.get('object coordinates');
                    oSizes = obj.get('object sizes');
                    positionT = cell(size(names));
                    sizeT = cell(size(names));
                    for ii=1:numel(names), positionT{ii} = sprintf('%.2f %.2f %.2f',coords(ii,1), coords(ii,2),coords(ii,3)); end
                    for ii=1:numel(names), sizeT{ii} = sprintf('%.2f %.2f %.2f',oSizes(ii,1), oSizes(ii,2),oSizes(ii,3)); end
                    T = table(matT, positionT, sizeT,'VariableNames',{'material','positions (m)','sizes (m)'}, 'RowNames',names);
                    disp(T);
                case {'objectmaterials','objectsmaterials','assetsmaterials'}
                    % Prints out a table of just the materials
                    piAssetMaterialPrint(obj);
                case {'objectpositions','objectposition','assetpositions','assetspositions'}
                    % Print out the positions
                    names = obj.get('object names')';
                    coords = obj.get('object coordinates');
                    positionT = cell(size(names));
                    for ii=1:numel(names), positionT{ii} = sprintf('%.2f %.2f %.2f',coords(ii,1), coords(ii,2),coords(ii,3)); end
                    T = table(positionT,'VariableNames',{'positions (m)'}, 'RowNames',names);
                    disp(T);
                case {'objectsizes','assetsizes','objectsize'}
                    names = obj.get('object names')';
                    sizeT = cell(size(names));
                    oSizes = obj.get('object sizes');
                    for ii=1:numel(names), sizeT{ii} = sprintf('%.2f %.2f %.2f',oSizes(ii,1), oSizes(ii,2),oSizes(ii,3)); end
                    T = table(sizeT,'VariableNames',{'sizes (m)'}, 'RowNames',names);
                    disp(T);
                case 'materials'
                    % Prints a table
                    piMaterialPrint(obj);
                case 'lights'
                    % Prints a table
                    piLightPrint(obj);
                otherwise
                    error('Unknown show %s\n',varargin{1});
            end
            
        end
    end
    
end
