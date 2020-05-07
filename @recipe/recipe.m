classdef recipe < matlab.mixin.Copyable
% The recipe class contains essential information to render PBRT files
%
% Syntax
%   thisR = recipe;
%
% Default version is no PBRT version 3.
%
% TL Scien Stanford, 2017

% PROGRAMMING TODO
%
%  Perhaps this class should be piRecipe.m
%
%  I think we should align the words here with the terms in PBRT.  So, for
%  example, integrator should be SurfaceIntegrator.  Then we should have the
%  permissible list of terms included.  Again, for SurfaceIntegrator in V2 these
%  appear to be described in http://www.pbrt.org/fileformat.html

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
        
        % INPUTFILE -  Original input file
        inputFile = '';   
        
        outputFile = ''; % Where outputFile = piWrite(recipe);
        version = 3;     % A PBRTv2 file or a PBRTv3 file
        materials;       % struct containing info about the materials, parsed from *_material.pbrt file
        textures;        % struct containing info about the textures used in the scene
        assets;          % assets list parsed from *_geometry.pbrt file
        exporter = '';
        metadata;
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
        
        function val = set(obj,varargin)
            % Sets parameters of the recipe.  Shortens the set call, mainly, and
            % does some parameter value checking.
            val = recipeSet(obj,varargin{:});
        end
        
    end
    
end
