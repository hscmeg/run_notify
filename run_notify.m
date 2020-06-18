function [  ] = run_notify( script_name, varargin )
%run_notify
%
% Runs the specified script, and sends a Pushover notification to the given
% user token after completion, or upon an error.

ip = inputParser;
addOptional(ip, 'DiaryDir', []);

parse(ip, varargin{:});

%% Parameters
cname = getenv('VNCDESKTOP');
tElapsed = tic;

if exist('pushover_parameters.mat', 'file')
  pparam = load('pushover_parameters.mat');
end

if ~isempty(ip.Results.DiaryDir)
  diarypath = ip.Results.DiaryDir;
elseif isfield(pparam, 'DIARY_DIR')
  diarypath = pparam.DIARY_DIR;
else
  diarypath = [];
end


if ~isempty(diarypath)
  diarypath = fullfile(diarypath, datestr(now, 'yyyymmdd'));
  
  if ~exist(diarypath, 'file')
    mkdir(diarypath);
  end
  
  sysinfo = regexprep(regexprep(cname, '[\(\)]',''), '[^a-zA-Z0-9-_.]', '_');
  diarypath = fullfile(diarypath, sprintf('%s_%s_%s.txt', datestr(now, 'HHMMSS'), sysinfo, script_name));
  
  diary(diarypath);
end

%% Script
start_str = datestr(now);
fprintf('%s started at %s on %s\n\n', script_name, start_str, getenv('VNCDESKTOP'));


try
  evalin('base', script_name);
  tElapsed = toc(tElapsed);
  
  title = ['Execution Success on ', cname];
  message = sprintf('Execution success: %s\nTime Elapsed: %.1fs', script_name, tElapsed);
catch exception
  tElapsed = toc(tElapsed);
  
  title = ['Execution Error on ', cname];
  message = sprintf('%s execution error!\n---\n%s\n---\nTime Elapsed: %.1fs', script_name, exception.message, tElapsed);
  fprintf(getReport(exception));
end

fprintf('\n---\n%s execution from %s to %s.\nTime Elapsed: %.1fs (%.2fh)\n---\n', ...
  script_name, start_str, datestr(now), tElapsed, tElapsed / 3600);

if ~isempty(diarypath)
  diary('off');
end

if exist('pparam', 'var')
  post_params = {'token', pparam.API_TOKEN,...    % API token
    'user', pparam.USER_TOKEN,...    % user's ID token
    'message', message,...    % message to push
    'title', title};          % message title in notification bar
  
  webwrite('https://api.pushover.net/1/messages.json', post_params{:});
end

end

