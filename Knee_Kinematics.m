classdef Knee_Kinematics 
    
    % Group 14 Comp App Project
    % Ada Yumiceva
    % Zoe Wexler
    % Thaisha Calixte
    % Saanvi Kodiganti

    properties
        %constants
        frame_rate = 69.9; % [frames/sec]
        body_density = 0;

        %initializing arrays
        theta21 = [];
        theta43 = [];
        theta65 = [];
        knee_angle = [];
        ankle_angle = [];
        velocity_array = zeros(106,12);
        data_array = [];
       
    end

    methods
        %functions go in here
        function obj = Knee_Kinematics()
            % constructor function
            data_array = xlsread('MarkerData.xlsx');
            assignin('base', 'data_array', data_array);
            disp("Welcome! This code helps analyze a subject's gait using the uploaded data marker set!");
            while true
                answ = input('What selection would you like to make:\n[1] Calculate Subject Body Density\n[2] Calculate Knee and Ankle Angles\n[3] Plots of Joint Angles\n');
                if answ == 1 
                    obj.Calc_BodyDensity();
                end
                if answ == 2 
                    [theta21, theta43, theta65] = obj.Angles(data_array);
                    [obj.knee_angle, obj.ankle_angle] = obj.Joint_Angles(theta21,theta43,theta65);
                end
                if answ == 3
                    [theta21, theta43, theta65] = obj.Angles(data_array);
                    [knee_angle, ankle_angle] = obj.Only_Angles(theta21,theta43,theta65);        
                    obj.plot_Angles(knee_angle,ankle_angle);
                end
                rep = input('\nOther original selection?\n', 's');
                if strcmpi(rep, 'no')
                        break; % Exit the loop
                end
            end

        end

       
        function body_density = Calc_BodyDensity(obj)
            h = input('Enter the participant''s height in meters: ');% body height [m]
            w = input('Enter the participant''s body mass in kilograms: '); % body weight [kg]
            c = h/(w^(1/3));
            % Drillis and Contini body density equation metric version
            % (page  97)
            body_density = 0.69 + 0.9*c; % units: [kg/l]
            fprintf('Your participant''s body density in [kg/liter] is: %.2f\n',body_density);
        end

        
        
        % input is data_array 
        % output theta21, theta43, and theta65 angles of thigh angle, shank
        % angle, and heel angle respectively
        function [theta21, theta43, theta65] = Angles(obj,data_array)
            theta21 = [];
            theta43 = [];
            theta65 = [];
            for ii = 1:106
                % hip coordinates x,y at frame ii
                x1 = data_array(ii,2);
                y1 = data_array(ii,3);
                % knee coordinates x,y at frame ii
                x2 = data_array(ii,4);
                y2 = data_array(ii,5);
                % fibula coordinates x,y at frame ii
                x3 = data_array(ii,6);
                y3 = data_array(ii,7);
                % ankle coordinates x,y at frame ii
                x4 = data_array(ii,8);
                y4 = data_array(ii,9);
                % heel coordinates x,y at frame ii
                x5 = data_array(ii,10);
                y5 = data_array(ii,11);
                % metatarsal coordinates x,y at frame ii
                x6 = data_array(ii,12);
                y6 = data_array(ii,13);
                
                % theta 21 is the thigh angle relative to the horizontal
                % plane(ground) it is a column vector 106 values one for
                % each frame
                calc_21 = rad2deg(atan((y1-y2)/(x1-x2)));
                theta21 = [theta21;calc_21];

                % theta 43 is the shank angle relative to the horizontal
                % plane(ground) it is a column vector 106 values one for
                % each frame
                calc_43 = rad2deg(atan((y3-y4)/(x3-x4)));
                theta43 = [theta43;calc_43];

                % theta 65 is the heel angle relative to the horizontal
                % plane(ground) it is a column vector 106 values one for
                % each frame
                calc_65 = rad2deg(atan((y5-y6)/(x5-x6)));
                theta65 = [theta65;calc_65];
            end

        end

         % calculating knee and ankle angle 
         % inputs: theta21, theta43, theta65 
         % outputs: knee_angle, ankle_angle
        function [knee_angle, ankle_angle] = Only_Angles(obj,theta21,theta43,theta65)
                knee_angle = [];
                ankle_angle = [];
                for jj = 1:106
                new_theta21 = theta21(jj);
                new_theta43 = theta43(jj);
                new_theta65 = theta65(jj);
                knee_angle = [knee_angle;new_theta21-new_theta43];
                ankle_angle = [ankle_angle;new_theta43-new_theta65+90];
                end
        end

            % calculating knee and ankle angle 
            % inputs: theta21, theta43, theta65 
            % outputs: knee_angle, ankle_angle
        function [knee_angle, ankle_angle] = Joint_Angles(obj,theta21,theta43,theta65)
                knee_angle = [];
                ankle_angle = [];
                for jj = 1:106
                new_theta21 = theta21(jj);
                new_theta43 = theta43(jj);
                new_theta65 = theta65(jj);
                knee_angle = [knee_angle;new_theta21-new_theta43];
                ankle_angle = [ankle_angle;new_theta43-new_theta65+90];
                end
                
                %Calculating knee angle at user inputted frame
                while true
                    user_frame = input('\nFind the <strong>knee angle</strong> at frame number [1-106]: ');
                    
                    %in case of user error
                    while user_frame < 1 || user_frame > 106 
                    disp('<strong>Invalid input.</strong> Please enter a frame number between 1 and 106.');
                    % Prompt the user again
                    user_frame = input('Find the <strong>knee angle</strong> at frame number [1-106]: ');
                    end

                    user_knee = knee_angle(user_frame);
                    fprintf('The knee angle at frame <strong>%d is %.2f degrees</strong>\n',user_frame,user_knee);
                    
                    % grab theta angles involved in knee angle
                    user_21 = theta21(user_frame);
                    user_43 = theta43(user_frame);
                    
                    % check flexion or extension
                    if user_21 > user_43
                        fprintf('Participant''s knee is in <strong>flexion.</strong>\n');
                    else
                        fprintf('Participant''s knee is <strong>extended.</strong>\n');
                    end

                    % Check if the user wants to continue inputting knee
                    % frames or onto next selection
                    userChoice = input('Do you want to input a <strong>different frame</strong> again? (yes/no): \n', 's');
                    if strcmpi(userChoice, 'no')
                        break; % Exit the loop
                    end
                  
                end

                % Calculating ankle angle at user inputted frame
                while true
                    user_frame2 = input('\nFind the <strong>ankle angle</strong> at frame number [1-106]: ');
                    
                    % in case of user error
                    while ~isnumeric(user_frame2) || user_frame2 < 1 || user_frame2 > 106
                    disp('<strong>Invalid input.</strong> Please enter a frame number between 1 and 106.');
                    % Prompt the user again
                    user_frame2 = input('Find the ankle angle at frame number [1-106]: ');
                    end

                    user_ankle = ankle_angle(user_frame2);
                    fprintf('The ankle angle at frame <strong>%d is %.2f degrees</strong>\n',user_frame2,user_ankle);
                    
                    % plantarflexed or dorsiflexed 
                    if user_ankle > 0
                        fprintf('Participant''s foot is <strong>plantarflexed.</strong>\n');
                    else
                        fprintf('Participant''s foot is <strong>dorsiflexed.</strong>\n');
                    end

                    % Check if the user wants to continue inputting frames
                    userChoice = input('Do you want to input a <strong>different frame</strong> again? (yes/no): \n', 's');
                    if strcmpi(userChoice, 'no')
                    break; % Exit the loop
                    end
                end
          end
          
          % Plot angles over time 
          function plot_Angles(obj,knee_angle,ankle_angle)
                time_array = 0:(1/69.9):(1/69.9 * (106-1));
                subplot(2,1,1);
                plot(time_array,knee_angle');
                title('Knee Angle Progression over Time');
                xlabel('Time [seconds]');
                ylabel('Angle [degrees]');
                
                subplot(2,1,2)
                plot(time_array,ankle_angle');
                title('Ankle Angle Progression over Time');
                xlabel('Time [seconds]');
                ylabel('Angle [degrees]');
          end
               
         end
end