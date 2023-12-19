from base64 import b64encode
from flask import Flask, request, jsonify
import cv2
import numpy as np
import tempfile
import os
from PIL import Image
from roboflow import Roboflow

app = Flask(__name__)

# Color map for each class
color_map = {
    'battery': (255, 255, 0),               # Cyan
    'paper': (0, 255, 0),                   # Bright Green
    'plastic bag': (0, 255, 255),           # Yellow
    'can': (255, 153, 204),                 # Pink
    'glass bottle': (0, 100, 0),            # Dark Green
    'pop tab': (0, 0, 255),                 # Red
    'plastic bottle': (255, 0, 0),          # Blue
    'cardboard': (0, 165, 255),             # Orange
    'plastic bottle cap': (255, 0, 255),    # Purple
    'drink carton': (128, 128, 0),          # Teal
}

# Helper function to resize image 
def resize_image_with_aspect_ratio(image_path, target_size=(640, 640), background_color=(0, 0, 0)):
    # Load the image
    image = cv2.imread(image_path)
    if image is None:
        print("Error: Image not found.")
        return None

    # Calculate the ratio of the target dimensions
    height_ratio, width_ratio = target_size[0] / image.shape[0], target_size[1] / image.shape[1]
    ratio = min(height_ratio, width_ratio)

    # Calculate the new image size
    new_size = (int(image.shape[1] * ratio), int(image.shape[0] * ratio))

    # Resize the image
    resized_image = cv2.resize(image, new_size, interpolation=cv2.INTER_AREA)

    # Create a black background
    background = np.full((target_size[0], target_size[1], 3), background_color, dtype=np.uint8)

    # Calculate the centering position
    x_offset = (background.shape[1] - resized_image.shape[1]) // 2
    y_offset = (background.shape[0] - resized_image.shape[0]) // 2

    # Place the resized image onto the black background
    background[y_offset:y_offset + resized_image.shape[0], x_offset:x_offset + resized_image.shape[1]] = resized_image

    # Return the resized image, scaling factors, and offsets
    scaling_factors = (new_size[0] / image.shape[1], new_size[1] / image.shape[0])
    offsets = (x_offset, y_offset)
    return background, scaling_factors, offsets

# Helper function to draw bounding boxes and labels on the image
def annotate_image(image, predictions, scaling_factors, offsets):
    # Overlay for drawing
    overlay = image.copy()

    for bounding_box in predictions['predictions']:
        class_name = bounding_box["class"]
        color = color_map.get(class_name, (255, 255, 255))  # Default to white if class not in map

        # Calculate the text size
        ((text_width, text_height), _) = cv2.getTextSize(class_name, cv2.FONT_HERSHEY_SIMPLEX, 1, 2)

        # Adjust the bounding box coordinates
        x0 = (bounding_box['x'] - bounding_box['width'] / 2 - offsets[0]) / scaling_factors[0]
        x1 = (bounding_box['x'] + bounding_box['width'] / 2 - offsets[0]) / scaling_factors[0]
        y0 = (bounding_box['y'] - bounding_box['height'] / 2 - offsets[1]) / scaling_factors[1]
        y1 = (bounding_box['y'] + bounding_box['height'] / 2 - offsets[1]) / scaling_factors[1]

        start_point = (int(x0), int(y0))
        end_point = (int(x1), int(y1))

        # Draw semi-transparent rectangle
        cv2.rectangle(overlay, start_point, end_point, color, thickness=cv2.FILLED)
        alpha = 0.1  # Transparency factor
        cv2.addWeighted(overlay, alpha, image, 1 - alpha, 0, image)

        # Draw border rectangle
        cv2.rectangle(image, start_point, end_point, color, thickness=3)
        
        # Ensure the text starts within the image width
        text_x = min(max(int(x0), 0), image.shape[1] - text_width)

        # If the box is at the top of the image, draw the text inside the box at the bottom
        if int(y0) - 10 < 0:
            text_y = min(int(y1) + text_height, image.shape[0])
        else:
            text_y = max(int(y0) - 10, text_height)

        cv2.putText(
            image,
            class_name,
            (text_x, text_y),
            fontFace=cv2.FONT_HERSHEY_SIMPLEX,
            fontScale=2,
            color=color,
            thickness=4
        )

    return image

# Helper function to check if the uploaded file is in allowed format.
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in {'png', 'jpg', 'jpeg'}

# Define the prediction route
@app.route("/predict", methods=["POST"])
def predict_img():
    if request.method == "POST":
        # Check if the post request has the file part
        if 'file' not in request.files:
            return jsonify({'error': 'No file part'}), 400
        
        # Get file
        file = request.files['file']
        
        # If user does not select file, browser submits an empty part without filename
        if file.filename == '' or not allowed_file(file.filename):
            return jsonify({'error': 'No selected file or file type not allowed'}), 400

        # Save as temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".jpg") as temp_file:
            file.save(temp_file)
            temp_file_path = temp_file.name

        try:
            # Resize and prepare image
            resized_image, scaling_factors, offsets = resize_image_with_aspect_ratio(temp_file_path)
            if resized_image is None:
                raise Exception("Failed to resize the image.")
            
            # Initialize Roboflow model and run inference
            rf = Roboflow(api_key="LQxr4L2Urf21o5qN3eJz")
            project = rf.workspace().project("yolov8-trash-detections")
            model = project.version(6).model
            predictions = model.predict(resized_image, confidence=50, overlap=30).json()

            # Annotate the original image
            original_image = cv2.imread(temp_file_path)
            annotated_image = annotate_image(original_image, predictions, scaling_factors, offsets)
            
            # Encode the annotated image to a base64 string
            _, encoded_image = cv2.imencode('.jpg', annotated_image)
            base64_image = b64encode(encoded_image).decode('utf-8')
        
            # Process predictions to exclude 'image_path'
            processed_predictions = []
            for pred in predictions['predictions']:
                processed_pred = {key: val for key, val in pred.items() if key != 'image_path'}
                processed_predictions.append(processed_pred)

            # Construct the response with processed predictions and the base64 image
            response = {
                'predictions': processed_predictions,
                'image': base64_image
            }

            print(processed_predictions)

            return jsonify(response)
        
        except Exception as e:
            print(f"Error during prediction: {e}")
            return jsonify({'error': 'Error during prediction'}), 500
        
        finally:
            # Clean up the temporary files
            os.remove(temp_file_path)

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)