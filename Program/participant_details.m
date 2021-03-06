%% participant_details

% conditions is an optional argument if you want to set counterbalancing.
% Needs to be a cell array containing the range of possible values for each
% condition, e.g. {[1:3] [1:4]} means there are 2 conditions, the first
% with 3 possible values and the second with 4.

% sessions is an optional argument for the number of experimental sessions.
% Default is 1. 

% bonus is an optional logical if the experiment includes a performance
% bonus. Default is false.

% needs to have global DATA declared in invoking program, that's what it
% will save the information to.

% bonus_session, bonus_total, & finish are updated by the update_details
% function, which needs to be run at the end of the experimental program

%% code

function [] = participant_details(conditions, sessions, bonus)

%     % variable declarations
%     global DATA  % needs to be in invoking program/function too
%     global testing  % for debugging
    
    
    % set any missing inputs
    if nargin < 3
        bonus = false;  % default, no bonus
    end
        
    if nargin < 2
        sessions = 1;  % default, 1 experimental session
    end
    
    if nargin < 1
        conditions = {};  % default, no conditions
    end
    
    
    % check inputs
    if ~isa(conditions, 'cell')
        error('conditions must be a cell')
    end
    
    if ~isa(sessions, 'double')
        error('sessions must be a double')
    end
    
    if ~isa(bonus, 'logical')
        error('bonus must be a logical')
    end
    
    
    % data storage    
    % identifying information stored separately for anonymity
    if exist('participant_details', 'dir') ~= 7  % check for participant details directory
        mkdir('participant_details')  % make it if it doesn't exist
    end
    
    if exist('raw_data', 'dir') ~= 7  % check for raw_data directory
        mkdir('raw_data')  % make it if it doesn't exist
    end
        
    % details Map - participant details stored here
    details = containers.Map('UniformValues', false);
    
    % experiment Map - experiment data stored here
    experiment = containers.Map({'start'}, {datestr(now, 0)}, 'UniformValues', false);
    
    
    % data validation
    % inputs are compared to options set here using ismember() and rejected if invalid
    gender_options = 'MmOoWw';
    hand_options = 'AaLlRr';
    accept_options = 'Yy';
    reject_options = 'Nn';
    
    
    % data check loop - these loops will repeat until a valid input is given
    while true
        
        commandwindow;  % moves cursor to command window

        % number loop
        while true

            try
                number = input('Participant number --> ', 's');  % storing this as a string to stop Matlab accepting expressions or named variables as inputs
            catch
                % do nothing with errors, number loop will repeat
            end

            % validation
            if str2double(number) > 0  % only accept positive values
                details('number') = number;  % add to details Map
                experiment('number') = number;  % add to experiment Map
                break  % exit the number loop
            else
                % do nothing, number loop will repeat
            end

        end  % number loop


        % sessions
        if sessions > 1  % number of experimental sessions, not the current session

            % session loop
            while true

                try
                    session = input('Session number --> ', 's');  % stored as a string to stop Matlab accepting expressions or named variables as inputs
                catch
                    % do nothing with errors, session loop will repeat
                end

                % validation
                if str2double(session) <= sessions
                    break  % exit the session loop
                else
                    % do nothing, session loop will repeat
                end

            end  % session loop

        else

            session = '1';

        end  % if sessions
        
        experiment('session') = session;  % add to experiment Map

        
        % filenames
        details_filename = ['participant_details/participant', number];
        details('details_filename') = details_filename;  % add to details Map
        
        data_filename = ['raw_data/participant', number, 'session'];  % data_filename doesn't include session number to make it easier to check for previous session's data        

        
        % check for existing datafile
        if exist([data_filename, session, '.mat'], 'file') == 2
            
            clc;
            data_exists = 'Session %c data for participant %c already exists.\n\n';
            fprintf(data_exists, session, number);
            % data check loop will repeat
            
        else
            
            if str2double(session) == 1  % first session
                
                if testing == 0  % experimental version
                
                    % age loop
                    while true

                        try
                            age = input('Participant age --> ', 's');  % stored as a string to stop Matlab accepting expressions or named variables as inputs
                        catch
                            % do nothing with errors, age loop will repeat
                        end

                        % validation
                        if str2double(age) > 0  % only accept positive values
                            details('age') = age;  % add to details Map
                            break  % exit the age loop
                        else
                            % do nothing, age loop will repeat
                        end

                    end  % age loop


                    % gender loop
                    while true

                        try
                            gender = input('Participant gender (use first letter): man/other/woman --> ', 's');  % stored as a string to stop Matlab accepting expressions or named variables as inputs
                        catch
                            % do nothing with errors, hand loop will repeat
                        end

                        % validation
                        if ismember(gender, gender_options)

                            % probably a better way to do this
                            if strcmp(gender, 'M') || strcmp(gender, 'm')
                                gender = 'man';
                            elseif strcmp(gender, 'O') || strcmp(gender, 'o')
                                gender = 'other';
                            elseif strcmp(gender, 'W') || strcmp(gender, 'w')
                                gender = 'woman';
                            end

                            details('gender') = gender;  % add to details Map
                            break  % exit gender loop

                        else
                            
                            % do nothing, gender loop will repeat
                            
                        end  % if validation

                    end  % gender loop


                    % hand loop
                    while true

                        try
                            hand = input('Participant dominant hand (use first letter): ambidextrous/left/right --> ', 's');  % stored as a string to stop Matlab accepting expressions or named variables as inputs
                        catch
                            % do nothing with errors, hand loop will repeat
                        end

                        % validation
                        if ismember(hand, hand_options)

                            % probably a better way to do this
                            if strcmp(hand, 'A') || strcmp(hand, 'a')
                                hand = 'ambidextrous';
                            elseif strcmp(hand, 'L') || strcmp(hand, 'l')
                                hand = 'left';
                            elseif strcmp(hand, 'R') || strcmp(hand, 'r')
                                hand = 'right';
                            end

                            details('hand') = hand;  % add to details Map

                            break  % exit hand loop

                        else
                            
                            % do nothing, hand loop will repeat
                            
                        end  % if validation

                    end  % hand loop
                
                elseif testing == 1  % testing version
                    
                    details('age') = '25';
                    details('gender') = 'man';
                    details('hand') = 'right';
                    % Andy
                
                else
                    
                    error('variable "testing" isn''t set properly');
                    
                end  % if testing
                
                
                % save participant details
                save(details_filename, 'details');

                
                % Counterbalance
                % TODO: the counterbalancing here should probably
                % increment by a different amount each time if there is
                % more than one condition but I don't have time to build
                % that right now
                if numel(conditions) > 0
                    
                    % blank array to store values
                    counterbalance = zeros(1, numel(conditions));
                    
                    for a = 1:numel(conditions)  % for each condition,
                        % number is divided by the number of possible
                        % values for that condition. Add 1 to shift floor
                        % up from 0 (if number is perfectly divisible by 1)
                        counterbalance(1, a) = mod(str2double(number), conditions{a}(end)) + 1;
                    end
                    
                    experiment('counterbalance') = counterbalance;
                    
                end  % if counterbalance
                
                % bonus
                if bonus 
                    experiment('bonus_session') = 0;
                    experiment('bonus_total') = 0;                
                end
                
                break  % exit the data check loop
            
            % check for previous session data
            else  % not the first session
                
                if exist([data_filename, num2str(str2double(session) - 1), '.mat'], 'file') ~= 2  % missing previous data

                    clc;
                    data_missing = 'Previous session (%c) data does not exist for participant %c.\n\n';
                    fprintf(data_missing, num2str(str2double(session) -1), number);
                    % data check loop will repeat

                else  % check previous session's data
                    
                    clc;
                    
                    % participant details
                    load([details_filename, '.mat'], 'details');

                    disp('Previous session details:')
                    disp(['Participant:      ', details('number')])
                    disp(['Age:              ', details('age')])
                    disp(['Gender:           ', details('gender')])
                    disp(['Hand:             ', details('hand')])
                    
                    if testing == 1
                        disp(['Details filename: ', details('details_filename')])
                    end
                    
                    % experiment data
                    load([data_filename, num2str(str2double(session) - 1), '.mat'], 'DATA');
                    
                    disp(['Session:          ', DATA.experiment('session')])
                    disp(['Start time:       ', DATA.experiment('start')])
                    
                    if isKey(DATA.experiment, 'finish')  % for testing, won't throw an error if it doesn't exist
                        disp(['Finish time:      ', DATA.experiment('finish')])
                    end
                    
                    % TODO: calculate duration in update_details
%                     if isKey(DATA.experiment, 'duration')  % for testing, won't throw an error if it doesn't exist
%                         disp(['Duration:         ', DATA.experiment('duration')])
%                     end
                    
                    if isKey(DATA.experiment, 'bonus_session')  % won't exist for experiments without a bonus
                        disp(['Session bonus:    ', num2str(DATA.experiment('bonus_session'))])
                    end
                    
                    if isKey(DATA.experiment, 'bonus_total')  % won't exist for experiments without a bonus
                        disp(['Total bonus:      ', num2str(DATA.experiment('bonus_total'))])
                    end
                    
                    if testing == 1
                        disp(['Counterbalance:   ', num2str(DATA.experiment('counterbalance'))])
                        disp(['Data filename:    ', DATA.experiment('data_filename')])
                    end
                    
                    
                    % confirm loop
                    while true
                        
                        try
                            confirm = input('Are these details correct? (y/n) --> ', 's');
                        catch
                            % do nothing with errors, confirm loop will repeat
                        end
                        
                        if ismember(confirm, accept_options) || ismember(confirm, reject_options)
                            break  % exit the confirm loop
                        else
                            % do nothing, confirm loop will repeat
                        end
                        
                    end  % confirm loop
                    
                    if ismember(confirm, accept_options)
                        
                        % set values from last session's data
                        if isKey(DATA.experiment, 'counterbalance')
                            experiment('counterbalance') = DATA.experiment('counterbalance');
                        end
                        
                        if isKey(DATA.experiment, 'bonus_session')
                            experiment('bonus_session') = 0;  % reset to 0
                        end
                        
                        if isKey(DATA.experiment, 'bonus_total')
                            experiment('bonus_total') = DATA.experiment('bonus_total');
                        end
                        
                        clear DATA;  % get rid of previous session's data
                        
                        break  % exit the data check loop
                        
                    else
                        
                        clc;
                        clear DATA;
                        % rejected details, data check loop will repeat
                        
                    end  % if confirm

                end  % if previous data
                
            end  % if session
           
        end  % if existing data
        
    end  % data check loop

    
    % filename
    data_filename = [data_filename, session];  % include session now
    experiment('data_filename') = data_filename;  % add to experiment Map
   
    
    % save DATA
    DATA.experiment = experiment;
    save(data_filename, 'DATA');
    

end  % participant_details
