# Use the official Node.js image as a base
FROM node:16-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to install dependencies
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose port 8080 for the server
EXPOSE 8080
# Command to run the application
CMD ["npm", "start"]