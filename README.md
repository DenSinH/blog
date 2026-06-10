# Blog

For local development:
```bash
nix develop
hugo server -D
```

To run the docker compose locally, don't forget to add
```yaml
ports:
- 80:80
```
to the `docker-compose.yml`.