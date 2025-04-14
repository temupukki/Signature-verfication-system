%Signature Verification System
%Abraham Fikre------------- 01143/14           
%Dagmawi Behailu----------- 02434/14
%Temesgen Gashaw------------ 01833/14
%TEST IMAGES FROM    https://cedar.buffalo.edu/NIJ/data/signatures.rar
function SignatureVerificationSystem()
    % Create a UI figure
    fig = uifigure('Position', [100, 100, 600, 400], 'Name', 'Signature Verification');

    % Create UI components
    lblReference = uilabel(fig, 'Position', [50, 330, 200, 20], 'Text', 'Select Reference Signature Image');
    uibutton(fig, 'Position', [50, 300, 200, 30], 'Text', 'Choose Reference', 'ButtonPushedFcn', @(btn, event) chooseReferenceImage());

    lblTest = uilabel(fig, 'Position', [300, 330, 200, 20], 'Text', 'Select Test Signature Image');
    uibutton(fig, 'Position', [300, 300, 200, 30], 'Text', 'Choose Test', 'ButtonPushedFcn', @(btn, event) chooseTestImage());
    
    % Image display components
    imgRefDisplay = uiimage(fig, 'Position', [50, 140, 200, 150]);
    imgTestDisplay = uiimage(fig, 'Position', [300, 140, 200, 150]);
    
    uibutton(fig, 'Position', [250, 70, 50, 40], 'Text', 'Verify', 'ButtonPushedFcn', @(btn, event) verifySignature());

    % Initialize variables for storing the selected images
    referenceImage = '';
    testImage = '';

    % Function to choose the reference signature image
    function chooseReferenceImage()
        [fileName, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.jfif', 'Image Files (*.png, *.jpg, *.jpeg, *.bmp, *.jfif)'}, 'Select an Image');
        if fileName ~= 0
            referenceImage = fullfile(path, fileName);
            lblReference.Text = ['Reference Image: ', fileName];
            imgRefDisplay.ImageSource = referenceImage;  % Display the reference image
        end
    end

    % Function to choose the test signature image
    function chooseTestImage()
        [fileName, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.jfif', 'Image Files (*.png, *.jpg, *.jpeg, *.bmp, *.jfif)'}, 'Select an Image');
        if fileName ~= 0
            testImage = fullfile(path, fileName);
            lblTest.Text = ['Test Image: ', fileName];
            imgTestDisplay.ImageSource = testImage;  % Display the test image
        end
    end

    % Function to verify the signatures when "Verify" button is clicked
    function verifySignature()
        if isempty(referenceImage) || isempty(testImage)
            uialert(fig, 'Please select both images!', 'Error', 'Icon', 'warning');
            return;
        end

        % Read the images
        img1 = imread(referenceImage);  % Reference signature
        img2 = imread(testImage);       % Test signature

        % Handle rotations: augment test image with rotated versions
        rotatedImages = createRotatedImages(img2);

        % Preprocess the reference image
        img1 = preprocessImage(img1);

        % Load AlexNet pre-trained network
        net = alexnet;

        % Initialize best similarity score
        bestDistance = inf;

        try
            % Extract features from the reference image
            features1 = activations(net, img1, 'fc7', 'OutputAs', 'rows');
            
            % Compare with all rotated versions of the test image
            for k = 1:length(rotatedImages)
                img2Rotated = preprocessImage(rotatedImages{k});
                features2 = activations(net, img2Rotated, 'fc7', 'OutputAs', 'rows');

                % Calculate the Euclidean distance
                distance = sqrt(sum((features1(:) - features2(:)).^2));
                % Keep track of the best (minimum) distance
                if distance < bestDistance
                    bestDistance = distance;
                end
            end

            % Display the best distance
            disp(" Best Euclidean distance between signatures: " + bestDistance);

            % Define a matching threshold
            threshold = 1.25;  
            
            % Classify the result
            if bestDistance < threshold 
                resultText = 'Genuine Signature';
                icon = 'success';
            else
                resultText = 'Forged Signature';
                icon = 'warning';
            end
            uialert(fig, sprintf('Result: %s\nEuclidean distance: %.2f', resultText, bestDistance), 'Verification Result', 'Icon', icon);

        catch ME
            disp('Error processing the signatures:');
            disp(ME.message);
            uialert(fig, 'Error during verification!', 'Error', 'Icon', 'error');
        end
    end
end

function img = preprocessImage(img)
    % Convert to grayscale if the image is RGB
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    
    % Denoise the image using a median filter
    img = medfilt2(img, [3, 3]); % Adjust filter size as needed
    
    % Enhance contrast using adaptive histogram equalization
    img = adapthisteq(img, 'ClipLimit', 0.02, 'Distribution', 'rayleigh');
    
    % Binarize the image
    img = imbinarize(img);
    img = imresize(img, [227, 227]);
    
    % Replicate to 3 channels for CNN compatibility
    img = repmat(img, [1, 1, 3]);
end

function rotatedImages = createRotatedImages(img)
    % Generate rotated versions of the test image
    angles = 0:15:345;  % Rotate in 15-degree steps
    rotatedImages = cell(1, length(angles));
    for i = 1:length(angles)
        rotatedImages{i} = imrotate(img, angles(i), 'bilinear', 'crop');
    end
end
