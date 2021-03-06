
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


starting_total = 0;
keyCounterbal = 1;


test = 0;

% Testing Session 1 currently
if test == 1;
    
    p_number = 1;
    exptSession = 2;
    colBalance = 1;
    p_age = 25;
    p_sex = 'm';
    p_hand = 'r';
    datafilename = ['ExptData\CirclesMultiDataP', p_number, 'S'];
    bonus_payment = 10;q
    
else 
    
    % Not going to need these validation checks, set off participant
    % details
    
    p_number = DATA.participant;
    exptSession = DATA.session;
    
    inputError = 1;

    while inputError == 1
        inputError = 0;

        % checks if there is a folder named 'ExptData'
        if exist('ExptData', 'dir') ~= 7
            mkdir('ExptData');  % if not, make it
        end

        datafilename = ['ExptData\CirclesMultiDataP', p_number, 'S'];

        if exist([datafilename, exptSession, '.mat'], 'file') == 2
            disp(['Session ', exptSession, ' data for participant ', p_number,' already exist'])
            inputError = 1;
        end

        if str2num(exptSession) > 2
            disp(['Incorrect session number'])
            inputError = 1;
        elseif str2num(exptSession) > 1
            if exist([datafilename, '1.mat'], 'file') == 0
                disp(['No session 1 data for participant ', p_number])
                inputError = 1;
            end
            if exist([datafilename, '1.mat'], 'file') == 0
                disp(['No session 1 data for participant ', p_number])
                inputError = 1;
            end
        end

    end
    
end


if test == 0
    % First Session
    if str2num(exptSession) == 1
        
        colBalance = DATA.counterbalance;
        p_age = DATA.age;
        p_sex = DATA.gender;
        p_hand = DATA.hand;
      
    % Second Session
    else

        load([datafilename, '1.mat'])
        colBalance = DATA.counterbal;
        p_age = DATA.age;
        p_sex = DATA.gender;
        p_hand = DATA.hand;
        
        if isfield(DATA, 'bonusSoFar')
            starting_total = DATA.bonusSoFar;
        else
            starting_total = 0;
        end

        disp (['Age:  ', p_age])
        disp (['Sex:  ', p_sex])
        disp (['Hand:  ', p_hand])

    end
else
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

if test == 0

    initialInstructionsSpatial;

    [~] = runTrialsSpatial(0);     % Practice phase

    save(datafilename, 'DATA');

    if exptSession == 1
        DrawFormattedText(MainWindow, 'Please fetch the experimenter', 'center', 'center' , white);
        Screen(MainWindow, 'Flip');

        RestrictKeysForKbCheck(KbName('t'));   % Only accept T key to continue
        KbWait([], 2);
    end

    exptInstructionsSpatial;

    bonus_payment = runTrialsSpatial(1);

    awareInstructionsSpatial;
    awareTest;
    
else
    % do nothing
end

%% THIS NEEDS TO CHANGE

bonus_payment = bonus_payment/100;    % 10 000 points = $1
bonus_payment = 10 * ceil(bonus_payment/10);        % ... round this value UP to nearest 10 cents
bonus_payment = bonus_payment / 100;    % ... then convert back to dollars

if test == 1
    bonus_payment = 10;
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

