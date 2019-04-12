function [status, result, exception] = piRunCommand(command, varargin)
% Run a system command, capture results or display them live.
%
% Syntax:
%   [status, result, exception] = piRunCommand(command, [varargin])
%
% Description:
%    The function executes the given command string using Matlab's built-in
%    system() function, and attempts to capture status codes and messages
%    that result. Attempts to never throw an exception. Instead, captures
%    and returns any exception thrown.
%
%    If the given hints.isCaptureCommandResults is false, allows Matlab to
%    print command results to the Command Window immediately as they
%    happen, instead of capturing them.
%
%    Returns the numeric status code and string result from the system()
%    function. The result may be empty, if hints.isCaptureCommandResults is
%    false. Also returns any exception that was thrown during command
%    execution, or empty [] if no exception was thrown.
%
% Inputs:
%    command   - String. The command to pass to the CLP/Shell prompt.
%
% Outputs:
%    status    - Numeric. The status code. Expect 0 for a pass. Default [].
%    result    - String. The result string (including error message(s)).
%                Default ''.
%    exception - Numeric. The exception code, if one exists. Default [].
%
% Optional key/value pairs:
%    None.
%
% Notes:
%	 * RenderToolbox4 Copyright (c) 2012-2016 The RenderToolbox Team.
%    * About Us://github.com/RenderToolbox/RenderToolbox4/wiki/About-Us
%    * RenderToolbox4 is released under the MIT License. See LICENSE file.
%

% History:
%    XX/XX/12  XXX  Created by RenderToolbox Team
%    03/27/19  JNM  Documentation pass.

%%
parser = inputParser();
parser.addRequired('command', @ischar);
parser.parse(command, varargin{:});
command = parser.Results.command;

% Default returns. Empty is good.
status = [];
result = '';
exception = [];

%%
fprintf('Docker command\n\t%s\n', command);
% Capture the status and results
try
    if ispc
        % On Windows machines, execute the command in a pop-up window.
        [status, result] = system(strcat(command, ' &'));
        pause(20);
    else
        [status, result] = system(command);
    end
catch exception
end

end
