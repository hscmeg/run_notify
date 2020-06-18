function [  ] = notify( message )
%run_notify
%
% Sends an alert using pushover to the specified device in pushover_parameters.mat

if exist('pushover_parameters.mat', 'file')
    load('pushover_parameters.mat', 'API_TOKEN', 'USER_TOKEN');
    
    cname = gethostname;
    title = ['Message from ', cname];
    
    post_params = {'token', API_TOKEN,...       % API token
                   'user', USER_TOKEN,...       % user's ID token
                   'message', message,...       % message to push
                   'title', title};             % message title in notification bar
           
    webwrite('https://api.pushover.net/1/messages.json', post_params{:});
end

% Display local message
fprintf([message, '\n']);

end

