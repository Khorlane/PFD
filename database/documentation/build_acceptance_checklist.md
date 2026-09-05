# PFD Core Build Acceptance Checklist

- [ ] Deployment target and approved manifest version identified.
- [ ] Backup/restore readiness confirmed for the target environment.
- [ ] Cluster roles bootstrapped and verified; owner is `NOLOGIN`, executor is `NOINHERIT`.
- [ ] Secrets are stored outside the package and libpq service connectivity succeeds.
- [ ] `validate` mode passes before build.
- [ ] `build-and-verify` mode completes without error.
- [ ] `core.database_change` contains contiguous changes `0001` through `0010` with matching checksums.
- [ ] Core SQL test suite passes in a disposable database.
- [ ] Natural-key, no-surrogate-key, privilege, and reference-data checks pass.
- [ ] Build and verification evidence is retained with operator and approver identification.
- [ ] Package is promoted unchanged between environments.
