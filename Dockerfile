FROM python:3

# Copy the requirements.txt file into the container
COPY requirements.txt /app/requirements.txt

# Install the required libraries from requirements.txt
RUN pip install -r /app/requirements.txt

# Copy the entire project directory (including Q2, Q5, etc.) into the container
COPY . /app

# Set the working directory where your code is located (in this case, Q2 folder)
WORKDIR /app/Work/Q2

# Run the Python code
CMD ["python", "plant.py"]
