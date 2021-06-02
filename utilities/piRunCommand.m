function [status, result, exception] = piRunCommand(command, varargin)
%% Run a system command, capture results or display them live.
%
% [status, result, exception] = piRunCommand(command, 'hints', hints)
% executes the given command string using Matlab's built-in
% system() function, and attempts to capture status codes and messages that
% result.  Attempts to never throw an exception.  Instead, captures and
% returns any exception thrown.
%
% If the given hints.isCaptureCommandResults is false, allows Matlab to
% print command results to the Command Window immediately as they happen,
% instead of capturing them.
%
% Returns the numeric status code and string result from the system()
% function.  The result may be empty, if hints.isCaptureCommandResults is
% false.  Also returns any exception that was thrown during command
% execution, or empty [] if no exception was thrown.
%
%%% RenderToolbox4 Copyright (c) 2012-2016 The RenderToolbox Team.
%%% About Us://github.com/RenderToolbox/RenderToolbox4/wiki/About-Us
%%% RenderToolbox4 is released under the MIT License.  See LICENSE file.

%%
parser = inputParser();
parser.addRequired('command', @ischar);
parser.addParameter('verbose', 2, @isnumeric);
parser.parse(command, varargin{:});

command = parser.Results.command;
verbosity = parser.Results.verbose;

% Default returns.  Empty is good.
status    = [];
result    = '';
exception = [];

%%
if verbosity > 1
    fprintf('Docker command\n\t%s\n', command);
end

% Capture the status and results
try
    if ispc
        % There is a much better way to invoke docker+pbrt on Windows
        % We can use '-echo' to get Stdout to the Matlab Command Window
        % and therefore don't need either the TTY or the Pause command
        % It doesn't seem to have any downside, but the old code is also
        % below.
        % Ideally we'd have a single point where the docker command is
        % created, and fix it there, but it is created in multiple places
        % so we remove the TTY flag here:
        %        [status, result] = system(strcat(command,' &'));
        %        pause(20);
        command = strrep(command,"-ti","-i");
        command = strrep(command,"-it", "-i");
        if verbosity > 2
            [status, result] = system(command,'-echo');
        else
            [status, result] = system(command); % don't display pbrt output
        end
    else
        [status, result] = system(command);
    end
catch exception
end

end
