# ---- Build stage ----
# todo: try alpine-latest or something?
FROM hugomods/hugo:latest as builder

WORKDIR /src

# Build site
COPY . /src

# Clone theme, do a shallow clone to speed it up a little
# RUN apk add --no-cache git
RUN git clone --recurse-submodules --depth 1 --filter=blob:none https://github.com/DenSinH/hugo-theme-stack.git themes/stack

# Replace below build command at will.
RUN hugo --minify

FROM nginx:alpine

# copy files
COPY --from=builder /src/public/ /site
COPY nginx.conf /etc/nginx/conf.d/default.conf