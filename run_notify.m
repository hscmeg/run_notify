function [  ] = run_notify( script_name )
%run_notify
%
% Runs the specified script, and sends a Pushover notification to the given
% user token after completion, or upon an error.

%% Parameters
if exist('pushover_parameters.mat', 'file')
    load pushover_parameters.mat
end

%% Script

cname = gethostname;
tElapsed = tic;

try
    evalin('base', script_name);
    tElapsed = toc(tElapsed);
    
    title = ['Execution Success on ', cname];
    message = sprintf('Execution success: %s\nTime Elapsed: %.1fs', script_name, tElapsed);
catch exception
    tElapsed = toc(tElapsed);
    
    title = ['Execution Error on ', cname];
    message = sprintf('Error executing %s!\n---\n%s\n---\nTime Elapsed: %.1fs', script_name, exception.message, tElapsed);
    cprintf('red', getReport(exception));
end

cprintf('blue', '\n---\nExecution Complete: %s\nTime Elapsed: %.1fs\n---\n', script_name, tElapsed);

if exist('API_TOKEN', 'var')
    post_params = {'token', API_TOKEN,...    % API token
                   'user', USER_TOKEN,...    % user's ID token
                   'message', message,...    % message to push
                   'title', title};          % message title in notification bar

    urlread('https://api.pushover.net/1/messages.json', 'Post', post_params);
end

end

