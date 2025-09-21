# ---- Use Lyfe's prebuilt base image ----
FROM quay.io/lyfe00011/md:beta

# ---- Clone your fork instead of Lyfe's ----
RUN git clone https://github.com/original-netrunner/levanter.git /root/bot
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

# ---- Patch root index.js to load protector first ----
RUN echo "console.log('🚀 index.js bootstrap');\n\
try { require('./lib/protect-session'); } catch(e){ console.warn('⚠️ protector failed:', e&&e.message);} \n\
require('./lib/client');" > index.js

# ---- Install dependencies (same as original) ----
RUN yarn install

# ---- Default command (same as original) ----
CMD ["npm", "start"]
