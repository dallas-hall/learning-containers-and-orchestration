# Use an official Python runtime as a parent image
FROM python:3.7-slim

# Set the working directory contents into the container at /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Make port 80 available to the world outside this container
EXPOSE 80

# Define an environment variable
ENV NAME World

# Run app.py when the container lunches
CMD ["python", "app.py"]
