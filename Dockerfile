FROM mcr.microsoft.com/devcontainers/jekyll:2-bullseye

# Set the working directory
WORKDIR /workspace

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Configure bundler path and install gems
RUN bundle config set --local path '/usr/local/bundle'
RUN bundle install

# Copy package.json and package-lock.json if they exist
COPY package*.json ./

# Install Node.js dependencies
RUN if [ -f package.json ]; then \
      bash -i -c "nvm install --lts && nvm install-latest-npm"; \
      npm install; \
    fi

# Copy the rest of the application code
COPY . .

# Copy and run the post-create script
COPY .devcontainer/post-create.sh /post-create.sh
RUN bash /post-create.sh

# Expose port 4000
EXPOSE 4000

# Default command
CMD ["bundle", "exec", "jekyll", "serve", "--host=0.0.0.0"]
