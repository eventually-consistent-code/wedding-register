# Infrastructure — OpenTofu + Terragrunt

3-tier AWS infra for wedding-register. **Code-only in this demo** — reviewed and
`validate`d, not applied.

```
infra/
├── modules/            # reusable OpenTofu modules
│   ├── network/        # VPC, public/app/data subnets, NAT, routing
│   ├── security/       # per-tier security groups + regional WAF web ACL
│   ├── compute/        # public ALB (+WAF), EC2 Auto Scaling Group (app tier)
│   └── database/       # RDS MySQL (private)
└── live/               # Terragrunt — DRY backend/provider + env wiring
    ├── terragrunt.hcl  # root: S3 state + aws provider, generated per component
    └── dev/
        ├── env.hcl     # name + region for this env
        ├── network/ security/ database/ compute/   # one state each, wired by `dependency`
```

## Why ALB (not NLB) for the WAF tier

AWS WAF attaches to an **Application** Load Balancer (and CloudFront / API GW),
not a Network LB. Since the registry is HTTP and wants L7 WAF rules, the web tier
is an ALB with a regional WAF web ACL. An NLB would be the choice for raw L4
pass-through with no WAF — noted here because the brief said "WAF NLB/ALB".

## Validate (no AWS account needed)

Each module validates offline (downloads the provider, no creds):

```bash
cd infra/modules/network && tofu init -backend=false && tofu validate
```

## Plan / apply (needs AWS creds + a state bucket)

```bash
export TF_VAR_db_password=...                  # or pull from SSM
cd infra/live/dev
terragrunt run-all validate                    # whole stack, dependency-ordered
terragrunt run-all plan
# terragrunt run-all apply                      # NOT run in this demo
```

State lives in an S3 bucket `wedding-register-tfstate` with a DynamoDB lock
table `wedding-register-tflock` (create once before the first apply).
