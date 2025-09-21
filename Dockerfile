FROM quay.io/lyfe00011/md:beta

# Clone your fork instead of Lyfe's
RUN git clone https://github.com/original-netrunner/levanter.git /root/LyFE/

# Set working directory
WORKDIR /root/LyFE/

# Install dependencies
RUN yarn install

# Start Levanter (pm2 as in original)
CMD ["npm", "start"]
