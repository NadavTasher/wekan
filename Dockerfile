FROM ubuntu:24.04 AS build

# Add binaries of NodeJS from the official archive
ADD https://nodejs.org/download/release/v14.21.3/node-v14.21.3-linux-x64.tar.gz /tmp/node.tar.gz
RUN tar xzf /tmp/node.tar.gz --strip-components=1 --keep-old-files --no-same-owner

# Install meteor globally
ADD https://static.meteor.com/packages-bootstrap/2.16/meteor-bootstrap-os.linux.x86_64.tar.gz /tmp/meteor.tar.gz
RUN tar xzf /tmp/meteor.tar.gz -C $HOME --no-same-owner

# Update the npm version
RUN npm install -g npm@v8.19.4

# Install several build dependencies
RUN apt update && \
    apt install --yes --no-install-suggests --no-install-recommends ssh git g++ curl && \
    rm -r /var/lib/apt/lists

# Change to temporary working directory
WORKDIR /tmp

# Copy package.json and package-lock.json to install application dependencies
COPY package.json .
COPY package-lock.json .

# Install application dependencies
RUN npm install -g --omit=dev

# Copy meteor application configurations
COPY .meteor .meteor

# Copy application sources
COPY packages packages
COPY client client
COPY server server
COPY config config
COPY models models
COPY public public

# Build the application
RUN $HOME/.meteor/meteor build --directory /build --allow-superuser


RUN cd node_modules/fibers; node build.js; rm -rf /home/wekan/app_build/bundle/programs/web.browser.legacy

# Change to server directory and build server
WORKDIR /build/bundle/programs/server

# Install server dependencies
RUN npm install -g --production

RUN mkdir /data
RUN chown wekan --recursive /data

USER wekan

ENV PORT=8080
EXPOSE $PORT

STOPSIGNAL SIGKILL
WORKDIR /home/wekan/app

#---------------------------------------------------------------------
# https://github.com/wekan/wekan/issues/3585#issuecomment-1021522132
# Add more Node heap:
#   NODE_OPTIONS="--max_old_space_size=4096"
# Add more stack:
#   bash -c "ulimit -s 65500; exec node --stack-size=65500 main.js"
#---------------------------------------------------------------------
#
# CMD ["node", "/build/main.js"]
# CMD ["bash", "-c", "ulimit -s 65500; exec node --stack-size=65500 /build/main.js"]
# CMD ["bash", "-c", "ulimit -s 65500; exec node --stack-size=65500 --max-old-space-size=8192 /build/main.js"]

FROM ubuntu:24.04

LABEL maintainer="wekan"
LABEL org.opencontainers.image.ref.name="ubuntu"
LABEL org.opencontainers.image.version="24.10"
LABEL org.opencontainers.image.source="https://github.com/wekan/wekan"


ENV SRC_PATH=./ \
    WITH_API=true \
    RESULTS_PER_PAGE="" \
    DEFAULT_BOARD_ID="" \
    ACCOUNTS_LOCKOUT_KNOWN_USERS_FAILURES_BEFORE=3 \
    ACCOUNTS_LOCKOUT_KNOWN_USERS_PERIOD=60 \
    ACCOUNTS_LOCKOUT_KNOWN_USERS_FAILURE_WINDOW=15 \
    ACCOUNTS_LOCKOUT_UNKNOWN_USERS_FAILURES_BERORE=3 \
    ACCOUNTS_LOCKOUT_UNKNOWN_USERS_LOCKOUT_PERIOD=60 \
    ACCOUNTS_LOCKOUT_UNKNOWN_USERS_FAILURE_WINDOW=15 \
    ACCOUNTS_COMMON_LOGIN_EXPIRATION_IN_DAYS=90 \
    ATTACHMENTS_UPLOAD_EXTERNAL_PROGRAM="" \
    ATTACHMENTS_UPLOAD_MIME_TYPES="" \
    ATTACHMENTS_UPLOAD_MAX_SIZE=0 \
    AVATARS_UPLOAD_EXTERNAL_PROGRAM="" \
    AVATARS_UPLOAD_MIME_TYPES="" \
    AVATARS_UPLOAD_MAX_SIZE=72000 \
    RICHER_CARD_COMMENT_EDITOR=false \
    CARD_OPENED_WEBHOOK_ENABLED=false \
    MAX_IMAGE_PIXEL="" \
    IMAGE_COMPRESS_RATIO="" \
    NOTIFICATION_TRAY_AFTER_READ_DAYS_BEFORE_REMOVE="" \
    BIGEVENTS_PATTERN=NONE \
    NOTIFY_DUE_DAYS_BEFORE_AND_AFTER="" \
    NOTIFY_DUE_AT_HOUR_OF_DAY="" \
    EMAIL_NOTIFICATION_TIMEOUT=30000 \
    MATOMO_ADDRESS="" \
    MATOMO_SITE_ID="" \
    MATOMO_DO_NOT_TRACK=true \
    MATOMO_WITH_USERNAME=false \
    METRICS_ALLOWED_IP_ADDRESSES="" \
    BROWSER_POLICY_ENABLED=true \
    TRUSTED_URL="" \
    WEBHOOKS_ATTRIBUTES="" \
    OAUTH2_ENABLED=false \
    OIDC_REDIRECTION_ENABLED=false \
    OAUTH2_CA_CERT="" \
    OAUTH2_ADFS_ENABLED=false \
    OAUTH2_B2C_ENABLED=false \
    OAUTH2_LOGIN_STYLE=redirect \
    OAUTH2_CLIENT_ID="" \
    OAUTH2_SECRET="" \
    OAUTH2_SERVER_URL="" \
    OAUTH2_AUTH_ENDPOINT="" \
    OAUTH2_USERINFO_ENDPOINT="" \
    OAUTH2_TOKEN_ENDPOINT="" \
    OAUTH2_ID_MAP="" \
    OAUTH2_USERNAME_MAP="" \
    OAUTH2_FULLNAME_MAP="" \
    OAUTH2_ID_TOKEN_WHITELIST_FIELDS="" \
    OAUTH2_REQUEST_PERMISSIONS='openid profile email' \
    OAUTH2_EMAIL_MAP="" \
    LDAP_ENABLE=false \
    LDAP_PORT=389 \
    LDAP_HOST="" \
    LDAP_AD_SIMPLE_AUTH="" \
    LDAP_USER_AUTHENTICATION=false \
    LDAP_USER_AUTHENTICATION_FIELD=uid \
    LDAP_BASEDN="" \
    LDAP_LOGIN_FALLBACK=false \
    LDAP_RECONNECT=true \
    LDAP_TIMEOUT=10000 \
    LDAP_IDLE_TIMEOUT=10000 \
    LDAP_CONNECT_TIMEOUT=10000 \
    LDAP_AUTHENTIFICATION=false \
    LDAP_AUTHENTIFICATION_USERDN="" \
    LDAP_AUTHENTIFICATION_PASSWORD="" \
    LDAP_LOG_ENABLED=false \
    LDAP_BACKGROUND_SYNC=false \
    LDAP_BACKGROUND_SYNC_INTERVAL="" \
    LDAP_BACKGROUND_SYNC_KEEP_EXISTANT_USERS_UPDATED=false \
    LDAP_BACKGROUND_SYNC_IMPORT_NEW_USERS=false \
    LDAP_ENCRYPTION=false \
    LDAP_CA_CERT="" \
    LDAP_REJECT_UNAUTHORIZED=false \
    LDAP_USER_SEARCH_FILTER="" \
    LDAP_USER_SEARCH_SCOPE="" \
    LDAP_USER_SEARCH_FIELD="" \
    LDAP_SEARCH_PAGE_SIZE=0 \
    LDAP_SEARCH_SIZE_LIMIT=0 \
    LDAP_GROUP_FILTER_ENABLE=false \
    LDAP_GROUP_FILTER_OBJECTCLASS="" \
    LDAP_GROUP_FILTER_GROUP_ID_ATTRIBUTE="" \
    LDAP_GROUP_FILTER_GROUP_MEMBER_ATTRIBUTE="" \
    LDAP_GROUP_FILTER_GROUP_MEMBER_FORMAT="" \
    LDAP_GROUP_FILTER_GROUP_NAME="" \
    LDAP_UNIQUE_IDENTIFIER_FIELD="" \
    LDAP_UTF8_NAMES_SLUGIFY=true \
    LDAP_USERNAME_FIELD="" \
    LDAP_FULLNAME_FIELD="" \
    LDAP_MERGE_EXISTING_USERS=false \
    LDAP_EMAIL_FIELD="" \
    LDAP_EMAIL_MATCH_ENABLE=false \
    LDAP_EMAIL_MATCH_REQUIRE=false \
    LDAP_EMAIL_MATCH_VERIFIED=false \
    LDAP_SYNC_USER_DATA=false \
    LDAP_SYNC_USER_DATA_FIELDMAP="" \
    LDAP_SYNC_GROUP_ROLES="" \
    LDAP_DEFAULT_DOMAIN="" \
    LDAP_SYNC_ADMIN_STATUS="" \
    LDAP_SYNC_ADMIN_GROUPS="" \
    HEADER_LOGIN_ID="" \
    HEADER_LOGIN_FIRSTNAME="" \
    HEADER_LOGIN_LASTNAME="" \
    HEADER_LOGIN_EMAIL="" \
    LOGOUT_WITH_TIMER=false \
    LOGOUT_IN="" \
    LOGOUT_ON_HOURS="" \
    LOGOUT_ON_MINUTES="" \
    CORS="" \
    CORS_ALLOW_HEADERS="" \
    CORS_EXPOSE_HEADERS="" \
    DEFAULT_AUTHENTICATION_METHOD="" \
    PASSWORD_LOGIN_ENABLED=true \
    CAS_ENABLED=false \
    CAS_BASE_URL="" \
    CAS_LOGIN_URL="" \
    CAS_VALIDATE_URL="" \
    SAML_ENABLED=false \
    SAML_PROVIDER="" \
    SAML_ENTRYPOINT="" \
    SAML_ISSUER="" \
    SAML_CERT="" \
    SAML_IDPSLO_REDIRECTURL="" \
    SAML_PRIVATE_KEYFILE="" \
    SAML_PUBLIC_CERTFILE="" \
    SAML_IDENTIFIER_FORMAT="" \
    SAML_LOCAL_PROFILE_MATCH_ATTRIBUTE="" \
    SAML_ATTRIBUTES="" \
    ORACLE_OIM_ENABLED=false \
    WAIT_SPINNER="" \
    WRITABLE_PATH=/data \
    S3=""

COPY --from=build /build /build

CMD ["bash", "-c", "ulimit -s 65500; exec node /build/main.js"]
