function [trial_list] = generate_trial_list()
% generate trial list string and randomise for data capture. For
% randomisation, use randperm(N) where N is the number of rows, and
% randperm(N) creates a vector of randomised order of integers from 1:N
%
% ----------------------------------------------------------------------- %
% Created: 29/11/2019
% ----------------------------------------------------------------------- %
% Simnon Thwaites
% simonthwaites1991@gmail.com
% ----------------------------------------------------------------------- %

trial_list_1 = "Calibration - Static";

trial_list_2 = ["Max_iso_quad - Affected"; ...
                "Max_iso_quad - Unaffected"];

% randomise by rows            
trial_list_2 = trial_list_2(randperm(size(trial_list_2, 1)), :);

trial_list_start = [trial_list_1; trial_list_2];

trial_list_3 = ["Timed up-and-go"; ...
                "Timed sitting leg extension - Affected"; ...
                "Timed sitting leg extension - Unaffected"];
trial_list_3 = trial_list_3(randperm(size(trial_list_3, 1)), :); % randomise      

trial_list_4 = ["Anterior reach - Affected"; ...
                "Anterior reach - Unaffected"; ...
                "Squatting"; ...
                "Single leg hop - Affected"; ...
                "Single leg hop - Unaffected"; ...
                "Triple leg hop - Affected"; ...
                "Triple leg hop - Unaffected"];
trial_list_4 = trial_list_4(randperm(size(trial_list_4, 1)), :); % randomise

trial_list_5 = "Gait";

trial_list_middle = {trial_list_3; trial_list_4; trial_list_5};
trial_list_middle = trial_list_middle(randperm(size(trial_list_middle, 1)), :); % randomise
trial_list_middle = [trial_list_middle{1}; trial_list_middle{2}; trial_list_middle{3}];

trial_list_6 = ["No pads - kneeling - AWB - flexed"; ...
                "No pads - kneeling - AWB - upright"; ...
                "No pads - kneeling - Reach - flexed"; ...
                "No pads - kneeling - Reach - upright"];
trial_list_6 = trial_list_6(randperm(size(trial_list_6, 1)), :); % randomise

% MIGHT NEED RECALIBRATION IN HERE

trial_list_7 = ["Pads - kneeling - AWB - flexed"; ...
                "Pads - kneeling - AWB - upright"; ...
                "Pads - kneeling - Reach - flexed"; ...
                "Pads - kneeling - Reach - upright"];
trial_list_7 = trial_list_7(randperm(size(trial_list_7, 1)), :); % randomise

trial_list_end = [trial_list_6; trial_list_7];

trial_list = [trial_list_start; trial_list_middle; trial_list_end];  

end