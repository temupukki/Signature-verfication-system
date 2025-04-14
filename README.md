Signature Verification System
============================

A MATLAB-based tool for verifying handwritten signatures using AlexNet (CNN) and image processing techniques.

Features:
---------
- Compares a reference signature with a test signature.
- Uses pre-trained AlexNet for feature extraction.
- Handles rotated signatures for better matching.
- Provides Euclidean distance as a similarity metric.
- Simple GUI for easy interaction.

How to Use:
-----------
1. Run the MATLAB Script:
   - Open MATLAB and run:
     >> SignatureVerificationSystem();
   - A GUI window will appear.

2. Select Images:
   - Click "Choose Reference" to select a known genuine signature.
   - Click "Choose Test" to select the signature to verify.

3. Verify Signatures:
   - Click "Verify" to compare the signatures.
   - The system will display:
     - "Genuine Signature" (if the distance is below a threshold).
     - "Forged Signature" (if the distance is too high).

Dependencies:
-------------
- MATLAB R2020b or later
- Deep Learning Toolbox (for AlexNet)
- Image Processing Toolbox

Dataset:
--------
Test signatures can be downloaded from:
CEDAR Signature Dataset: https://cedar.buffalo.edu/NIJ/data/signatures.rar

How It Works:
-------------
1. Preprocessing:
   - Converts images to grayscale.
   - Applies median filtering and adaptive histogram equalization.
   - Binarizes and resizes images to 227×227 (AlexNet input size).

2. Feature Extraction:
   - Uses AlexNet's fc7 layer to extract deep features.

3. Rotation Handling:
   - Generates 24 rotated versions (15° steps) of the test signature.
   - Compares all rotations to find the best match.

4. Similarity Check:
   - Computes Euclidean distance between features.
   - Classifies as genuine/forged based on a threshold (1.25).

Notes:
------
- Adjust the threshold in code for stricter/looser verification.
- Works best with clean, high-contrast signature images.

