test = 1;


%Screen('Preference', 'SkipSyncTests', 2 );      % Skips the Psychtoolbox calibrations - REMOVE THIS WHEN RUNNING FOR REAL!
Screen('CloseAll');

Beeper;

clc;

addpath('functions');

global MainWindow scr_centre DATA datafilename
global keyCounterbal starting_total exptSession
global distract_col colourName
global white black gray yellow
global bigMultiplier smallMultiplier
global zeroPayRT oneMSvalue nf

nf = java.text.DecimalFormat;


screenNum = 0;


zeroPayRT = 1000;       % 1000
fullPayRT = 500;        % 500
oneMSvalue = 0.1;


bigMultiplier = 10;    % Points multiplier for trials with high-value distractor
smallMultiplier = 1;   % Points multiplier for trials with low-value distractor

KbName('UnifyKeyNames');    % Important for some reason to standardise keyboard input across platforms / OSs.

starting_total = 0;
keyCounterbal = 1;




inputError = 1;

if test == 1;
    p_number = 1;
    exptSession = 1;
    colBalance = 1;
    p_age = 18;
    p_sex = 'm';
    p_hand = 'r';
else
    p_number = str2num(participant_number);
    exptSession = str2num(participant_session);
end

while inputError == 1
    inputError = 0;

    
    % checks if there is a folder named 'ExptData'
    if exist('ExptData', 'dir') ~= 7
        mkdir('ExptData');  % if not, make it
    end
    
    datafilename = ['ExptData\CirclesMultiDataP', num2str(p_number), 'S'];
    
    if exist([datafilename, num2str(exptSession), '.mat'], 'file') == 2
        disp(['Session ', num2str(exptSession), ' data for participant ', num2str(p_number),' already exist'])
        inputError = 1;
    end
    
    if exptSession > 2
        disp(['Incorrect session number'])
        inputError = 1;
    elseif exptSession > 1  % essentially: if session 2
        if exist([datafilename, num2str(exptSession - 1), '.mat'], 'file') == 0
            disp(['No session ', num2str(exptSession - 1), ' data for participant ', num2str(p_number)])
            inputError = 1;
        end
        
    end
    
end

% First Session
if exptSession == 1
    if test == 1
        colBalance = 1;
        p_age = 18;
        p_sex = 'm';
        p_hand = 'r';
    else
        colBalance = participant_counterbalance;
        p_age = participant_age;
        p_sex = participant_gender;
        p_hand = participant_hand;
    end

% Second Session
else
    
    load([datafilename, num2str(exptSession - 1), '.mat'])
    colBalance = DATA.counterbal;
    p_age = DATA.age;
    p_sex = DATA.sex;
    p_hand = DATA.hand;
    if isfield(DATA, 'bonusSoFar')
        starting_total = DATA.bonusSoFar;
    else
        starting_total = 0;
    end
        
    disp (['Age:  ', num2str(p_age)])
    disp (['Sex:  ', p_sex])
    disp (['Hand:  ', p_hand])
    
    y_to_continue = 'a';
    while y_to_continue ~= 'y' && y_to_continue ~= 'Y'
        y_to_continue = input('Is this OK? (y = continue, n = quit) --> ','s');
        if y_to_continue == 'n'
            Screen('CloseAll');
            clear all;
            error('Quitting program');
        end
    end
    
end

% clear DATA;

DATA.subject = p_number;
DATA.session = exptSession;
DATA.counterbal = colBalance;
DATA.age = p_age;
DATA.sex = p_sex;
DATA.hand = p_hand;
DATA.start_time = datestr(now,0);

% generate a random seed using the clock, then use it to seed the random
% number generator
rng('shuffle');
randSeed = randi(30000);
DATA.rSeed = randSeed;
rng(randSeed);

datafilename = [datafilename, num2str(exptSession),'.mat'];


% Get screen resolution, and find location of centre of screen
[scrWidth, scrHeight] = Screen('WindowSize',screenNum);
res = [scrWidth scrHeight];
scr_centre = res / 2;


MainWindow = Screen(screenNum, 'OpenWindow', [], [], 32);

DATA.frameRate = round(Screen(MainWindow, 'FrameRate'));

HideCursor;

Screen('Preference', 'DefaultFontName', 'Courier New');

Screen('TextSize', MainWindow, 34);

% now set colors
white = WhiteIndex(MainWindow);
black = BlackIndex(MainWindow);
gray = [70 70 70];
orange = [193 95 30];
green = [54 145 65];
blue = [37 141 165];
pink = [193 87 135];
yellow = [255 255 0];
Screen('FillRect',MainWindow, black);

distract_col = zeros(5,3);

distract_col(5,:) = yellow;       % Practice colour
if exptSession == 1
    if colBalance == 1
        distract_col(1,:) = orange;      % High-value distractor colour
        distract_col(2,:) = blue;      % Low-value distractor colour
    elseif colBalance == 2
        distract_col(1,:) = blue;
        distract_col(2,:) = orange;
    elseif colBalance == 3
        distract_col(1,:) = green;
        distract_col(2,:) = pink;
    elseif colBalance == 4
        distract_col(1,:) = pink;
        distract_col(2,:) = green;
    end
elseif exptSession == 2
    if colBalance == 1
        distract_col(1,:) = green;      % High-value distractor colour
        distract_col(2,:) = pink;      % Low-value distractor colour
    elseif colBalance == 2
        distract_col(1,:) = pink;
        distract_col(2,:) = green;
    elseif colBalance == 3
        distract_col(1,:) = orange;
        distract_col(2,:) = blue;
    elseif colBalance == 4
        distract_col(1,:) = blue;
        distract_col(2,:) = orange;
    end
end
        
distract_col(3,:) = gray;
distract_col(4,:) = gray;

for i = 1 : 2
    if distract_col(i,:) == orange
        colName = 'ORANGE    ';           % All entries need to have the same length. We'll strip the blanks off later.
    elseif distract_col(i,:) == green
        colName = 'GREEN     ';
    elseif distract_col(i,:) == blue
        colName = 'BLUE      ';
    elseif distract_col(i,:) == pink
        colName = 'PINK      ';
    elseif distract_col(i,:) == yellow
        colName = 'YELLOW    ';
    end
    
    if i == 1
        colourName = char(colName);
    else
        colourName = char(colourName, colName);
    end
end

initialInstructionsSpatial;

if test == 0
    [~] = runTrialsSpatial(0);     % Practice phase
end

save(datafilename, 'DATA');

if exptSession == 1
    DrawFormattedText(MainWindow, 'Please fetch the experimenter', 'center', 'center' , white);
    Screen(MainWindow, 'Flip');
    
    RestrictKeysForKbCheck(KbName('t'));   % Only accept T key to continue
    KbWait([], 2);
end

exptInstructionsSpatial;
    
if test == 0;
    bonus_payment = runTrialsSpatial(1);
    awareInstructionsSpatial;
    awareTest;
end



%% THIS NEEDS TO CHANGE
if test == 0
    bonus_payment = bonus_payment/100;    % 10 000 points = $1
    bonus_payment = 10 * ceil(bonus_payment/10);        % ... round this value UP to nearest 10 cents
    bonus_payment = bonus_payment / 100;    % ... then convert back to dollars
elseif test == 1
    bonus_payment = 10.00;
end

DATA.bonusSessionSpatial = bonus_payment;
DATA.bonusSoFar = bonus_payment + starting_total;

save(datafilename, 'DATA');

DrawFormattedText(MainWindow, ['Experiment complete - Please fetch the experimenter\n\n\nTotal bonus so far = $', num2str(bonus_payment + starting_total , '%0.2f')], 'center', 'center' , white);
Screen(MainWindow, 'Flip');
RestrictKeysForKbCheck(KbName('q'));   % Only accept Q key to quit
KbWait([], 2);


rmpath('functions');
Snd('Close');

%Screen('Preference', 'SkipSyncTests',0);

Screen('CloseAll');

clear all


