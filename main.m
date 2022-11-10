addpath("./Functions");
% [Blue-S Yellow-S Red-S Blue-L Yellow-L Red-L]
bins = [0 0 0 0 0 0];
totalBlocksSorted = 0;
if (exist('myev3', 'var') == 0)
    %myev3 = legoev3('WiFi', '10.245.30.70', '00165355da1e');
    myev3 = legoev3('USB');
end

drumMotor = motor(myev3, 'D');
%vibrateMotor = motor(myev3, 'B');
feedKickerMotor = motor(myev3, 'C');
drumKickerMotor = motor(myev3, 'A');

sensorColor = colorSensor(myev3, 1);
%lightSensor = colorSensor(myev3, '2');

%zeroMotor(drumMotor)33;
%vibrate(vibrateMotor);

selected = 8;

while (1)
        clearLCD(myev3);
        writeLCD(myev3, 'X', selected, 1);
        % The blocks avalible
        writeLCD(myev3, 'Large - Red', 1, 3);
        writeLCD(myev3, 'Small - Red', 2, 3);
        writeLCD(myev3, 'Large - Green', 3, 3);
        writeLCD(myev3, 'Small - Green', 4, 3);
        writeLCD(myev3, 'Large - Yellow', 5, 3);
        writeLCD(myev3, 'Small - Yellow', 6, 3);
        writeLCD(myev3, 'Push out', 7, 3);
        writeLCD(myev3, 'Sort', 8, 3);
        writeLCD(myev3, 'Move -90deg', 9, 3);
        % Amount of blocks avalible
        writeLCD(myev3, num2str(bins(1)), 1, 19);
        writeLCD(myev3, num2str(bins(2)), 2, 19);
        writeLCD(myev3, num2str(bins(3)), 3, 19);
        writeLCD(myev3, num2str(bins(4)), 4, 19);
        writeLCD(myev3, num2str(bins(5)), 5, 19);
        writeLCD(myev3, num2str(bins(6)), 6, 19);
    buttonPressed = buttonPress(myev3);

    if (buttonPressed == "up")
        if (selected > 1)
            selected = selected - 1;
            readRotation(drumMotor)
        end

    elseif (buttonPressed == "down")
        if (selected < 8)
            selected = selected + 1;
            readRotation(drumMotor)
        end

    elseif (buttonPressed == "center")
        selected

        if (selected <= 6)
            moveToStorage(selected, drumMotor, 0)
            %Kick out block manualy
        elseif (selected == 7)
            
            moveDegrees(drumKickerMotor, 70, 30);
            
            moveDegrees(drumKickerMotor, 0, 50);
        % Sorting
        elseif (selected == 8)
            % moveDegrees (drumKickerMotor, 90, 15);
            %vibrate(vibrateMotor);
            sorting = 1;
            feedKickerMotor.Speed = 5;

            while (sorting)
                feedKickerMotor.Speed = 5;
                start(feedKickerMotor);
                sensing = 1;
                resetRotation(feedKickerMotor);
                sensingStartTime = getTime();
                sensedColor = 'none';
                % 0: Small, 1: large
                sensedSize = 0;

                while (sensing)

                    if (readRotation(feedKickerMotor) > 360)
                        stop(feedKickerMotor);
                    end

                    if (timeBetween(getTime(), sensingStartTime) > 2)
                        sensing = 0;
                    end

                    curCol = readColor(sensorColor);

                    if (curCol == "blue" || curCol == "yellow" || curCol == "red")
                        sensedColor = curCol
                        sensedSize = 1
                    else
                        sensedSize = 0;

                    end

                    deltaTime = timeBetween(sensingStartTime, getTime());
                end

                % Turn drum to the drum corresponding to the seen block
                % [Blue-S Yellow-S Red-S Blue-L Yellow-L Red-L]
                if (sensedColor == "blue" || sensedColor == "yellow" || sensedColor == "red")

                    switch sensedColor
                        case 'blue'

                            if (sensedSize == 0)
                                moveToStorage(1, drumMotor, 1);
                                bins(1) = bins(1) +1;
                            else
                                moveToStorage(4, drumMotor, 1);
                                bins(4) = bins(4) +1;
                            end

                        case 'yellow'

                            if (sensedSize == 0)
                                moveToStorage(2, drumMotor, 1);
                                bins(2) = bins(2) +1;
                            else
                                moveToStorage(5, drumMotor, 1);
                                bins(5) = bins(5) +1;
                            end

                        case 'red'

                            if (sensedSize == 0)
                                moveToStorage(3, drumMotor, 1);
                                bins(3) = bins(3) +1;
                            else
                                moveToStorage(6, drumMotor, 1);
                                bins(6) = bins(6) +1;
                            end

                    end

                    totalBlocksSorted = totalBlocksSorted +1;
                end



                if (totalBlocksSorted == 10)
                    %stop(vibrateMotor);
                    sorting = 0;
                end

            end
        elseif (selected == 9)
            moveDegrees (drumKickerMotor, -90, 15);
        end

    end

end

%switch(buttonPressed)

%end
