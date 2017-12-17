FROM python:3

# Install the dependencies
COPY requirements.txt .
RUN pip3 install -r requirements.txt

# Copy the source files
WORKDIR /usr/src/app
COPY ./src/ .

# Expose the ports
EXPOSE 8080

# Run the server
CMD [ "python3", "main.py", "0.0.0.0", "8080", "/stor/projects.json" ]