# ---- Base image ----
FROM node:20-bullseye

# Install system dependencies for sharp/ffmpeg/sqlite3
RUN apt-get update && apt-get install -y \
    git ffmpeg sqlite3 python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

# ---- Clone your repo ----
WORKDIR /root
RUN git clone https://github.com/original-netrunner/levanter.git bot
WORKDIR /root/bot

# ---- Add session protector ----
RUN mkdir -p lib && echo "\
const fs = require('fs');\n\
const path = require('path');\n\
const projectRoot = path.resolve(__dirname, '..');\n\
const backupDir = path.join(projectRoot, '.session_backup');\n\
const protectPatterns = ['/session','auth_info','creds','creds.json','auth_info_baileys','auth_info_multi'];\n\
function isProtectedPath(p){if(!p)return false;try{const abs=path.resolve(p);return protectPatterns.some(pat=>abs.toLowerCase().includes(pat));}catch(e){return false;}}\n\
(function patch(){try{const orig=fs.unlinkSync;fs.unlinkSync=function(p){if(isProtectedPath(p)){console.warn('[protect-session] blocked unlinkSync',p);return;}return orig.apply(this,arguments);};console.log('[protect-session] enabled');}catch(e){console.warn('[protect-session] failed',e&&e.message);}})();" \
> lib/protect-session.js

# ---- Patch index.js at repo root ----
RUN echo "console.log('🚀 index.js bootstrap');\n\
try { require('./lib/protect-session'); } catch(e){ console.warn('⚠️ protector failed:', e&&e.message);} \n\
require('./lib/client');" > index.js

# ---- Install dependencies ----
RUN yarn install --network-concurrency 1

# Ensure session dirs exist
RUN mkdir -p /root/bot/session /root/bot/.session_backup

# ---- Expose port (optional: dashboard etc.) ----
EXPOSE 3000

# ---- Start with PM2 ----
CMD ["yarn", "docker"]
