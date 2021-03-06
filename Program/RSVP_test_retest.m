sca;

% no idea what this does
% PVar = 'DYLD_LIBRARY_PATH';
% PVal = getenv(PVar);
% nVal = [ '/opt/X11/lib:', PVal ];
% setenv(PVar, nVal);

commandwindow;  % for testing, can type sca to exit

% variable declarations
global DATA exptName MainWindow
global bColour white screenWidth screenHeight
global cueBalance
global soundPAhandle winSoundArray loseSoundArray
global datafilename

% Andy's additions
global testing startingTotal

exptName = 'RSVP_test_retest';

bColour = [0 0 0];  % black
white = [255, 255, 255];

KbName('UnifyKeyNames');    % Supposedly important to standardise keyboard input across platforms / OSs.

%% Back to more sensible things

functionFoldername = fullfile(pwd, 'RSVP_functions');  % Generate file path for "functions" folder in current working directory
addpath(genpath(functionFoldername));  % Then add path to this folder and all subfolders

imageFoldername = fullfile(pwd, 'RSVP_images');  % Generate file path for "images" folder in current working directory
addpath(genpath(imageFoldername));  % Then add path to this folder and all subfolders

InitializePsychSound;

[winSoundArrayMono, sndFreq] = audioread('winSound.wav');     % read in win sound
[loseSoundArrayMono, sndFreq] = audioread('loseSound.wav');     % read in lose sound

winSoundArray = [winSoundArrayMono, winSoundArrayMono];
loseSoundArray = [loseSoundArrayMono, loseSoundArrayMono];

testVersion = testing;

if testVersion == 1     % Parameters for development / debugging
%     Screen('Preference', 'SkipSyncTests', 2);      % Skips the Psychtoolbox calibrations
    Screen('Preference', 'SkipSyncTests', 1);
    screenNum = 0;
    soundLatency = 0;
else     % Parameters for running the real experiment
    Screen('Preference', 'SkipSyncTests', 0);
    screenNum = 0;
    soundLatency = 1;
end    


soundPAhandle = PsychPortAudio('Open', [], 1, soundLatency, sndFreq);


% confirm options
accept_options = 'Yy';
reject_optins = 'Nn';

% confirm loop
while true  % loops until a break statement is encountered
    
    % check sound volume
    PsychPortAudio('FillBuffer', soundPAhandle, winSoundArray');
    PsychPortAudio('Start', soundPAhandle);
    
    try
        confirm = input('Is volume OK? (y/n) --> ', 's');
    catch
        % do nothng with errors, confirm loop will repeat
    end
    
    if ismember(confirm, accept_options)
        break  % exit the confirm loop
    else
        % do nothing, confirm loop will repeat
    end
    
end

% % original sound check from Mike
% keyResponse = 'a';
% while keyResponse ~= 'y' && keyResponse ~= 'Y' && keyResponse ~= 'n' && keyResponse ~= 'N' 
%     PsychPortAudio('FillBuffer', soundPAhandle, winSoundArray');
%     PsychPortAudio('Start', soundPAhandle);
%     keyResponse = input('Is volume OK? (y / n / blank to hear again) ---> ', 's');
%     if isempty(keyResponse); keyResponse = 'a'; end
% end
% 
% if keyResponse == 'n' || keyResponse == 'N'
%     fprintf(1, '\nQuitting script. Change volume and then run the script again.\n\n');
%     PsychPortAudio('Close', soundPAhandle);
%     clear all;
%     return
% end

% % original data dir from Mike
% Check to see if subject data folder exists; if not, create it.
datafoldername = ['SubjData_', exptName];
if exist(datafoldername, 'dir') == 0
    mkdir(datafoldername);
end
  
p_number = experiment('number');
session = experiment('session');
cueBalance = experiment('counterbalance');

datafilename = [datafoldername, '/', exptName, '_dataP', num2str(p_number), 'S', session, '.mat'];

% startingTotal
if strcmp(session, '1')  % first session
    startingTotal = 0;
elseif strcmp(session, '2')  % second session
    load(['SubjData_RSVP_test_retest/RSVP_test_retest_dataP', p_number, 'S1'], 'DATA')  % doesn't scale but that's ok
    startingTotal = DATA.amountTotal; % set startingTotal from previous session
    clear DATA;
else
    error('variable "session" isn''t set properly')
end

    
%% original data check from Mike
%     inputError = 1;
%     
%     while inputError == 1
%         inputError = 0;
%         
%         p_number = input('Participant number  ---> ');
%         
%         datafilename = [datafoldername, '/', exptName, '_dataP', num2str(p_number), '.mat'];
%         
%         if exist(datafilename, 'file') == 2
%             disp(['Data for participant ', num2str(p_number),' already exist'])
%             inputError = 1;
%         end
%         
%     end
%     
%     cueBalance = 0;
%     while cueBalance < 1 || cueBalance > 2
%         cueBalance = input('Cue counterbalance (1-2) ---> ');      % 1 = birds rewarded, 2 = cars rewarded
%         if isempty(cueBalance); cueBalance = 0; end
%     end
%     
%     
%     p_sex = 'a';
%     while p_sex ~= 'm' && p_sex ~= 'f' && p_sex ~= 'M' && p_sex ~= 'F'
%         p_sex = input('Participant gender (M/F) ---> ', 's');
%         if isempty(p_sex); p_sex = 'a'; end
%     end
%     
%     p_age = input('Participant age ---> ');
% 
DATA.subject = p_number;
DATA.cueBal = cueBalance;
% DATA.age = p_age;
% DATA.sex = p_sex;
DATA.start_time = datestr(now,0);


DATA.session_bonus = 0;
DATA.session_points = 0;
DATA.actualBonusSession = 0;
DATA.totalBonus = 0;

    
% generate a random seed using the clock, then use it to seed the random
% number generator
rng('shuffle');
randSeed = randi(30000);
rsvp('random_seed') = randSeed;
DATA.rSeed = randSeed;
rng(randSeed);



%% Set up screens

MainWindow = Screen(screenNum, 'OpenWindow', bColour);

DATA.frameRate = round(Screen(MainWindow, 'FrameRate'));

Screen('TextFont' , MainWindow ,'Segoe UI' );
Screen('TextSize', MainWindow, 46);
Screen('TextStyle', MainWindow, 0);


[screenWidth, screenHeight] = Screen('WindowSize', MainWindow);

HideCursor;

instrWindow = Screen('OpenOffscreenWindow', MainWindow, bColour);
Screen('TextFont', instrWindow, 'Segoe UI');
Screen('TextStyle', instrWindow, 0);
Screen('TextSize', instrWindow, 40);

%% Read in images

global rewardImages numRewardImages
global neutImages numNeutImages
global baselineImages numBaselineImages
global targetImages numTargetImages targetRotation

% TODO: check the counterbalancing grid here
if session == '1'  % birds and bikes
    
%     [imageTexture, numImages, targetRotation] function == readinImages(inputFoldername, readingTargetImages);
    
    if cueBalance == 1 || cueBalance == 3
        [rewardImages, numRewardImages, targetRotation] = readInImages([imageFoldername, '/BIRDPICS'], 0);
        [neutImages, numNeutImages, targetRotation] = readInImages([imageFoldername, '/BICYCLEPICS'], 0);
    elseif cueBalance == 2 || cueBalance == 4
        [rewardImages, numRewardImages, targetRotation] = readInImages([imageFoldername, '/BICYCLEPICS'], 0);
        [neutImages, numNeutImages, targetRotation] = readInImages([imageFoldername, '/BIRDPICS'], 0);
    else
        error('cueBalance isn''t set properly');
    end
    
elseif session == '2'  % cars and chairs
    
    if cueBalance == 1 || cueBalance == 2
        [rewardImages, numRewardImages, targetRotation] = readInImages([imageFoldername, '/CHAIRPICS'], 0);
        [neutImages, numNeutImages, targetRotation] = readInImages([imageFoldername, '/CARPICS'], 0);
    elseif cueBalance == 3 || cueBalance == 4
        [rewardImages, numRewardImages, targetRotation] = readInImages([imageFoldername, '/CARPICS'], 0);
        [neutImages, numNeutImages, targetRotation] = readInImages([imageFoldername, '/CHAIRPICS'], 0);
    else
        error('cueBalance isn''t set properly');
    end
    
else
    error('session isn''t set properly');
end


% % original counterbalancing
% if cueBalance == 1
%     [rewardImages, numRewardImages, ~] = readInImages([imageFoldername, '\BIRDPICS'], 0);
%     [neutImages, numNeutImages, ~] = readInImages([imageFoldername, '\CARPICS'], 0);
% else
%     [rewardImages, numRewardImages, ~] = readInImages([imageFoldername, '\CARPICS'], 0);
%     [neutImages, numNeutImages, ~] = readInImages([imageFoldername, '\BIRDPICS'], 0);
% end

[baselineImages, numBaselineImages, targetRotation] = readInImages([imageFoldername, '/ColourScenes'], 0);
[targetImages, numTargetImages, targetRotation] = readInImages([imageFoldername, '/EBY_Targets'], 1);

DATA.numRewardImages = numRewardImages;
DATA.numNeutImages = numNeutImages;
DATA.numBaselineImages = numBaselineImages;
DATA.numTargetImages = numTargetImages; 


%% Run experiment
if testing == 0  % experimental version
    startSecs = GetSecs;

    % add a session check
    showInstructions1;

    [~, ~] = runTrials(1);    % Practice with no salient distractors


    % add a session check
    showInstructions2;
    [rewardPropCorrect, runningTotalPoints] = runTrials(2);    % Main expt starts

elseif testing == 1  % experimental version
    startSecs = GetSecs;
    
    showInstructions1;
    
    [~, ~] = runTrials(1);
    
    showInstructions2;
%     [rewardPropCorrect, runningTotalPoints] = runTrials(2);    % Main expt starts    
    
    rewardPropCorrect = 1;  % not sure about the type
    runningTotalPoints = 1000;  % idk if this is even close to a real value
    
else 
    error('variable "rewardPropCorrect" isn''t set properly')
end
    
amountEarned = rewardPropCorrect * 7.5;  % Amount earned in dollars (0.5 correct gives $3, 1 correct gives $6)

amountEarned = amountEarned * 100;  % change to cents
amountEarned = 10 * ceil(amountEarned/10);  % round this value UP to nearest 10 cents
amountEarned = amountEarned / 100;  % then convert back to dollars


% change this across the whole experiment
if amountEarned > 6.25    % This shouldn't be possible, but you never know
    amountEarned = 6.25;
elseif amountEarned < 3     % This is here in case there are any very unlucky dolts
    amountEarned = 3;
end

fid1 = fopen([datafoldername,'/_TotalBonus_summary.csv'], 'a');
fprintf(fid1,'%d,%d,%f,%f\n', p_number, runningTotalPoints, rewardPropCorrect, amountEarned);
fclose(fid1);

PsychPortAudio('Close', soundPAhandle);

% Mike data
DATA.end_time = datestr(now,0);
DATA.exptDuration = GetSecs - startSecs;

% Andy
DATA.amountSession = amountEarned;  % check this
DATA.amountTotal = startingTotal + amountEarned;  % check this

save(datafilename, 'DATA');

% Andy data
experiment('rsvp') = DATA;
update_details(experiment, amountEarned);

Screen('Flip',MainWindow);
[~, ny, ~] = DrawFormattedText(MainWindow, ['TASK COMPLETE\n\nPoints earned = ', separatethousands(runningTotalPoints, ','), '\n\nCash bonus = $', num2str(amountEarned, '%0.2f'), '\n\nTotal cash bonus for this task = $', num2str(DATA.amountTotal, '%0.2f'), '\n\nPlease fetch the experimenter'], 'center', 'center' , white, [], [], [], 1.3);
Screen('Flip',MainWindow);

rmpath(genpath(functionFoldername));       % remove path to this folder and all subfolders
rmpath(genpath(imageFoldername));       % remove path to this folder and all subfolders

RestrictKeysForKbCheck(KbName('ESCAPE'));   % Only accept escape key to quit
KbWait([], 2);
RestrictKeysForKbCheck([]); % Re-enable all keys


Screen('Preference', 'SkipSyncTests',0);

ShowCursor;

% Close all windows.
Screen('ClearAll');
Screen('CloseAll');

% clear all;